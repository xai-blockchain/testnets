# XAI Testnet Setup Checklist

**Chain ID**: `xai-testnet-1`
**Nodes**: 4 (staged deployment)
**Port Range**: 12000-12999
**Consensus**: Hybrid PoI Mining + Validator Finality (2/3 quorum)

## Server Allocation

| Node | Server | VPN IP | Role | Ports |
|------|--------|--------|------|-------|
| node1 | xai-testnet | 10.10.0.3 | Miner + Validator | RPC:12545, P2P:12333, WS:12765, Metrics:12000 |
| node2 | xai-testnet | 10.10.0.3 | Miner + Validator | RPC:12555, P2P:12334, WS:12766, Metrics:12001 |
| node3 | services-testnet | 10.10.0.4 | Validator only | RPC:12546, P2P:12335, WS:12767, Metrics:12002 |
| node4 | services-testnet | 10.10.0.4 | Validator only | RPC:12556, P2P:12336, WS:12768, Metrics:12003 |

## Phase 1: Genesis Creation (Local)

```bash
# On bcpc (local machine)
cd ~/blockchain-projects/xai

# Create virtual environment if needed
python -m venv venv
source venv/bin/activate
pip install -e .

# Create data directories for 4 nodes
for i in 1 2 3 4; do
  mkdir -p ~/.xai-node${i}/data
  mkdir -p ~/.xai-node${i}/config
  mkdir -p ~/.xai-node${i}/wallets
done

# Generate validator keys for each node
for i in 1 2 3 4; do
  python -m xai.cli wallet create --output ~/.xai-node${i}/wallets/validator.json
done

# Record validator set (track in testnet repo)
# Save to: xai-testnets/xai-testnet-1/validators.json
# Then copy to each node at: /home/ubuntu/xai/config/validators.json
# (or set XAI_VALIDATOR_SET_PATH to point to it).

# Extract validator addresses and public keys
VAL1_ADDR=$(jq -r '.address' ~/.xai-node1/wallets/validator.json)
VAL2_ADDR=$(jq -r '.address' ~/.xai-node2/wallets/validator.json)
VAL3_ADDR=$(jq -r '.address' ~/.xai-node3/wallets/validator.json)
VAL4_ADDR=$(jq -r '.address' ~/.xai-node4/wallets/validator.json)

VAL1_PUBKEY=$(jq -r '.public_key' ~/.xai-node1/wallets/validator.json)
VAL2_PUBKEY=$(jq -r '.public_key' ~/.xai-node2/wallets/validator.json)
VAL3_PUBKEY=$(jq -r '.public_key' ~/.xai-node3/wallets/validator.json)
VAL4_PUBKEY=$(jq -r '.public_key' ~/.xai-node4/wallets/validator.json)

# Create genesis.json with 4 validators (equal voting power)
cat > genesis.json << EOF
{
  "chain_id": "xai-testnet-1",
  "genesis_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "initial_height": 0,
  "validators": [
    {"address": "${VAL1_ADDR}", "public_key": "${VAL1_PUBKEY}", "voting_power": 25, "name": "validator-1"},
    {"address": "${VAL2_ADDR}", "public_key": "${VAL2_PUBKEY}", "voting_power": 25, "name": "validator-2"},
    {"address": "${VAL3_ADDR}", "public_key": "${VAL3_PUBKEY}", "voting_power": 25, "name": "validator-3"},
    {"address": "${VAL4_ADDR}", "public_key": "${VAL4_PUBKEY}", "voting_power": 25, "name": "validator-4"}
  ],
  "accounts": [
    {"address": "${VAL1_ADDR}", "balance": 1000000000000},
    {"address": "${VAL2_ADDR}", "balance": 1000000000000},
    {"address": "${VAL3_ADDR}", "balance": 1000000000000},
    {"address": "${VAL4_ADDR}", "balance": 1000000000000}
  ],
  "consensus": {
    "quorum_threshold": 0.667,
    "finality_delay_blocks": 1
  },
  "mining": {
    "difficulty": 1,
    "target_block_time": 10,
    "reward": 50
  }
}
EOF

# Copy genesis to all node directories
for i in 1 2 3 4; do
  cp genesis.json ~/.xai-node${i}/config/
done
```

## Phase 2: Deploy Nodes 1 & 2 (xai-testnet)

### 2.1 Copy Files to Server
```bash
# Copy source code and configs
rsync -avz ~/blockchain-projects/xai/ xai-testnet:~/xai/
scp ~/.xai-node1/config/genesis.json xai-testnet:~/xai-node1/config/
scp ~/.xai-node1/wallets/validator.json xai-testnet:~/xai-node1/wallets/
scp ~/.xai-node2/wallets/validator.json xai-testnet:~/xai-node2/wallets/
```

