# XAI Testnet (xai-testnet-1)

Development network for the XAI blockchain - a Python-based proof-of-work chain focused on AI-powered trading systems.

## Chain Information

| Property | Value |
|----------|-------|
| Network | `xai-testnet-1` |
| Native Token | `XAI` |
| Address Prefix | `TXAI` (testnet) |
| Consensus | Proof of Work |
| Block Time | ~60 seconds |

## Public Artifacts

All artifacts available at: **https://artifacts.xaiblockchain.com**

| File | URL | Description |
|------|-----|-------------|
| config.json | [Download](https://artifacts.xaiblockchain.com/config.json) | Sample node configuration |
| peers.txt | [Download](https://artifacts.xaiblockchain.com/peers.txt) | P2P peer list |
| network_info.json | [Download](https://artifacts.xaiblockchain.com/network_info.json) | Network metadata |

## Public Endpoints

| Service | URL |
|---------|-----|
| JSON-RPC API | https://testnet-rpc.xaiblockchain.com |
| WebSocket | wss://testnet-ws.xaiblockchain.com |
| GraphQL | https://testnet-graphql.xaiblockchain.com |
| Explorer | https://testnet-explorer.xaiblockchain.com |
| Faucet | https://testnet-faucet.xaiblockchain.com |

## P2P Nodes

```
54.39.129.11:8333
139.99.149.160:8333
```

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/xai-blockchain/xai.git
cd xai
```

### 2. Install Dependencies

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. Configure for Testnet

```bash
cp .env.example .env
# Edit .env and set:
# XAI_NETWORK=testnet
# XAI_P2P_SEEDS=54.39.129.11:8333,139.99.149.160:8333
```

### 4. Start Node

```bash
python -m xai.node
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

## Get Testnet Tokens

Visit the faucet: https://testnet-faucet.xaiblockchain.com

## Become a Contributor

For node operator access or development contribution:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/xai-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - dev@xaiblockchain.com
3. **Discord** - [discord.gg/xai](https://discord.gg/xai)

## Resources

- [XAI Core Repository](https://github.com/xai-blockchain/xai)
- [Documentation](https://testnet-docs.xaiblockchain.com)
- [Block Explorer](https://testnet-explorer.xaiblockchain.com)
