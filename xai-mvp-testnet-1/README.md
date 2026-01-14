# XAI MVP Testnet

**Chain ID:** `xai-mvp-testnet-1`
**Version:** 1.0.0-mvp
**Genesis Time:** 2026-01-13T00:00:00Z

## Network Overview

| Property | Value |
|----------|-------|
| Chain ID | `xai-mvp-testnet-1` |
| Consensus | Hybrid PoI + BFT (67% quorum) |
| Validators | 4 (2 miners + 2 validator-only) |
| Block Time | ~10 seconds target |
| Difficulty | 4 (capped via XAI_FAST_MINING) |

## Network Architecture

The XAI MVP Testnet uses a **sentry node architecture** for DDoS protection. All external traffic routes through sentry nodes—validators are hidden behind VPN.

```
                    PUBLIC INTERNET
                          │
                   ┌──────┴──────┐
                   │   NGINX LB  │
                   │  Cloudflare │
                   └──────┬──────┘
                          │
            ┌─────────────┴─────────────┐
            │      SENTRY NODES         │
            │   (Public DDoS Shield)    │
            │  sentry1 RPC:12570 P2P:12371  │
            │  sentry2 RPC:12571 P2P:12372  │
            └─────────────┬─────────────┘
                          │ WireGuard VPN (10.10.0.x)
            ┌─────────────┴─────────────┐
            │     VALIDATOR NODES       │
            │   (Private, Protected)    │
            │  node1-4 (mining/voting)  │
            └───────────────────────────┘
```

### Node Configuration

| Node | Server | Role | RPC | P2P | Mining | Service |
|------|--------|------|-----|-----|--------|---------|
| **Sentries** ||||||
| Sentry 1 | xai-testnet | Public Gateway | 12570 | 12371 | No | `xai-sentry1.service` |
| Sentry 2 | xai-testnet | Public Gateway | 12571 | 12372 | No | `xai-sentry2.service` |
| **Validators** ||||||
| Node 1 | xai-testnet (10.10.0.3) | Miner+Validator | 12545 | 12333 | Yes | `xai-mvp-node1.service` |
| Node 2 | xai-testnet (10.10.0.3) | Miner+Validator | 12555 | 12334 | Yes | `xai-mvp-node2.service` |
| Node 3 | services-testnet (10.10.0.4) | Validator Only | 12546 | 12335 | No | `xai-mvp-node3.service` |
| Node 4 | services-testnet (10.10.0.4) | Validator Only | 12556 | 12336 | No | `xai-mvp-node4.service` |

### Supporting Services

| Service | Port | Server | Description | Service Unit |
|---------|------|--------|-------------|--------------|
| **Blockscout Explorer** |||||
| RPC Adapter | 8545 | xai-testnet | EVM JSON-RPC (dual sentry failover) | `xai-rpc-adapter.service` |
| Blockscout Backend | 4000 | xai-testnet | Block indexer (Elixir/OTP) | Docker: `blockscout-backend` |
| Blockscout Frontend | 3001 | xai-testnet | Explorer UI (Next.js) | Docker: `blockscout-frontend` |
| PostgreSQL | 5432 | xai-testnet | Indexed chain data | Docker: `blockscout-postgres` |
| **Other Services** |||||
| Faucet | 12081 | xai-testnet | Testnet token faucet | `xai-faucet.service` |
| WebSocket | 8766 | xai-testnet | Real-time block updates | `xai-websocket.service` |
| GraphQL | 8083 | xai-testnet | GraphQL API | `xai-graphql.service` |
| Metrics | 8767 | xai-testnet | Prometheus metrics (WS) | Part of websocket |

## Public Endpoints

All endpoints use HTTPS with Cloudflare SSL and nginx load balancing.

| Service | URL | Backend | Description |
|---------|-----|---------|-------------|
| **RPC** | https://testnet-rpc.xaiblockchain.com | Sentries (round-robin) | Native XAI JSON-RPC API |
| **REST API** | https://testnet-api.xaiblockchain.com | Sentries (round-robin) | REST API |
| **WebSocket** | wss://testnet-ws.xaiblockchain.com | Port 8766 | Real-time updates |
| **GraphQL** | https://testnet-graphql.xaiblockchain.com | Port 8083 | GraphQL playground |
| **Explorer** | https://testnet-explorer.xaiblockchain.com | Blockscout (port 3001) | Blockscout block explorer |
| **Explorer API** | https://testnet-explorer.xaiblockchain.com/api/v2/* | Port 4000 | Blockscout REST API |
| **RPC Health** | https://testnet-explorer.xaiblockchain.com/rpc-health | Port 8545 | RPC adapter health |
| **Faucet** | https://testnet-faucet.xaiblockchain.com | Port 12081 | Get test tokens |
| **Docs** | https://testnet-docs.xaiblockchain.com | Static | API documentation |
| **Archive** | https://testnet-archive.xaiblockchain.com | Sentries | Full node RPC |
| **Artifacts** | https://artifacts.xaiblockchain.com | R2 bucket | Config files, snapshots |

