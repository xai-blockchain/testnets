# XAI MVP Testnet Architecture

**Chain ID:** `xai-mvp-testnet-1`
**Last Updated:** 2026-01-14

## Overview

The XAI MVP Testnet implements a sentry node architecture for DDoS protection, with validators hidden behind a WireGuard VPN mesh network. The network includes a Blockscout-powered block explorer with EVM-compatible RPC adapter for full blockchain indexing.

## Network Topology

```
                              INTERNET
                                  │
                          ┌───────┴───────┐
                          │   Cloudflare  │
                          │   (SSL/CDN)   │
                          └───────┬───────┘
                                  │
                          ┌───────┴───────┐
                          │     nginx     │
                          │ (Load Balance)│
                          └───────┬───────┘
                                  │
    ┌─────────────┬───────────────┼───────────────┬─────────────┐
    │             │               │               │             │
┌───┴───┐   ┌─────┴─────┐   ┌─────┴─────┐   ┌─────┴─────┐   ┌───┴───┐
│Blocksct│   │  Sentry 1 │   │  Sentry 2 │   │ Services  │   │Faucet │
│Explorer│   │   :12570  │   │   :12571  │   │ WS/GQL/etc│   │:12081 │
└───┬───┘   └─────┬─────┘   └─────┬─────┘   └───────────┘   └───────┘
    │             │               │
    │       ┌─────┴───────────────┘
    │       │
┌───┴───────┴───┐
│  RPC Adapter  │
│    :8545      │
│ (Dual Sentry  │
│   Failover)   │
└───────┬───────┘
        │
        └────────┬────────┐
                 │ WireGuard VPN (10.10.0.x)
        ┌────────┴────────┐
        │                 │
  ┌─────┴─────┐     ┌─────┴─────┐
  │xai-testnet│     │services-  │
  │ 10.10.0.3 │     │ testnet   │
  │           │     │ 10.10.0.4 │
  │ Node 1    │     │ Node 3    │
  │ Node 2    │     │ Node 4    │
  └───────────┘     └───────────┘
```

## Server Infrastructure

### xai-testnet (54.39.129.11 / 10.10.0.3)

Primary server hosting sentries, miners, and supporting services.

| Component | Type | Port | Service Unit |
|-----------|------|------|--------------|
| Sentry 1 | Gateway | RPC:12570, P2P:12371 | `xai-sentry1.service` |
| Sentry 2 | Gateway | RPC:12571, P2P:12372 | `xai-sentry2.service` |
| Node 1 | Miner+Validator | RPC:12545, P2P:12333 | `xai-mvp-node1.service` |
| Node 2 | Miner+Validator | RPC:12555, P2P:12334 | `xai-mvp-node2.service` |
| **Blockscout Explorer** ||||
| RPC Adapter | EVM Translation | 8545 | `xai-rpc-adapter.service` |
| Blockscout Backend | Indexer (Elixir) | 4000 | Docker: `blockscout-backend` |
| Blockscout Frontend | UI (Next.js) | 3001 | Docker: `blockscout-frontend` |
| PostgreSQL | Database | 5432 | Docker: `blockscout-postgres` |
| **Legacy Services** ||||
| Faucet | Service | 12081 | `xai-faucet.service` |
| WebSocket | Service | 8766 | `xai-websocket.service` |
| GraphQL | Service | 8083 | `xai-graphql.service` |

### services-testnet (139.99.149.160 / 10.10.0.4)

Secondary server hosting additional validators.

| Component | Type | Port | Service Unit |
|-----------|------|------|--------------|
| Node 3 | Validator | RPC:12546, P2P:12335 | `xai-mvp-node3.service` |
| Node 4 | Validator | RPC:12556, P2P:12336 | `xai-mvp-node4.service` |

## Consensus Architecture

### Hybrid PoI + BFT

- **Mining**: Proof of Intelligence (PoI) with capped difficulty
- **Finality**: BFT with 67% quorum threshold (3 of 4 validators)
- **Block Time**: ~10 seconds target

### Validator Set

