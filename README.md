# minionteechs-web-staking

A Foundry-based smart contract project for implementing a staking protocol.

## Project Structure

```
minionteechs-web-staking/
├── src/
│   └── Staking.sol          # Main staking contract
├── test/
│   └── Staking.t.sol        # Contract tests
├── script/
│   └── Deploy.s.sol         # Deployment script
├── foundry.toml             # Foundry configuration
└── README.md                # This file
```

## Prerequisites

- [Foundry](https://book.getfoundry.sh/)
- Rust (required for Foundry)

## Installation

```bash
# Install dependencies
forge install

# Build contracts
forge build

# Run tests
forge test

# Deploy (requires environment setup)
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## Development

- Edit contracts in `src/`
- Write tests in `test/`
- Update deployment logic in `script/`

## License

MIT
