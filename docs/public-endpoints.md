# XAI Testnet Public Endpoints

**Chain ID:** `xai-mvp-testnet-1`
**Last Updated:** 2026-01-14

## Primary Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| **RPC** | https://testnet-rpc.xaiblockchain.com | Native XAI JSON-RPC (load-balanced) |
| **REST API** | https://testnet-api.xaiblockchain.com | REST API (load-balanced) |
| **WebSocket** | wss://testnet-ws.xaiblockchain.com | Real-time block updates |
| **GraphQL** | https://testnet-graphql.xaiblockchain.com | GraphQL API & playground |
| **Explorer** | https://testnet-explorer.xaiblockchain.com | Blockscout block explorer |
| **Faucet** | https://testnet-faucet.xaiblockchain.com | Get test tokens |

## Blockscout Explorer Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| Explorer UI | https://testnet-explorer.xaiblockchain.com | Blockscout web interface |
| API v2 | https://testnet-explorer.xaiblockchain.com/api/v2/* | Blockscout REST API |
| RPC Health | https://testnet-explorer.xaiblockchain.com/rpc-health | RPC adapter health status |
| Node Status | https://testnet-explorer.xaiblockchain.com/rpc-nodes | Sentry node health details |

## Additional Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| **Docs** | https://testnet-docs.xaiblockchain.com | API documentation |
| **Archive** | https://testnet-archive.xaiblockchain.com | Archive node RPC |
| **Artifacts** | https://artifacts.xaiblockchain.com | Config files, snapshots |
| **Snapshots** | https://snapshots.xaiblockchain.com | Snapshot downloads |

## Direct P2P Connections

For direct peering (bypass load balancer):

| Sentry | IP | RPC Port | P2P Port |
|--------|-----|----------|----------|
| Sentry 1 | 54.39.129.11 | 12570 | 12371 |
| Sentry 2 | 54.39.129.11 | 12571 | 12372 |

## API Reference

### RPC Endpoints

```bash
# Chain stats
curl https://testnet-rpc.xaiblockchain.com/stats

# Health check
curl https://testnet-api.xaiblockchain.com/health

# Get balance
curl https://testnet-api.xaiblockchain.com/balance/xaitest1...

# Get block
curl https://testnet-rpc.xaiblockchain.com/blocks/100

# Latest block
curl https://testnet-rpc.xaiblockchain.com/block/latest

# Mempool
curl https://testnet-rpc.xaiblockchain.com/mempool

# Peers
curl https://testnet-rpc.xaiblockchain.com/peers
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
  -d '{"query": "{ latestBlock { index hash difficulty } }"}'

# Available queries: blocks, block, latestBlock, transaction, balance, networkStats, nodeInfo
```

### WebSocket

```javascript
const ws = new WebSocket('wss://testnet-ws.xaiblockchain.com');

ws.onopen = () => {
  console.log('Connected');
  ws.send(JSON.stringify({ type: 'subscribe', channel: 'blocks' }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Block:', data.current_block);
};
```

### Faucet

```bash
# Get test tokens (rate limited)
curl -X POST https://testnet-faucet.xaiblockchain.com/api/claim \
  -H "Content-Type: application/json" \
  -d '{"address": "xaitest1..."}'
```

Rate limits: 4-hour cooldown, max 2 requests per wallet/day, 5 per IP/day.

## Backend Configuration

| Service | Backend Port | Service Unit |
|---------|--------------|--------------|
| RPC/API | 12570, 12571 (sentries) | `xai-sentry1/2.service` |
| WebSocket | 8766 | `xai-websocket.service` |
| GraphQL | 8083 | `xai-graphql.service` |
| RPC Adapter | 8545 | `xai-rpc-adapter.service` |
| Blockscout Backend | 4000 | Docker: `blockscout-backend` |
| Blockscout Frontend | 3001 | Docker: `blockscout-frontend` |
| PostgreSQL | 5432 | Docker: `blockscout-postgres` |
| Faucet | 12081 | `xai-faucet.service` |

## Blockscout Explorer

The block explorer uses Blockscout with an EVM-compatible RPC adapter that connects to both sentry nodes with automatic failover.

### Architecture
```
Blockscout UI (3001) → Blockscout Backend (4000) → RPC Adapter (8545) → Sentry Nodes (12570/12571)
```

### Health Check
```bash
# Check RPC adapter health (shows both sentry nodes)
curl -s https://testnet-explorer.xaiblockchain.com/rpc-health | jq '.'

# Check Blockscout API
curl -s https://testnet-explorer.xaiblockchain.com/api/v2/stats | jq '.'
```

## Status

Check endpoint health:

```bash
# Quick check all endpoints
for url in \
  "https://testnet-rpc.xaiblockchain.com/stats" \
  "https://testnet-api.xaiblockchain.com/health" \
  "https://testnet-graphql.xaiblockchain.com/" \
  "https://testnet-explorer.xaiblockchain.com/" \
  "https://testnet-faucet.xaiblockchain.com/" \
  "https://artifacts.xaiblockchain.com/"
do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "$url: $code"
done
```

## Resources

- [XAI Documentation](https://github.com/xai-blockchain/xai)
- [Network Status](https://status.xaiblockchain.com)
