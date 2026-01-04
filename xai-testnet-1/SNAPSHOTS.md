# XAI Testnet Snapshots

This document describes how to use snapshots for fast node synchronization.

## Available Snapshots

| Type | Size | Update Frequency | Download |
|------|------|------------------|----------|
| Full | ~10 GB | Daily | [Download](https://artifacts.xaiblockchain.com/snapshots/xai-testnet-1-latest.tar.lz4) |

## Quick Restore

```bash
# 1. Stop the node
pkill -f "xai.node"

# 2. Backup wallet (if exists)
cp ~/.xai/wallet.json ~/.xai/wallet.json.backup

# 3. Remove old data
rm -rf ~/.xai/data

# 4. Create data directory
mkdir -p ~/.xai/data

# 5. Download and extract snapshot
curl -L https://artifacts.xaiblockchain.com/snapshots/xai-testnet-1-latest.tar.lz4 | lz4 -dc - | tar -xf - -C ~/.xai/data

# 6. Start the node
source ~/.xai/venv/bin/activate
python -m xai.node
```

## Docker Restore

```bash
# 1. Stop container
docker stop xai-node

# 2. Remove old data
docker exec xai-node rm -rf /root/.xai/data

# 3. Download and extract snapshot
docker exec xai-node bash -c "curl -L https://artifacts.xaiblockchain.com/snapshots/xai-testnet-1-latest.tar.lz4 | lz4 -dc - | tar -xf - -C /root/.xai/data"

# 4. Start container
docker start xai-node
```

## Snapshot Verification

Each snapshot comes with a checksum file:

```bash
# Download checksum
curl -O https://artifacts.xaiblockchain.com/snapshots/xai-testnet-1-latest.sha256

# Verify (after downloading the snapshot)
sha256sum -c xai-testnet-1-latest.sha256
```

## Snapshot Contents

The snapshot archive contains:

```
data/
├── blocks/           # Block data
├── chainstate/       # UTXO set
├── indexes/          # Block indexes
└── mempool.dat       # Mempool state
```

## When to Use Snapshots

**Use Snapshot When:**
- Setting up a new full node
- Node fell too far behind to sync normally
- Quick recovery after data corruption
- Testing purposes
- Limited bandwidth for full sync

## Snapshot Schedule

| Snapshot Type | Generation Time (UTC) |
|---------------|----------------------|
| Full (daily) | 00:00 |

## Troubleshooting

### Database Corruption

If you encounter database errors after restore:
```bash
rm -rf ~/.xai/data
# Re-download and extract snapshot
```

### Slow Extraction

For faster extraction, ensure you have `lz4` installed:
```bash
# Ubuntu/Debian
sudo apt install lz4

# macOS
brew install lz4
```

### Disk Space Issues

Before restoring, ensure you have at least 25 GB free disk space.

## Support

For snapshot-related issues:
- GitHub: https://github.com/xai-blockchain/testnets/issues
- Discord: https://discord.gg/xai
