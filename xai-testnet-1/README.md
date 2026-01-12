# XAI Testnet-1

**Chain ID:** `xai-testnet-1`
**Status:** Active
**Version:** v0.1.0

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

## Network Information

| Parameter | Value |
|-----------|-------|
| Native Token | XAI |
| Block Time | ~10 seconds |
| Consensus | Proof-of-Work |
| Validators | 4 (quorum: 3) |
| Python Version | 3.10+ |

## Get Testnet Tokens

Visit the [XAI Testnet Faucet](https://testnet-faucet.xaiblockchain.com) to claim 100 XAI tokens (24-hour cooldown).

## Peering

### Bootstrap Nodes

```
seed@testnet-rpc.xaiblockchain.com:8333
```

### Persistent Peers

See [peers.txt](./peers.txt) for the full peer list.

## Useful Commands

```bash
# Check sync status
curl -s https://testnet-rpc.xaiblockchain.com/stats | jq

# Get latest block height
curl -s https://testnet-rpc.xaiblockchain.com/stats | jq -r '.chain_height'

# Check health
curl -s https://testnet-rpc.xaiblockchain.com/health | jq

# View Prometheus metrics
curl -s https://testnet-rpc.xaiblockchain.com/metrics

# List connected peers
curl -s https://testnet-rpc.xaiblockchain.com/peers | jq
```

## Configuration Files

- [`config.json`](./config.json) - Network configuration
- [`network_info.json`](./network_info.json) - Detailed network metadata
- [`endpoints.json`](./endpoints.json) - Machine-readable endpoints
- [`peers.txt`](./peers.txt) - Peer addresses
- [`validators.json`](./validators.json) - Validator information

## Setup Guide

See [TESTNET_SETUP.md](./TESTNET_SETUP.md) for detailed node setup instructions.

## Resources

- [XAI Documentation](https://github.com/xai-blockchain/xai)
- [Block Explorer](https://testnet-explorer.xaiblockchain.com)
- [Artifacts CDN](https://artifacts.xaiblockchain.com)
- [Network Status](https://status.xaiblockchain.com)
