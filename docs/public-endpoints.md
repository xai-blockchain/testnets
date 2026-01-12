# XAI Public Endpoints

Comprehensive documentation for XAI testnet public endpoints.

## Chain Overview

| Property | Value |
|----------|-------|
| **Network** | XAI Testnet |
| **Chain ID** | xai-testnet-1 |
| **Version** | v0.1.0 |
| **Status** | Active |

## Public Endpoints

| Service | URL | Format |
|---------|-----|--------|
| RPC | https://testnet-rpc.xaiblockchain.com | JSON-RPC |
| REST API | https://testnet-api.xaiblockchain.com | REST |
| WebSocket | wss://testnet-ws.xaiblockchain.com | WebSocket |
| Prometheus Metrics | https://testnet-rpc.xaiblockchain.com/metrics | Prometheus |
| JSON Stats | https://testnet-rpc.xaiblockchain.com/stats | JSON |
| Health Check | https://testnet-rpc.xaiblockchain.com/health | JSON |
| Explorer | https://testnet-explorer.xaiblockchain.com | Web |
| Faucet | https://testnet-faucet.xaiblockchain.com | Web |

## Useful Commands

```bash
# Check sync status
curl -s https://testnet-rpc.xaiblockchain.com/stats | jq

# Get block height
curl -s https://testnet-rpc.xaiblockchain.com/stats | jq -r '.chain_height'

# Check health
curl -s https://testnet-rpc.xaiblockchain.com/health | jq

# View metrics
curl -s https://testnet-rpc.xaiblockchain.com/metrics
```

## Resources

- [XAI Documentation](https://github.com/xai-blockchain/xai)
- [Network Status](https://status.xaiblockchain.com)
