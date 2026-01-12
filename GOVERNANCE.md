# Governance

This repository contains network configurations for XAI testnets and follows the governance structure of the main XAI project.

## Scope

This repository governs:
- Genesis files and network parameters
- Peer and seed node lists
- Validator set configurations
- Snapshot and sync documentation

## Decision Process

### Network Configuration Changes

1. **Proposal**: Author creates GitHub issue or PR
2. **Review**: Core team and validators provide feedback
3. **Approval**: Changes require core team approval
4. **Merge**: Approved changes merged to main

### Adding Validators

New validator additions to active testnets require:
1. PR with validator info in `validators.json`
2. Core team review and approval
3. Network coordination for genesis updates

## Roles

### Core Maintainers
- Review and merge network configuration PRs
- Coordinate testnet launches and upgrades
- Manage validator coordination

### Validators
- Maintain uptime and network health
- Participate in testnet governance
- Report issues and propose improvements

## Related

- Main project governance: [xai-blockchain/xai](https://github.com/xai-blockchain/xai)
- Security policy: See SECURITY.md