### 2.2 Setup Python Environment (xai-testnet)
```bash
ssh xai-testnet

# Create venv and install
cd ~/xai
python3 -m venv venv
source venv/bin/activate
pip install -e .

# Create node directories
mkdir -p ~/xai-node1/{data,config,wallets,logs}
mkdir -p ~/xai-node2/{data,config,wallets,logs}
```

### 2.3 Create Node 1 Config
```bash
cat > ~/xai-node1/config/node.yaml << EOF
node:
  name: "validator-1"
  data_dir: "/home/ubuntu/xai-node1/data"

network:
  host: "0.0.0.0"
  api_port: 12545
  p2p_port: 12333
  ws_port: 12765
  metrics_port: 12000

mining:
  enabled: true
  miner_address: "$(jq -r '.address' ~/xai-node1/wallets/validator.json)"
  allow_empty_blocks: true
  heartbeat_seconds: 10

validator:
  enabled: true
  key_file: "/home/ubuntu/xai-node1/wallets/validator.json"

peers:
  persistent: []

logging:
  level: "INFO"
  file: "/home/ubuntu/xai-node1/logs/node.log"
EOF
```

### 2.4 Create Node 2 Config
```bash
cat > ~/xai-node2/config/node.yaml << EOF
node:
  name: "validator-2"
  data_dir: "/home/ubuntu/xai-node2/data"

network:
  host: "0.0.0.0"
  api_port: 12555
  p2p_port: 12334
  ws_port: 12766
  metrics_port: 12001

mining:
  enabled: true
  miner_address: "$(jq -r '.address' ~/xai-node2/wallets/validator.json)"
  allow_empty_blocks: true
  heartbeat_seconds: 10

validator:
  enabled: true
  key_file: "/home/ubuntu/xai-node2/wallets/validator.json"

peers:
  persistent:
    - "127.0.0.1:12333"

logging:
  level: "INFO"
  file: "/home/ubuntu/xai-node2/logs/node.log"
EOF

# Update node1 with node2 peer
sed -i 's/persistent: \[\]/persistent:\n    - "127.0.0.1:12334"/' ~/xai-node1/config/node.yaml
```

### 2.5 Start Nodes 1 & 2
```bash
source ~/xai/venv/bin/activate

# Start node1
XAI_CONFIG=~/xai-node1/config/node.yaml \
XAI_DATA_DIR=~/xai-node1/data \
nohup python -m xai.core.node \
  --port 12545 \
  --p2p-port 12333 \
  --miner $(jq -r '.address' ~/xai-node1/wallets/validator.json) \
  --data-dir ~/xai-node1/data \
  > ~/xai-node1/logs/node.log 2>&1 &

sleep 10

# Start node2
XAI_CONFIG=~/xai-node2/config/node.yaml \
XAI_DATA_DIR=~/xai-node2/data \
nohup python -m xai.core.node \
  --port 12555 \
  --p2p-port 12334 \
  --miner $(jq -r '.address' ~/xai-node2/wallets/validator.json) \
  --data-dir ~/xai-node2/data \
  --peers http://127.0.0.1:12545 \
  > ~/xai-node2/logs/node.log 2>&1 &
```

### 2.6 CHECKPOINT: Verify 2-Node Consensus
```bash
# Wait for blocks
sleep 30

# Check block height on node1
curl -s http://127.0.0.1:12545/stats | jq '.chain_height'

# Check block height on node2
curl -s http://127.0.0.1:12555/stats | jq '.chain_height'

# Check peer connections
curl -s http://127.0.0.1:12545/peers | jq '.connected_peers'

# Check finality status (should show 2 validators)
curl -s http://127.0.0.1:12545/finality/status | jq '.'

# Verify blocks are being finalized
curl -s http://127.0.0.1:12545/finality/certificates | jq '. | length'

# MUST SEE: Blocks advancing, 2 nodes connected, finality certificates being issued
# With 2/4 validators (50%), blocks mine but may not finalize until 3rd validator joins
# If nodes not syncing, DO NOT proceed to Phase 3
```

## Phase 3: Add Node 3 (services-testnet)

### 3.1 Copy Files to Server
```bash
# From bcpc
rsync -avz ~/blockchain-projects/xai/ services-testnet:~/xai/
scp ~/.xai-node1/config/genesis.json services-testnet:~/xai-node3/config/
scp ~/.xai-node3/wallets/validator.json services-testnet:~/xai-node3/wallets/
```

