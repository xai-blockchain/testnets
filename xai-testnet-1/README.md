# XAI Devnet (xai-testnet-1)

Development network for the XAI blockchain. Access is limited to approved developers and contributors.

## Chain Information

| Property | Value |
|----------|-------|
| Network | `testnet` |
| Native Token | `XAI` |
| Address Prefix | `TXAI` |
| Consensus | Proof of Work |

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

## Artifacts

Configuration files are available at:
https://artifacts.xaiblockchain.com

## Faucet

Contact the XAI team for devnet tokens.
