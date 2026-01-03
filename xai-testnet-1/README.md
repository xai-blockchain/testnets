# XAI Devnet (xai-testnet-1)

Development network for the XAI blockchain.

## Access

This devnet is currently limited to approved developers and contributors. To request access:

1. Review the [XAI documentation](https://github.com/xai-blockchain/xai)
2. Contact the XAI team to request devnet tokens

Artifacts and configs are publicly available. Token distribution requires approval.

## Chain Information

| Property | Value |
|----------|-------|
| Network | `testnet` |
| Native Token | `XAI` |
| Address Prefix | `TXAI` |
| Consensus | Proof of Work |

## Public Resources

| Resource | URL |
|----------|-----|
| Explorer | https://explorer.xaiblockchain.com |
| Artifacts | https://artifacts.xaiblockchain.com |

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

## Quick Start

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

### 5. Request tokens

Contact the XAI team after your node is synced to receive devnet tokens.
