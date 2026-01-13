# XAI MVP Testnet

**Chain ID:** `xai-mvp-testnet-1`
**Version:** 1.0.0-mvp

## Network Architecture

| Node | Server | Role | RPC | P2P |
|------|--------|------|-----|-----|
| Node 1 | xai-testnet (10.10.0.3) | Miner+Validator | 12545 | 12333 |
| Node 2 | xai-testnet (10.10.0.3) | Miner+Validator | 12555 | 12334 |
| Node 3 | services-testnet (10.10.0.4) | Validator | 12546 | 12335 |
| Node 4 | services-testnet (10.10.0.4) | Validator | 12556 | 12336 |

## Public Endpoints

- **RPC:** https://testnet-rpc.xaiblockchain.com
- **API:** https://testnet-api.xaiblockchain.com
- **Explorer:** https://testnet-explorer.xaiblockchain.com
- **Faucet:** https://testnet-faucet.xaiblockchain.com

## Configuration

### Fast Mining (Required)

The network type `mvp-testnet` requires explicit fast mining configuration:

```bash
XAI_FAST_MINING=1                    # Enable fast mining (caps difficulty at 4)
XAI_ALLOW_EMPTY_MINING=true          # Allow heartbeat blocks when mempool empty
```

Without `XAI_FAST_MINING=1`, mining will use difficulty 16+ which is too hard for testnet.

### Key Environment Variables

| Variable | Miner Nodes | Validator Nodes | Description |
|----------|-------------|-----------------|-------------|
| `XAI_FAST_MINING` | `1` | - | Cap mining difficulty at 4 |
| `XAI_ALLOW_EMPTY_MINING` | `true` | - | Mine heartbeat blocks on idle |
| `XAI_MINING_ENABLED` | `true` | `false` | Enable/disable mining |
| `XAI_FINALITY_ENABLED` | `true` | `true` | BFT finality voting |
| `XAI_API_AUTH_REQUIRED` | `0` | `0` | Disable API auth for testnet |
| `XAI_FAUCET_WALLET_FILE` | path | - | Faucet wallet for miner nodes |
| `XAI_FAUCET_AMOUNT` | `10` | - | XAI per faucet claim |

## MVP Module Status

| Module | Status | Notes |
|--------|--------|-------|
| blockchain | Enabled | Core chain |
| consensus | Enabled | Hybrid PoI + BFT |
| transactions | Enabled | UTXO model |
| mining | Enabled | PoI mining |
| p2p | Enabled | Node networking |
| security | Enabled | Crypto + validation |
| wallets | Enabled | Key management |
| api | Enabled | REST/RPC |
| ai | Disabled | Post-MVP |
| governance | Disabled | Post-MVP |
| defi | Disabled | Post-MVP |
| vm | Disabled | Post-MVP |

## Deployment

```bash
# Deploy all phases
./deploy-mvp.sh all

# Or run phases individually
./deploy-mvp.sh 1  # Stop old & backup
./deploy-mvp.sh 2  # Deploy xai-testnet
./deploy-mvp.sh 3  # Deploy services-testnet
./deploy-mvp.sh 4  # Start & verify
```

## Health Check

```bash
# Check all nodes
for hp in "10.10.0.3:12545" "10.10.0.3:12555" "10.10.0.4:12546" "10.10.0.4:12556"; do
  echo "$hp: $(curl -s http://$hp/stats | jq -r '.chain_height')"
done
```

## Faucet

Get testnet tokens via RPC endpoint (no captcha required):
```bash
curl -X POST https://testnet-rpc.xaiblockchain.com/faucet/claim \
  -H "Content-Type: application/json" \
  -d '{"address":"YOUR_ADDRESS"}'
```

**Note:** The faucet web UI at testnet-faucet.xaiblockchain.com requires Turnstile captcha.

## Service Management

```bash
# xai-testnet
sudo systemctl {start|stop|restart|status} xai-mvp-node1
sudo systemctl {start|stop|restart|status} xai-mvp-node2

# services-testnet
sudo systemctl {start|stop|restart|status} xai-mvp-node3
sudo systemctl {start|stop|restart|status} xai-mvp-node4
```