| Node | Role | Mining | Voting |
|------|------|--------|--------|
| Node 1 | Miner+Validator | Yes | Yes |
| Node 2 | Miner+Validator | Yes | Yes |
| Node 3 | Validator Only | No | Yes |
| Node 4 | Validator Only | No | Yes |

## Network Security

### Sentry Node Architecture

Sentries protect validators from direct exposure:

1. **Public Traffic** → Sentries only (IPs: 54.39.129.11)
2. **Validator IPs** → Never exposed, VPN-only (10.10.0.x)
3. **Peer Discovery** → Disabled on validators (`--pex-disabled`)
4. **Private Peers** → Validators listed in sentry `--private-peers`

### DDoS Protection Layers

1. **Cloudflare** - CDN, WAF, rate limiting
2. **nginx** - Connection limits, upstream health checks
3. **Sentries** - Gossip filtering, rate limiting
4. **VPN** - Validators unreachable from public internet

## Service Dependencies

```
┌─────────────────────────────────────────────────────────────┐
│                      Public Layer                            │
│  Blockscout UI ──► Blockscout API ──► RPC Adapter           │
│  Faucet ─────────────────────────────► Sentry RPC           │
│  GraphQL ────────────────────────────► Sentry RPC           │
│  WebSocket ──────────────────────────► Sentry RPC           │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    RPC Adapter Layer                         │
│  RPC Adapter (8545) ─┬─► Sentry 1 (12570) [primary]         │
│     (EVM JSON-RPC)   └─► Sentry 2 (12571) [failover]        │
│  - Health-based load balancing                              │
│  - Automatic failover on node failure                       │
│  - Response time tracking for optimal routing               │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      Sentry Layer                            │
│  Sentry 1 ────┬─► Node 1, Node 2 (VPN)                      │
│  Sentry 2 ────┘─► Node 3, Node 4 (VPN)                      │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     Validator Layer                          │
│  Node 1 ◄───► Node 2 ◄───► Node 3 ◄───► Node 4             │
│         (Full mesh via WireGuard VPN)                       │
└─────────────────────────────────────────────────────────────┘
```

## Blockscout Explorer Architecture

### Why Blockscout?

Blockscout is the industry-standard open-source block explorer for EVM chains. Since XAI uses a custom Python blockchain (not EVM-native), an **RPC Adapter** translates XAI's native API to EVM-compatible JSON-RPC format.

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Blockscout Stack                          │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Next.js)     │ Port 3001 │ Docker container      │
│  - Modern React UI      │           │                       │
│  - Real-time updates    │           │                       │
│  - Transaction search   │           │                       │
├─────────────────────────────────────────────────────────────┤
│  Backend (Elixir/OTP)   │ Port 4000 │ Docker container      │
│  - Block indexer        │           │                       │
│  - API v2 endpoints     │           │                       │
│  - WebSocket server     │           │                       │
├─────────────────────────────────────────────────────────────┤
│  PostgreSQL             │ Port 5432 │ Docker container      │
│  - Indexed chain data   │           │                       │
│  - Full-text search     │           │                       │
├─────────────────────────────────────────────────────────────┤
│  RPC Adapter (FastAPI)  │ Port 8545 │ systemd service       │
│  - XAI → EVM translation│           │                       │
│  - Dual sentry failover │           │                       │
│  - Health monitoring    │           │                       │
└─────────────────────────────────────────────────────────────┘
```

### RPC Adapter Features

The RPC adapter provides EVM-compatible JSON-RPC endpoints while connecting to XAI sentry nodes:

| Feature | Description |
|---------|-------------|
| **Dual Node Failover** | Routes to fastest healthy sentry node |
| **Health Checks** | Monitors both sentries every 30 seconds |
| **Load Balancing** | Supports `fastest`, `round_robin`, `random` strategies |
| **Auto Recovery** | Re-enables nodes after recovery |

### Supported EVM Methods

| Method | XAI Mapping |
|--------|-------------|
| `eth_blockNumber` | `/stats` → `chain_height` |
| `eth_getBlockByNumber` | `/block/{height}` |
| `eth_getBlockByHash` | `/block/{hash}` |
| `eth_getTransactionByHash` | `/transaction/{txid}` |
| `eth_getBalance` | `/address/{addr}` → `balance` |
| `eth_chainId` | Returns configured chain ID (0x539) |
| `net_version` | Returns chain ID as string |

### Explorer Endpoints

| Endpoint | URL | Description |
|----------|-----|-------------|
| Explorer UI | https://testnet-explorer.xaiblockchain.com | Block explorer interface |
| API v2 | https://testnet-explorer.xaiblockchain.com/api/v2/* | Blockscout REST API |
| RPC Health | https://testnet-explorer.xaiblockchain.com/rpc-health | Adapter health status |
| Node Status | https://testnet-explorer.xaiblockchain.com/rpc-nodes | Sentry node health |

### Docker Compose Deployment

```bash
# Start Blockscout stack
cd ~/blockscout-adapter/deploy
docker compose -f docker-compose-blockscout.yml up -d