### 3.2 Setup Python Environment (services-testnet)
```bash
ssh services-testnet

cd ~/xai
python3 -m venv venv
source venv/bin/activate
pip install -e .

mkdir -p ~/xai-node3/{data,config,wallets,logs}
mkdir -p ~/xai-node4/{data,config,wallets,logs}
```

### 3.3 Create Node 3 Config (Validator-only, no mining)
```bash
cat > ~/xai-node3/config/node.yaml << EOF
node:
  name: "validator-3"
  data_dir: "/home/ubuntu/xai-node3/data"

network:
  host: "0.0.0.0"
  api_port: 12546
  p2p_port: 12335
  ws_port: 12767
  metrics_port: 12002

mining:
  enabled: false

validator:
  enabled: true
  key_file: "/home/ubuntu/xai-node3/wallets/validator.json"

peers:
  persistent:
    - "10.10.0.3:12333"
    - "10.10.0.3:12334"

logging:
  level: "INFO"
  file: "/home/ubuntu/xai-node3/logs/node.log"
EOF
```

### 3.4 Start Node 3
```bash
source ~/xai/venv/bin/activate

XAI_MINING_ENABLED=false \
nohup python -m xai.core.node \
  --port 12546 \
  --p2p-port 12335 \
  --no-mining \
  --data-dir ~/xai-node3/data \
  --peers http://10.10.0.3:12545 http://10.10.0.3:12555 \
  > ~/xai-node3/logs/node.log 2>&1 &
```

### 3.5 Update Nodes 1 & 2 with Node 3 Peer
```bash
# On xai-testnet
ssh xai-testnet

# Add node3 peer to node1 and node2 configs, then restart or use API
curl -X POST http://127.0.0.1:12545/peers/add -d '{"peer": "10.10.0.4:12335"}'
curl -X POST http://127.0.0.1:12555/peers/add -d '{"peer": "10.10.0.4:12335"}'
```

### 3.6 CHECKPOINT: Verify 3-Node Consensus with Finality
```bash
# Wait for sync
sleep 60

# Check all 3 nodes
curl -s http://10.10.0.3:12545/stats | jq '{height: .chain_height, peers: .peer_count}'
curl -s http://10.10.0.3:12555/stats | jq '{height: .chain_height, peers: .peer_count}'
curl -s http://10.10.0.4:12546/stats | jq '{height: .chain_height, peers: .peer_count}'

# Check finality - WITH 3 VALIDATORS, QUORUM IS REACHED (75% > 67%)
curl -s http://10.10.0.3:12545/finality/status | jq '.'
# Should show: quorum_power achieved, blocks being finalized

# Verify finality certificates are being issued
curl -s http://10.10.0.3:12545/finality/certificates | jq '. | length'
# Should be > 0 and growing

# MUST SEE: 3 nodes synced, finality certificates being issued
# If finality not working, DO NOT proceed to Phase 4
```

## Phase 4: Add Node 4 (services-testnet)

### 4.1 Copy Files
```bash
scp ~/.xai-node4/wallets/validator.json services-testnet:~/xai-node4/wallets/
scp ~/.xai-node1/config/genesis.json services-testnet:~/xai-node4/config/
```

### 4.2 Create Node 4 Config (Validator-only, no mining)
```bash
ssh services-testnet

cat > ~/xai-node4/config/node.yaml << EOF
node:
  name: "validator-4"
  data_dir: "/home/ubuntu/xai-node4/data"

network:
  host: "0.0.0.0"
  api_port: 12556
  p2p_port: 12336
  ws_port: 12768
  metrics_port: 12003

mining:
  enabled: false

validator:
  enabled: true
  key_file: "/home/ubuntu/xai-node4/wallets/validator.json"

peers:
  persistent:
    - "10.10.0.3:12333"
    - "127.0.0.1:12335"

logging:
  level: "INFO"
  file: "/home/ubuntu/xai-node4/logs/node.log"
EOF
```

### 4.3 Start Node 4
```bash
source ~/xai/venv/bin/activate

XAI_MINING_ENABLED=false \
nohup python -m xai.core.node \
  --port 12556 \
  --p2p-port 12336 \
  --no-mining \
  --data-dir ~/xai-node4/data \
  --peers http://10.10.0.3:12545 http://127.0.0.1:12546 \
  > ~/xai-node4/logs/node.log 2>&1 &
```

### 4.4 Update All Nodes with Node 4 Peer
```bash
# Add node4 to peer lists via API
curl -X POST http://10.10.0.3:12545/peers/add -d '{"peer": "10.10.0.4:12336"}'
curl -X POST http://10.10.0.3:12555/peers/add -d '{"peer": "10.10.0.4:12336"}'
curl -X POST http://10.10.0.4:12546/peers/add -d '{"peer": "127.0.0.1:12336"}'
```

