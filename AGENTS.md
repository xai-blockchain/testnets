# XAI Testnets Repository

## Repository Purpose

This repository contains network configuration for XAI testnets. Source code lives in the main `xai/` repository.

| Repository | GitHub | Purpose |
|------------|--------|---------|
| `testnets/` | xai-blockchain/testnets | Network configs, genesis, peers |
| `xai/` | xai-blockchain/xai | Source code, blockchain node |

## Active Network

| Network | Chain ID | Status |
|---------|----------|--------|
| MVP Testnet | `xai-mvp-testnet-1` | **Active** |

## Directory Structure

```
testnets/
├── CLAUDE.md              # This file
├── README.md              # Public repo README
├── docs/                  # Additional documentation
│   └── public-endpoints.md
└── xai-mvp-testnet-1/     # Active testnet
    ├── README.md          # Network documentation
    ├── genesis.json       # Genesis configuration
    ├── peers.txt          # P2P peer list
    ├── config.json        # Node configuration template
    ├── validators.json    # Validator set
    ├── systemd/           # Service unit templates
    └── e2e/               # End-to-end test configs
```

## Save Location Guide

### Save to THIS repo (testnets/)
- Network configuration (genesis.json, config.json)
- Peer lists (peers.txt, seeds.txt)
- Network metadata (network_info.json)
- Testnet-specific documentation
- Systemd service templates

### Save to MAIN repo (xai/)
- Python source code
- Blockchain modules
- Tests and requirements
- Docker configurations
- General documentation

## Infrastructure Overview

### Servers

| Server | SSH Alias | Public IP | VPN IP | Role |
|--------|-----------|-----------|--------|------|
| xai-testnet | `ssh xai-testnet` | 54.39.129.11 | 10.10.0.3 | Primary (sentries + 2 validators) |
| services-testnet | `ssh services-testnet` | 139.99.149.160 | 10.10.0.4 | Secondary (2 validators) |

### Node Ports (xai-testnet / 10.10.0.3)

| Node | Role | RPC | P2P | Service |
|------|------|-----|-----|---------|
| Sentry 1 | Public Gateway | 12570 | 12371 | `xai-sentry1.service` |
| Sentry 2 | Public Gateway | 12571 | 12372 | `xai-sentry2.service` |
| Node 1 | Miner+Validator | 12545 | 12333 | `xai-mvp-node1.service` |
| Node 2 | Miner+Validator | 12555 | 12334 | `xai-mvp-node2.service` |

### Node Ports (services-testnet / 10.10.0.4)

| Node | Role | RPC | P2P | Service |
|------|------|-----|-----|---------|
| Node 3 | Validator Only | 12546 | 12335 | `xai-mvp-node3.service` |
| Node 4 | Validator Only | 12556 | 12336 | `xai-mvp-node4.service` |

### Supporting Services (xai-testnet)

| Service | Port | Description | Service Unit |
|---------|------|-------------|--------------|
| **Blockscout Explorer** ||||
| RPC Adapter | 8545 | EVM JSON-RPC adapter (dual sentry failover) | `xai-rpc-adapter.service` |
| Blockscout Backend | 4000 | Block indexer (Elixir/OTP) | Docker: `blockscout-backend` |
| Blockscout Frontend | 3001 | Explorer UI (Next.js) | Docker: `blockscout-frontend` |
| PostgreSQL | 5432 | Indexed chain data | Docker: `blockscout-postgres` |
| **Other Services** ||||
| Faucet | 12081 | Testnet token faucet | `xai-faucet.service` |
| WebSocket | 8766 | Real-time block updates | `xai-websocket.service` |
| GraphQL | 8083 | GraphQL API | `xai-graphql.service` |
| WS Metrics | 8767 | Prometheus metrics | Part of websocket |

### Public Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| RPC | https://testnet-rpc.xaiblockchain.com | Native XAI JSON-RPC |
| REST API | https://testnet-api.xaiblockchain.com | REST API (load-balanced) |
| WebSocket | wss://testnet-ws.xaiblockchain.com | Real-time updates |
| GraphQL | https://testnet-graphql.xaiblockchain.com | GraphQL playground |
| **Explorer** | https://testnet-explorer.xaiblockchain.com | **Blockscout block explorer** |
| Explorer API | https://testnet-explorer.xaiblockchain.com/api/v2/* | Blockscout REST API |
| RPC Health | https://testnet-explorer.xaiblockchain.com/rpc-health | Adapter health (both sentries) |
| Faucet | https://testnet-faucet.xaiblockchain.com | Get test tokens |
| Docs | https://testnet-docs.xaiblockchain.com | API documentation |
| Archive | https://testnet-archive.xaiblockchain.com | Archive node RPC |
| Artifacts | https://artifacts.xaiblockchain.com | Config files, snapshots |

## Quick Commands

```bash
# Check chain height
curl -s https://testnet-rpc.xaiblockchain.com/stats | jq '.chain_height'

# Check all nodes
for port in 12545 12555 12570 12571; do
  ssh xai-testnet "curl -s http://127.0.0.1:$port/stats | jq -r '.chain_height'"
done
ssh services-testnet "curl -s http://127.0.0.1:12546/stats | jq .chain_height"
ssh services-testnet "curl -s http://127.0.0.1:12556/stats | jq .chain_height"

# Restart all services
ssh xai-testnet "sudo systemctl restart xai-mvp-node1 xai-mvp-node2 xai-sentry1 xai-sentry2"
ssh services-testnet "sudo systemctl restart xai-mvp-node3 xai-mvp-node4"

# View service logs
ssh xai-testnet "journalctl -u xai-mvp-node1 -f"
```

## Health Check

Run the health check script:
```bash
~/blockchain-projects/scripts/testnet-health-check.sh
```

Or quick health via API:
```bash
curl -s https://testnet-api.xaiblockchain.com/health | jq '.'
```

## Blockscout Explorer

The block explorer uses Blockscout with an EVM-compatible RPC adapter that connects to both sentry nodes with automatic failover.

### Check Explorer Health
```bash
# RPC adapter health (shows both sentry nodes)
curl -s https://testnet-explorer.xaiblockchain.com/rpc-health | jq '.'

# Detailed node status
curl -s https://testnet-explorer.xaiblockchain.com/rpc-nodes | jq '.'

# Blockscout API stats
curl -s https://testnet-explorer.xaiblockchain.com/api/v2/stats | jq '.'
```

### Manage Blockscout (SSH to xai-testnet)
```bash
# Check container status
ssh xai-testnet "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep blockscout"

# View Blockscout logs
ssh xai-testnet "cd ~/blockscout-adapter/deploy && docker compose -f docker-compose-blockscout.yml logs -f"

# Restart Blockscout stack
ssh xai-testnet "cd ~/blockscout-adapter/deploy && docker compose -f docker-compose-blockscout.yml restart"

# Restart RPC adapter
ssh xai-testnet "sudo systemctl restart xai-rpc-adapter"
```

### RPC Adapter Configuration
- **Nodes**: Sentry 1 (12570) + Sentry 2 (12571)
- **Strategy**: `fastest` (routes to fastest healthy node)
- **Health check interval**: 30 seconds
- **Service**: `xai-rpc-adapter.service`
