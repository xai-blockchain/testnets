# XAI Testnets Repository

## Repository Separation

**This repo (`xai-testnets/`)** → github:xai-blockchain/testnets (network config)
**Main repo (`xai/`)** → github:xai-blockchain/xai (source code)

### Save HERE (xai-testnets/<chain-id>/)
- config.json - network configuration
- network_info.json - network metadata
- peers.txt, seeds.txt - node addresses
- config/.env.example - reference environment config
- SNAPSHOTS.md - sync guide
- README.md - network-specific docs

### Save to MAIN REPO (xai/)
- Python source code, blockchain modules
- Tests, requirements.txt, setup.py
- Dockerfiles, docker-compose files
- General documentation

## Health Check
Run `~/blockchain-projects/scripts/testnet-health-check.sh` for all testnets.

## Port Configuration (XAI Testnet - Port Range 12000-12999)

**4-Node Setup** with staged deployment (2 miners + 2 validator-only)

### Node Ports (xai-testnet / 10.10.0.3)
| Node | Role | RPC | P2P | WS |
|------|------|-----|-----|-----|
| Node 1 | Miner + Validator | 12545 | 12333 | 12765 |
| Node 2 | Miner + Validator | 12555 | 12334 | 12766 |

### Node Ports (services-testnet / 10.10.0.4)
| Node | Role | RPC | P2P | WS |
|------|------|-----|-----|-----|
| Node 3 | Validator only | 12546 | 12335 | 12767 |
| Node 4 | Validator only | 12556 | 12336 | 12768 |

### Public Endpoints
| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.xaiblockchain.com |
| REST API | https://testnet-api.xaiblockchain.com |
| WebSocket | wss://testnet-ws.xaiblockchain.com |
| Explorer | https://testnet-explorer.xaiblockchain.com |
| Faucet | https://testnet-faucet.xaiblockchain.com |

### Service Ports
| Service | Port |
|---------|------|
| Explorer API | 12080 |
| Faucet API | 12081 |
| WS Proxy | 12082 |
| Indexer API | 12084 |
| GraphQL | 12400 |

See `xai-testnet-1/TESTNET_SETUP.md` for full deployment checklist.
