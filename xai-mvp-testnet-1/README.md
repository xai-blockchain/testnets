# XAI MVP Testnet

**Chain ID:** `xai-mvp-testnet-1`
**Version:** 1.0.0-mvp

## Network Architecture

The XAI MVP Testnet uses a **sentry node architecture** for DDoS protection. External nodes should connect to sentries, not directly to validators.

```
                    PUBLIC INTERNET
                          │
            ┌─────────────┴─────────────┐
            │      SENTRY NODES         │
            │  (Public DDoS Shield)     │
            │  sentry1 :12371 (P2P)     │
            │  sentry2 :12372 (P2P)     │
            └─────────────┬─────────────┘
                          │ VPN (10.10.0.x)
            ┌─────────────┴─────────────┐
            │    VALIDATOR NODES        │
            │  (Private, Protected)     │
            │  validator1-4             │
            └───────────────────────────┘
```

### Node Table

| Node | Server | Role | RPC | P2P | Public |
|------|--------|------|-----|-----|--------|
| Sentry 1 | xai-testnet | Sentry | 12570 | 12371 | Yes |
| Sentry 2 | xai-testnet | Sentry | 12571 | 12372 | Yes |
| Validator 1 | xai-testnet (10.10.0.3) | Miner | 12545 | 12333 | No (VPN) |
| Validator 2 | xai-testnet (10.10.0.3) | Miner | 12555 | 12334 | No (VPN) |
| Validator 3 | services-testnet (10.10.0.4) | Validator | 12546 | 12335 | No (VPN) |
| Validator 4 | services-testnet (10.10.0.4) | Validator | 12556 | 12336 | No (VPN) |

## Connecting to the Network

### External Nodes (Recommended)

Connect to sentry nodes for public access:

```bash
python -m xai.core.node \
  --peers http://54.39.129.11:12570 http://54.39.129.11:12571 \
  --data-dir ~/.xai-mvp
```

Or use public DNS:
```bash
python -m xai.core.node \
  --peers https://testnet-rpc.xaiblockchain.com \
  --data-dir ~/.xai-mvp
```

### P2P Peers (for persistent connections)

Add to your node config or use `--peers`:
```
sentry-1@54.39.129.11:12371
sentry-2@54.39.129.11:12372
```

## Public Endpoints

| Service | URL | Backend |
|---------|-----|---------|
| RPC | https://testnet-rpc.xaiblockchain.com | Sentries (load-balanced) |
| API | https://testnet-api.xaiblockchain.com | Sentries (load-balanced) |
| WebSocket | wss://testnet-ws.xaiblockchain.com | Sentry 1 |
| Explorer | https://testnet-explorer.xaiblockchain.com | Sentry 1 |
| Faucet | https://testnet-faucet.xaiblockchain.com | Direct |

## Running Your Own Node

### Full Node (sync only)

```bash
# Clone and install
git clone https://github.com/xai-blockchain/xai.git
cd xai
pip install -r requirements.txt

# Run full node (connects to sentries)
python -m xai.core.node \
  --network mvp-testnet \
  --peers http://54.39.129.11:12570 http://54.39.129.11:12571 \
  --data-dir ~/.xai-mvp \
  --no-mining
```

### Validator Node (requires approval)

To run a validator, you need:
1. Stake XAI tokens (contact team for testnet allocation)
2. Run behind your own sentry nodes
3. Use `--pex-disabled` to only connect to your sentries

```bash
# Your sentry node (public-facing)
python -m xai.core.node \
  --sentry-mode \
  --private-peers YOUR_VALIDATOR_IP:PORT \
  --peers http://54.39.129.11:12570

# Your validator node (hidden behind sentry)
python -m xai.core.node \
  --pex-disabled \
  --peers http://YOUR_SENTRY:PORT \
  --mining
```

## Configuration

### Fast Mining (Required for all nodes)

```bash
export XAI_FAST_MINING=1               # Cap difficulty at 4
export XAI_ALLOW_EMPTY_MINING=true     # Allow heartbeat blocks
```

### Environment Variables

| Variable | Full Node | Validator | Description |
|----------|-----------|-----------|-------------|
| `XAI_FAST_MINING` | `1` | `1` | Cap mining difficulty at 4 |
| `XAI_MINING_ENABLED` | `false` | `true` | Enable mining |
| `XAI_FINALITY_ENABLED` | `true` | `true` | BFT finality voting |
| `XAI_API_AUTH_REQUIRED` | `0` | `0` | Disable API auth |

## MVP Module Status

| Module | Status |
|--------|--------|
| blockchain | Enabled |
| consensus | Enabled (Hybrid PoI + BFT) |
| transactions | Enabled (UTXO model) |
| mining | Enabled (PoI mining) |
| p2p | Enabled |
| security | Enabled |
| wallets | Enabled |
| api | Enabled (REST/RPC) |
| sentry | Enabled (DDoS protection) |
| ai | Disabled (Post-MVP) |
| governance | Disabled (Post-MVP) |

## Faucet

Get testnet tokens:

```bash
curl -X POST https://testnet-rpc.xaiblockchain.com/faucet/claim \
  -H "Content-Type: application/json" \
  -d '{"address":"YOUR_ADDRESS"}'
```

Or visit: https://testnet-faucet.xaiblockchain.com

## Health Check

```bash
# Check via public endpoint
curl -s https://testnet-rpc.xaiblockchain.com/stats | jq '.chain_height'

# Check metrics
curl -s https://testnet-rpc.xaiblockchain.com/metrics | grep xai_chain_height
```

## Support

- GitHub Issues: https://github.com/xai-blockchain/xai/issues
- Documentation: https://docs.xaiblockchain.com
