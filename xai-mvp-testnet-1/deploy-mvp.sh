#!/bin/bash
# XAI MVP Testnet Deployment Script
# Migrates from xai-testnet-1 to xai-mvp-testnet-1
#
# Usage: ./deploy-mvp.sh [phase]
#   phase 1: Stop old services and backup
#   phase 2: Deploy to xai-testnet (nodes 1 & 2)
#   phase 3: Deploy to services-testnet (nodes 3 & 4)
#   phase 4: Start all nodes and verify
#   all: Run all phases

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHAIN_ID="xai-mvp-testnet-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[MVP]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

phase1_backup() {
    log "Phase 1: Stopping old services and creating backups..."

    # Stop old services on xai-testnet
    log "Stopping services on xai-testnet..."
    ssh xai-testnet "sudo systemctl stop xai xai-node2 xai-explorer xai-faucet xai-indexer xai-websocket 2>/dev/null || true"

    # Stop old services on services-testnet
    log "Stopping services on services-testnet..."
    ssh services-testnet "sudo systemctl stop xai-node3 xai-node4 2>/dev/null || true"

    # Backup old data on xai-testnet
    log "Backing up data on xai-testnet..."
    ssh xai-testnet "mkdir -p ~/xai-backup-$(date +%Y%m%d) && \
        cp -r ~/xai/data ~/xai-backup-$(date +%Y%m%d)/node1-data 2>/dev/null || true && \
        cp -r ~/xai-node2/data ~/xai-backup-$(date +%Y%m%d)/node2-data 2>/dev/null || true"

    # Backup old data on services-testnet
    log "Backing up data on services-testnet..."
    ssh services-testnet "mkdir -p ~/xai-backup-$(date +%Y%m%d) && \
        cp -r ~/xai-node3/data ~/xai-backup-$(date +%Y%m%d)/node3-data 2>/dev/null || true && \
        cp -r ~/xai-node4/data ~/xai-backup-$(date +%Y%m%d)/node4-data 2>/dev/null || true"

    log "Phase 1 complete: Services stopped, backups created"
}

phase2_deploy_xai_testnet() {
    log "Phase 2: Deploying MVP to xai-testnet (nodes 1 & 2)..."

    # Create MVP directories
    ssh xai-testnet "mkdir -p ~/xai-mvp/{node1,node2}/{data,config,wallets,logs}"

    # Copy genesis
    scp "${SCRIPT_DIR}/genesis.json" xai-testnet:~/xai-mvp/genesis.json

    # Copy validator wallets (reusing existing)
    ssh xai-testnet "cp ~/xai/wallets/validator.json ~/xai-mvp/node1/wallets/ 2>/dev/null || true"
    ssh xai-testnet "cp ~/xai-node2/wallets/validator.json ~/xai-mvp/node2/wallets/ 2>/dev/null || true"

    # Deploy systemd services
    log "Installing systemd services on xai-testnet..."
    scp "${SCRIPT_DIR}/systemd/xai-node1.service" xai-testnet:/tmp/
    scp "${SCRIPT_DIR}/systemd/xai-node2.service" xai-testnet:/tmp/

    ssh xai-testnet "sudo cp /tmp/xai-node1.service /etc/systemd/system/xai-mvp-node1.service && \
        sudo cp /tmp/xai-node2.service /etc/systemd/system/xai-mvp-node2.service && \
        sudo systemctl daemon-reload"

    log "Phase 2 complete: xai-testnet configured"
}

phase3_deploy_services_testnet() {
    log "Phase 3: Deploying MVP to services-testnet (nodes 3 & 4)..."

    # Create MVP directories
    ssh services-testnet "mkdir -p ~/xai-mvp/{node3,node4}/{data,config,wallets,logs}"

    # Copy genesis
    scp "${SCRIPT_DIR}/genesis.json" services-testnet:~/xai-mvp/genesis.json

    # Copy validator wallets (reusing existing)
    ssh services-testnet "cp ~/xai-node3/wallets/validator.json ~/xai-mvp/node3/wallets/ 2>/dev/null || true"
    ssh services-testnet "cp ~/xai-node4/wallets/validator.json ~/xai-mvp/node4/wallets/ 2>/dev/null || true"

    # Deploy systemd services
    log "Installing systemd services on services-testnet..."
    scp "${SCRIPT_DIR}/systemd/xai-node3.service" services-testnet:/tmp/
    scp "${SCRIPT_DIR}/systemd/xai-node4.service" services-testnet:/tmp/

    ssh services-testnet "sudo cp /tmp/xai-node3.service /etc/systemd/system/xai-mvp-node3.service && \
        sudo cp /tmp/xai-node4.service /etc/systemd/system/xai-mvp-node4.service && \
        sudo systemctl daemon-reload"

    log "Phase 3 complete: services-testnet configured"
}

phase4_start_and_verify() {
    log "Phase 4: Starting MVP nodes and verifying consensus..."

    # Start node 1 first
    log "Starting node 1 (xai-testnet)..."
    ssh xai-testnet "sudo systemctl start xai-mvp-node1"
    sleep 10

    # Start node 2
    log "Starting node 2 (xai-testnet)..."
    ssh xai-testnet "sudo systemctl start xai-mvp-node2"
    sleep 10

    # Start node 3
    log "Starting node 3 (services-testnet)..."
    ssh services-testnet "sudo systemctl start xai-mvp-node3"
    sleep 10

    # Start node 4
    log "Starting node 4 (services-testnet)..."
    ssh services-testnet "sudo systemctl start xai-mvp-node4"
    sleep 20

    # Verify all nodes
    log "Verifying node status..."

    echo ""
    echo "=== Node Heights ==="
    for i in 1 2; do
        port=$((12544 + i))
        height=$(ssh xai-testnet "curl -s http://127.0.0.1:${port}/stats 2>/dev/null | jq -r '.chain_height // \"offline\"'" 2>/dev/null || echo "offline")
        echo "Node $i (xai-testnet:${port}): height $height"
    done

    for i in 3 4; do
        port=$((12543 + i))
        height=$(ssh services-testnet "curl -s http://127.0.0.1:${port}/stats 2>/dev/null | jq -r '.chain_height // \"offline\"'" 2>/dev/null || echo "offline")
        echo "Node $i (services-testnet:${port}): height $height"
    done

    echo ""
    log "Phase 4 complete: All nodes started"
    echo ""
    echo "=== MVP Testnet Endpoints ==="
    echo "Node 1 RPC: http://10.10.0.3:12545"
    echo "Node 2 RPC: http://10.10.0.3:12555"
    echo "Node 3 RPC: http://10.10.0.4:12546"
    echo "Node 4 RPC: http://10.10.0.4:12556"
}

# Main
case "${1:-all}" in
    1|phase1) phase1_backup ;;
    2|phase2) phase2_deploy_xai_testnet ;;
    3|phase3) phase3_deploy_services_testnet ;;
    4|phase4) phase4_start_and_verify ;;
    all)
        phase1_backup
        phase2_deploy_xai_testnet
        phase3_deploy_services_testnet
        phase4_start_and_verify
        ;;
    *)
        echo "Usage: $0 [1|2|3|4|all]"
        echo "  1: Stop old services and backup"
        echo "  2: Deploy to xai-testnet"
        echo "  3: Deploy to services-testnet"
        echo "  4: Start and verify"
        echo "  all: Run all phases"
        exit 1
        ;;
esac
