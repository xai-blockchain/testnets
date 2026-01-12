# XAI Testnet-1

**Chain ID:** `xai-testnet-1`
**Status:** Active
**Version:** v0.2.0

## Quick Start

### One-Line Install (Recommended)

```bash
curl -sL https://raw.githubusercontent.com/xai-blockchain/xai/main/scripts/install-testnet.sh | bash
```

### Manual Installation

```bash
# Clone and setup
git clone https://github.com/xai-blockchain/xai.git
cd xai
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install -e .

# Start node (connects to testnet automatically)
python -m xai.core.node --port 8545 --p2p-port 8333 --peers https://testnet-rpc.xaiblockchain.com
```

## Public Endpoints

| Service | URL | Format |
|---------|-----|--------|
| RPC | https://testnet-rpc.xaiblockchain.com | JSON-RPC |
| REST API | https://testnet-api.xaiblockchain.com | REST |
| WebSocket | wss://testnet-ws.xaiblockchain.com | WebSocket |
| Explorer | https://testnet-explorer.xaiblockchain.com | Web |
| Faucet | https://testnet-faucet.xaiblockchain.com | Web |
| Metrics | https://testnet-rpc.xaiblockchain.com/metrics | Prometheus |
| Health | https://testnet-rpc.xaiblockchain.com/health | JSON |

## Network Information

| Parameter | Value |
|-----------|-------|
| Chain ID | `xai-testnet-1` |
| Native Token | XAI |
| Block Time | ~10 seconds |
| Consensus | Hybrid PoW + Validator Finality |
| Validators | 4 (quorum: 3, 67%) |
| Python Version | 3.10+ required |

## Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 cores | 4 cores |
| RAM | 4 GB | 8 GB |
| Storage | 50 GB SSD | 100 GB NVMe |
| Network | 25 Mbps | 50 Mbps |
| OS | Ubuntu 22.04 | Ubuntu 22.04 |

## Get Testnet Tokens

Visit the [XAI Testnet Faucet](https://testnet-faucet.xaiblockchain.com):
- **Amount**: 100 XAI per request
- **Cooldown**: 24 hours per address

## Joining Methods

### Method 1: One-Line Installer (Fastest)

```bash
curl -sL https://raw.githubusercontent.com/xai-blockchain/xai/main/scripts/install-testnet.sh | bash
```

This will:
- Install Python dependencies
- Clone the repository
- Download genesis file
- Configure systemd service
- Optionally download checkpoint for fast sync

### Method 2: Checkpoint Sync (~10 minutes)

```bash
# Stop node if running
sudo systemctl stop xai

# Download latest checkpoint
mkdir -p ~/xai/data
curl -sL https://artifacts.xaiblockchain.com/snapshots/latest.tar.gz | tar -xzf - -C ~/xai/data/

# Start node
sudo systemctl start xai
```

### Method 3: Full Sync (hours)

```bash
git clone https://github.com/xai-blockchain/xai.git ~/xai
cd ~/xai
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt && pip install -e .

# Download genesis
curl -sL https://raw.githubusercontent.com/xai-blockchain/testnets/main/xai-testnet-1/genesis.json > genesis.json

# Start syncing
python -m xai.core.node --port 8545 --p2p-port 8333 --peers https://testnet-rpc.xaiblockchain.com
```

## Peering

### Bootstrap Nodes

```
https://testnet-rpc.xaiblockchain.com
```

### Persistent Peers

See [peers.txt](./peers.txt) for the full peer list, or download:

```bash
curl -sL https://artifacts.xaiblockchain.com/peers.json
```

## Useful Commands

```bash
# Check sync status
curl -s http://localhost:8545/stats | jq

# Get latest block height
curl -s http://localhost:8545/stats | jq -r '.chain_height'

# Compare with public endpoint
curl -s https://testnet-rpc.xaiblockchain.com/stats | jq -r '.chain_height'

# Check peer count
curl -s http://localhost:8545/peers | jq '. | length'

# View logs (systemd)
sudo journalctl -u xai -f

# Restart node
sudo systemctl restart xai
```

## Configuration Files

| File | Purpose | Update Frequency |
|------|---------|------------------|
| [`genesis.json`](https://raw.githubusercontent.com/xai-blockchain/testnets/main/xai-testnet-1/genesis.json) | Genesis state | Never |
| [`peers.txt`](./peers.txt) | Peer addresses | Weekly |
| [`config.json`](./config.json) | Network config | As needed |
| [`validators.json`](./validators.json) | Validator info | As needed |
| [`endpoints.json`](./endpoints.json) | API endpoints | As needed |

## Artifacts CDN

Large files available at `https://artifacts.xaiblockchain.com/`:

| File | Purpose |
|------|---------|
| `genesis.json` | Genesis configuration |
| `peers.json` | Auto-updated peer list |
| `snapshots/latest.tar.gz` | Chain checkpoint |

## Troubleshooting

### Node won't start
- Check Python version: `python3 --version` (3.10+ required)
- Verify dependencies: `pip install -r requirements.txt`

### Sync stuck
- Check peers: `curl -s http://localhost:8545/peers | jq '. | length'`
- Add more peers from peers.txt
- Try checkpoint sync

### Connection refused
- Verify port 8545 is open: `sudo ufw allow 8545`
- Check node is running: `systemctl status xai`

## Resources

- [Full Documentation](https://github.com/xai-blockchain/xai/tree/main/docs)
- [Block Explorer](https://testnet-explorer.xaiblockchain.com)
- [Network Status](https://status.xaiblockchain.com)
- [Artifacts CDN](https://artifacts.xaiblockchain.com)
- [GitHub Issues](https://github.com/xai-blockchain/xai/issues)

## Advanced Setup

See [TESTNET_SETUP.md](./TESTNET_SETUP.md) for:
- Multi-node deployments
- Validator setup
- Mining configuration
- Systemd service files
