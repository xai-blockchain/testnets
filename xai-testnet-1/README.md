# XAI Testnet (xai-testnet-1)

Development network for the XAI blockchain - a Python-based proof-of-work chain focused on AI-powered trading systems.

## Chain Information

| Property | Value |
|----------|-------|
| Network | `xai-testnet-1` |
| Native Token | `XAI` |
| Address Prefix | `TXAI` (testnet) |
| Consensus | Proof of Work (SHA-256) |
| Block Time | ~60 seconds |
| Python Version | 3.10+ |

## Hardware Requirements

| Specification | Minimum | Recommended |
|---------------|---------|-------------|
| CPU | 2 cores | 4 cores |
| RAM | 4 GB | 8 GB |
| Disk | 50 GB SSD | 200 GB NVMe |
| Network | 50 Mbps | 100 Mbps |

## Software Requirements

| Software | Version |
|----------|---------|
| Python | 3.10 or higher |
| pip | 21.0+ |
| Git | 2.0+ |
| OpenSSL | 1.1.1+ |

## Pre-built Packages

Download pre-packaged distributions (recommended for quick setup):

| Platform | Download | Checksum |
|----------|----------|----------|
| Linux (pip wheel) | [xai-0.1.0-py3-none-any.whl](https://artifacts.xaiblockchain.com/dist/xai-0.1.0-py3-none-any.whl) | [SHA256](https://artifacts.xaiblockchain.com/dist/SHA256SUMS) |
| Docker Image | `docker pull ghcr.io/xai-blockchain/xai:testnet` | - |

```bash
# Option 1: Install via wheel
curl -L https://artifacts.xaiblockchain.com/dist/xai-0.1.0-py3-none-any.whl -o xai-0.1.0-py3-none-any.whl
pip install xai-0.1.0-py3-none-any.whl

# Option 2: Docker
docker pull ghcr.io/xai-blockchain/xai:testnet
docker run -d --name xai-node ghcr.io/xai-blockchain/xai:testnet
```

## Public Artifacts

All artifacts available at: **https://artifacts.xaiblockchain.com**

| File | URL | Description |
|------|-----|-------------|
| genesis.json | [Download](https://artifacts.xaiblockchain.com/genesis.json) | Genesis block |
| config.json | [Download](https://artifacts.xaiblockchain.com/config.json) | Sample node configuration |
| peers.txt | [Download](https://artifacts.xaiblockchain.com/peers.txt) | P2P peer list |
| seeds.txt | [Download](https://artifacts.xaiblockchain.com/seeds.txt) | Seed nodes |
| network_info.json | [Download](https://artifacts.xaiblockchain.com/network_info.json) | Network metadata |
| .env.example | [Download](https://artifacts.xaiblockchain.com/config/.env.example) | Example environment file |

## Snapshots

For faster sync, download a recent blockchain snapshot:

| Type | Size | Block Height | Download |
|------|------|--------------|----------|
| Full | ~10 GB | Updated daily | [Download](https://artifacts.xaiblockchain.com/snapshots/xai-testnet-1-latest.tar.lz4) |

```bash
# Download and extract snapshot
mkdir -p ~/.xai/data
curl -L https://artifacts.xaiblockchain.com/snapshots/xai-testnet-1-latest.tar.lz4 | lz4 -dc - | tar -xf - -C ~/.xai/data
```

## Public Endpoints

| Service | URL | Status |
|---------|-----|--------|
| JSON-RPC API | https://testnet-rpc.xaiblockchain.com | [Status](https://status.xaiblockchain.com) |
| WebSocket | wss://testnet-ws.xaiblockchain.com | - |
| GraphQL | https://testnet-graphql.xaiblockchain.com | [Playground](https://testnet-graphql.xaiblockchain.com/playground) |
| Explorer | https://testnet-explorer.xaiblockchain.com | - |
| Faucet | https://testnet-faucet.xaiblockchain.com | - |
| Status Page | https://status.xaiblockchain.com | - |

## API Documentation

- **JSON-RPC API**: https://testnet-docs.xaiblockchain.com/api/rpc
- **GraphQL Playground**: https://testnet-graphql.xaiblockchain.com/playground
- **WebSocket Events**: https://testnet-docs.xaiblockchain.com/api/websocket
- **OpenAPI Spec**: https://testnet-rpc.xaiblockchain.com/openapi.json

## P2P Nodes

```
54.39.129.11:8333
139.99.149.160:8333
```

## Quick Start

### Option A: Pre-built Package (Recommended)

```bash
# 1. Create virtual environment
python3 -m venv ~/.xai/venv
source ~/.xai/venv/bin/activate

# 2. Install package
pip install https://artifacts.xaiblockchain.com/dist/xai-0.1.0-py3-none-any.whl

# 3. Download configuration
mkdir -p ~/.xai/config
curl -o ~/.xai/config/.env https://artifacts.xaiblockchain.com/config/.env.example

# 4. Edit configuration
# Set XAI_NETWORK=testnet in ~/.xai/config/.env

# 5. Start node
xai-node --config ~/.xai/config/.env
```

### Option B: Build from Source

```bash
# 1. Verify Python version (3.10+ required)
python3 --version

# 2. Clone repository
git clone https://github.com/xai-blockchain/xai.git
cd xai
git checkout v0.1.0

# 3. Create virtual environment
python3 -m venv venv
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Configure for testnet
cp .env.example .env
# Edit .env and set:
# XAI_NETWORK=testnet
# XAI_P2P_SEEDS=54.39.129.11:8333,139.99.149.160:8333

# 6. Start node
python -m xai.node
```

### Docker Setup

```bash
# Pull and run
docker pull ghcr.io/xai-blockchain/xai:testnet
docker run -d \
  --name xai-node \
  -p 8333:8333 \
  -p 8545:8545 \
  -v ~/.xai:/root/.xai \
  ghcr.io/xai-blockchain/xai:testnet

# View logs
docker logs -f xai-node
```

## API Examples

### Get Chain Stats
```bash
curl https://testnet-rpc.xaiblockchain.com/stats
```

### Get Block by Height
```bash
curl https://testnet-rpc.xaiblockchain.com/block/100
```

### Get Transaction
```bash
curl https://testnet-rpc.xaiblockchain.com/transaction/<txid>
```

### Get Address Balance
```bash
curl https://testnet-rpc.xaiblockchain.com/address/<address>
```

### WebSocket Subscription
```javascript
const ws = new WebSocket('wss://testnet-ws.xaiblockchain.com');
ws.send(JSON.stringify({method: 'subscribe', params: ['newBlock']}));
```

## Get Testnet Tokens

Visit the faucet: https://testnet-faucet.xaiblockchain.com

## Network Status

Check current network status:

- **Status Page**: https://status.xaiblockchain.com
- **Current Block Height**: `curl -s https://testnet-rpc.xaiblockchain.com/stats | jq -r .chain_height`
- **Network Hash Rate**: `curl -s https://testnet-rpc.xaiblockchain.com/stats | jq -r .hash_rate`
- **Connected Peers**: `curl -s https://testnet-rpc.xaiblockchain.com/stats | jq -r .peer_count`

## Become a Contributor

For node operator access or development contribution:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/xai-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - dev@xaiblockchain.com
3. **Discord** - [discord.gg/xai](https://discord.gg/xai)

## Resources

- [XAI Core Repository](https://github.com/xai-blockchain/xai)
- [Documentation](https://testnet-docs.xaiblockchain.com)
- [Block Explorer](https://testnet-explorer.xaiblockchain.com)
- [API Documentation](https://testnet-docs.xaiblockchain.com/api)
- [GraphQL Playground](https://testnet-graphql.xaiblockchain.com/playground)
- [Status Page](https://status.xaiblockchain.com)