# Check status
docker compose -f docker-compose-blockscout.yml ps

# View logs
docker compose -f docker-compose-blockscout.yml logs -f blockscout-backend
```

## Data Flow

### Transaction Lifecycle

1. User submits tx to `testnet-api.xaiblockchain.com`
2. nginx routes to sentry1 or sentry2 (round-robin)
3. Sentry validates and adds to mempool
4. Sentry gossips to validators via VPN
5. Mining node includes in block
6. Block proposed to BFT consensus
7. 3/4 validators sign → block finalized
8. WebSocket broadcasts new block

### Block Propagation

```
Miner (Node 1/2) → Sentries → Validators (Node 3/4)
                      ↓
               WebSocket/GraphQL
                      ↓
              Explorer/Faucet/Users
```

## Environment Configuration

### Required Variables (All Nodes)

```bash
XAI_FAST_MINING=1              # Cap difficulty at 4
XAI_ALLOW_EMPTY_MINING=true    # Allow heartbeat blocks
XAI_FINALITY_ENABLED=true      # Enable BFT finality
XAI_CHAIN_ID=xai-mvp-testnet-1
```

### Sentry-Specific

```bash
--sentry-mode                  # Enable sentry behavior
--private-peers <validator-ips> # Hidden validator addresses
```

### Validator-Specific

```bash
--pex-disabled                 # Disable peer discovery
--miner <address>              # Mining address (Node 1/2 only)
```

## Monitoring Points

### Health Endpoints

| Check | URL | Expected |
|-------|-----|----------|
| RPC Health | `/stats` | `chain_height` incrementing |
| API Health | `/health` | HTTP 200 |
| WebSocket | Connect + receive | Block updates |
| GraphQL | `{ latestBlock { index } }` | Valid response |

### Key Metrics

- Block height (should match across all nodes)
- Peer count (sentries: 2+, validators: depends on mesh)
- Mempool size
- Finality lag (blocks between mined and finalized)

## Disaster Recovery

### Node Recovery

1. Stop failed node service
2. Sync chain data from healthy node
3. Restart with same configuration
4. Verify height matches network

### Network Partition

- BFT requires 3/4 validators for finality
- If <3 validators available, chain halts
- Recovery: restore quorum, consensus resumes automatically

## File Locations (xai-testnet)

| Component | Path |
|-----------|------|
| Node binaries | `/home/ubuntu/xai/` |
| Chain data | `/home/ubuntu/xai/data/` |
| Service units | `/etc/systemd/system/xai-*.service` |
| nginx configs | `/etc/nginx/sites-available/testnet-*.xaiblockchain.com` |
| Logs | `journalctl -u xai-*` |
| **Blockscout Components** ||
| RPC Adapter | `/home/ubuntu/blockscout-adapter/` |
| RPC Adapter Service | `/etc/systemd/system/xai-rpc-adapter.service` |
| Docker Compose | `/home/ubuntu/blockscout-adapter/deploy/docker-compose-blockscout.yml` |
| PostgreSQL Data | Docker volume: `postgres_data` |
| Blockscout Logs | `docker compose logs -f` |
