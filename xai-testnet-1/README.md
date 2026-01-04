# XAI Devnet (xai-testnet-1)

Development network for the XAI blockchain.

## Become a Contributor

This devnet is for developers interested in long-term contribution to the XAI project. We're building a team of committed contributors to help develop, test, and improve the network before public launch.

### How to Apply

Choose any of the following methods:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/xai-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - Contact dev@xaiblockchain.com with your background and interest
3. **Discord** - Join [discord.gg/xai](https://discord.gg/xai) and introduce yourself in #devnet-applications

### What We're Looking For

- Developers with blockchain, Python, or AI/ML experience
- Contributors interested in proof-of-work, UTXO models, or trading systems
- Long-term commitment to the project
- Node operators, miners, and SDK developers

## Chain Information

| Property | Value |
|----------|-------|
| Network | `testnet` |
| Native Token | `XAI` |
| Address Prefix | `TXAI` |
| Consensus | Proof of Work |

## Public Resources

These resources are publicly accessible:

| Resource | URL |
|----------|-----|
| Explorer | https://explorer.xaiblockchain.com |
| Artifacts | https://artifacts.xaiblockchain.com |
| Documentation | https://github.com/xai-blockchain/xai |

## Endpoints

| Service | URL |
|---------|-----|
| JSON-RPC API | http://54.39.129.11:8545 |
| P2P | 54.39.129.11:8333 |
| WebSocket | ws://54.39.129.11:8765 |

## API Endpoints

### Get chain stats
```bash
curl http://54.39.129.11:8545/stats
```

### Get block by height
```bash
curl http://54.39.129.11:8545/block/<height>
```

### Get transaction
```bash
curl http://54.39.129.11:8545/transaction/<txid>
```

### Get address balance
```bash
curl http://54.39.129.11:8545/address/<address>
```

## Quick Start (After Approval)

Once your access request is approved:

### 1. Clone repository

```bash
git clone https://github.com/xai-blockchain/xai.git
cd xai
```

### 2. Install dependencies

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. Configure for devnet

```bash
cp .env.example .env
# Edit .env and set XAI_NETWORK=testnet
```

### 4. Start node

```bash
python -m xai.node
```

### 5. Receive tokens

After approval, you'll receive devnet tokens to your provided wallet address.
