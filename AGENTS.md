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