### 4.5 FINAL CHECKPOINT: Verify 4-Node Consensus
```bash
# Wait for sync
sleep 60

# Check all 4 nodes synced
for host_port in "10.10.0.3:12545" "10.10.0.3:12555" "10.10.0.4:12546" "10.10.0.4:12556"; do
  echo "$host_port: $(curl -s http://$host_port/stats | jq -r '.chain_height')"
done

# Check finality status - all 4 validators participating
curl -s http://10.10.0.3:12545/finality/status | jq '.'
# Should show: total_validators: 4, quorum_power reached

# Verify validator voting
curl -s http://10.10.0.3:12545/finality/validators | jq '.[] | {address: .address, voting_power: .voting_power}'

# Check recent finality certificates have all 4 signatures
curl -s http://10.10.0.3:12545/finality/certificates?limit=5 | jq '.[0].signatures | length'
# Should be 3 or 4 (quorum requires 3)

# Verify mining is working (only nodes 1 & 2 mine)
curl -s http://10.10.0.3:12545/mining/stats | jq '.'
curl -s http://10.10.0.3:12555/mining/stats | jq '.'

# Target: 95%+ finality rate (most blocks get 3-4 validator signatures)
```

## Phase 5: Deploy Supporting Services

After 4-node consensus is stable:

```bash
# On xai-testnet (primary services)
# Explorer: 12080, Faucet: 12081, Indexer: 12084, GraphQL: 12400

# On services-testnet (backup/indexer)
# Indexer API: 12103, WS Proxy: 12203
```

## Health Check Commands

```bash
# Quick status
curl -s http://10.10.0.3:12545/stats | jq '{height: .chain_height, peers: .peer_count, mining: .is_mining}'

# Finality status
curl -s http://10.10.0.3:12545/finality/status | jq '{finalized_height: .highest_finalized_height, validators: .total_validators, quorum: .quorum_power}'

# All nodes height comparison
for hp in "10.10.0.3:12545" "10.10.0.3:12555" "10.10.0.4:12546" "10.10.0.4:12556"; do
  echo "$hp: $(curl -s http://$hp/stats 2>/dev/null | jq -r '.chain_height // "offline"')"
done

# Mining activity (only on miner nodes)
curl -s http://10.10.0.3:12545/mining/stats | jq '{blocks_mined: .mined_blocks_counter, last_mine_time: .last_mining_time}'
```

## Systemd Service Files

### Node 1 (xai-testnet - miner+validator)
```bash
cat > /etc/systemd/system/xai-node1.service << EOF
[Unit]
Description=XAI Node 1 (Miner+Validator)
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/xai
Environment=XAI_API_PORT=12545
Environment=XAI_MINING_ENABLED=true
ExecStart=/home/ubuntu/xai/venv/bin/python -m xai.core.node \
  --port 12545 --p2p-port 12333 \
  --miner $(jq -r '.address' /home/ubuntu/xai-node1/wallets/validator.json) \
  --data-dir /home/ubuntu/xai-node1/data
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

### Node 3 (services-testnet - validator only)
```bash
cat > /etc/systemd/system/xai-node3.service << EOF
[Unit]
Description=XAI Node 3 (Validator Only)
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/xai
Environment=XAI_API_PORT=12546
Environment=XAI_MINING_ENABLED=false
ExecStart=/home/ubuntu/xai/venv/bin/python -m xai.core.node \
  --port 12546 --p2p-port 12335 \
  --no-mining \
  --data-dir /home/ubuntu/xai-node3/data \
  --peers http://10.10.0.3:12545 http://10.10.0.3:12555
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

## Rollback Procedure

If consensus fails at any phase:
1. Stop all nodes: `pkill -f "python -m xai"`
2. Check logs: `tail -100 ~/xai-nodeX/logs/node.log`
3. Reset data if needed: `rm -rf ~/xai-nodeX/data/*`
4. Restart from last working phase

## Key Differences from Cosmos SDK Testnets

| Aspect | Cosmos SDK Chains | XAI (Python) |
|--------|-------------------|--------------|
| Consensus | CometBFT (pure BFT) | Hybrid PoI + Validator Finality |
| Block Production | All validators | Only miners (nodes 1 & 2) |
| Finality | Immediate | After 2/3 validator signatures |
| Config Format | TOML | YAML |
| Binary | Single Go binary | Python + venv |
| Node Roles | All validators equal | Miners vs Validator-only |