## Connecting to the Network

### Option 1: HTTP RPC (Recommended)

```bash
# Clone and setup
git clone https://github.com/xai-blockchain/xai.git
cd xai
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# Run full node (sync only)
python -m xai.core.node \
  --peers https://testnet-rpc.xaiblockchain.com \
  --data-dir ~/.xai-testnet \
  --no-mining
```

### Option 2: Direct P2P Connection

Connect directly to sentry P2P ports for persistent peering:

```bash
python -m xai.core.node \
  --peers http://54.39.129.11:12570 http://54.39.129.11:12571 \
  --data-dir ~/.xai-testnet \
  --no-mining
```

### Required Environment Variables

```bash
export XAI_FAST_MINING=1              # Cap difficulty at 4 (required)
export XAI_ALLOW_EMPTY_MINING=true    # Allow heartbeat blocks
export XAI_FINALITY_ENABLED=true      # Enable BFT finality
export XAI_CHAIN_ID=xai-mvp-testnet-1
```

## Running a Validator

To run a validator node, you must:

1. **Request validator status** - Contact team via Discord or GitHub issue
2. **Run your own sentry nodes** - Validators must be behind sentries
3. **Configure private peering** - Use `--pex-disabled` flag

### Sentry Node Setup (Your Infrastructure)

```bash
# Your public-facing sentry
python -m xai.core.node \
  --sentry-mode \
  --private-peers YOUR_VALIDATOR_IP:PORT \
  --peers http://54.39.129.11:12570 http://54.39.129.11:12571 \
  --port 8545 \
  --p2p-port 26656 \
  --data-dir ~/xai-sentry
```

### Validator Node Setup (Behind Sentry)

```bash
# Your hidden validator
python -m xai.core.node \
  --pex-disabled \
  --peers http://YOUR_SENTRY:8545 \
  --miner YOUR_VALIDATOR_ADDRESS \
  --port 8546 \
  --data-dir ~/xai-validator
```

## API Reference

### RPC Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/stats` | GET | Chain statistics |
| `/health` | GET | Node health check |
| `/blocks` | GET | List blocks (paginated) |
| `/blocks/<index>` | GET | Get block by height |
| `/block/latest` | GET | Get latest block |
| `/transaction/<txid>` | GET | Get transaction |
| `/balance/<address>` | GET | Get address balance |
| `/mempool` | GET | Pending transactions |
| `/peers` | GET | Connected peers |
| `/send` | POST | Submit transaction |

### Faucet

Get testnet tokens (rate limited: 4-hour cooldown, max 2 per wallet/day):

```bash
# Via API
curl -X POST https://testnet-faucet.xaiblockchain.com/api/claim \
  -H "Content-Type: application/json" \
  -d '{"address": "xaitest1..."}'

# Or visit the web UI
open https://testnet-faucet.xaiblockchain.com
```

### GraphQL

```bash
# Introspect schema
curl -X POST https://testnet-graphql.xaiblockchain.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __schema { queryType { fields { name } } } }"}'

# Get latest block
curl -X POST https://testnet-graphql.xaiblockchain.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ latestBlock { index hash difficulty timestamp } }"}'
```

### WebSocket

```javascript
const ws = new WebSocket('wss://testnet-ws.xaiblockchain.com');
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('New block:', data);
};
```

## Genesis Configuration

```json
{
  "chain_id": "xai-mvp-testnet-1",
  "genesis_time": "2026-01-13T00:00:00Z",
  "validators": 4,
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
```

## Module Status

| Module | Status | Notes |
|--------|--------|-------|
| blockchain | **Enabled** | Core chain functionality |
| consensus | **Enabled** | Hybrid PoI + BFT |
| transactions | **Enabled** | UTXO model |
| mining | **Enabled** | Proof of Intelligence |
| p2p | **Enabled** | Gossip protocol |
| security | **Enabled** | Sentry architecture |
| wallets | **Enabled** | HD wallets |
| api | **Enabled** | REST/RPC/GraphQL/WS |
| ai | Disabled | Post-MVP |
| governance | Disabled | Post-MVP |
| defi | Disabled | Post-MVP |
| vm | Disabled | Post-MVP |

## Health Check

```bash
# Quick height check
curl -s https://testnet-rpc.xaiblockchain.com/stats | jq '.chain_height'

# Full health
curl -s https://testnet-api.xaiblockchain.com/health | jq '.'

# WebSocket test
python3 -c "
import asyncio, websockets, json
async def test():
    async with websockets.connect('wss://testnet-ws.xaiblockchain.com/') as ws:
        msg = await ws.recv()
        print(json.loads(msg))
asyncio.run(test())
"
```

## Support

- **GitHub Issues**: https://github.com/xai-blockchain/xai/issues
- **Discord**: XAI Blockchain • Official
- **Documentation**: https://docs.xaiblockchain.com
- **Email**: dev@xaiblockchain.com
