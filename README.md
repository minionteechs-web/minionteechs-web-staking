# MiniotechS Web Staking

A production-grade, full-stack ERC20 staking protocol with tiered rewards, emergency withdrawals, and comprehensive testing.

## Features

### Core Staking Features
- **Tiered Staking System**: Choose from 3 lock periods with different reward multipliers
  - Tier 1: 7 days lock (1x rewards)
  - Tier 2: 30 days lock (1.5x rewards)
  - Tier 3: 90 days lock (2x rewards)
- **Reward Accrual**: Synthetix-style reward distribution
- **Emergency Withdrawal**: Exit early with 5% fee (configurable)
- **Pull-based Rewards**: Users claim rewards on-demand
- **Reentrancy Protection**: Secure against reentrancy attacks

### Admin Features
- **Pausable Contract**: Pause/unpause staking in emergencies
- **Configurable Reward Rate**: Adjust rewards per second
- **Configurable Emergency Fee**: Set custom withdrawal penalties
- **Fee Recovery**: Withdraw collected emergency fees
- **ERC20 Recovery**: Recover accidentally sent tokens

### Safety Features
- **Reentrancy Guard**: Protection against reentrancy attacks
- **Zero Address Checks**: Validate address inputs
- **Balance Validation**: Ensure sufficient balances before transfers
- **Lock Enforcement**: Prevent early withdrawals (except emergency)

## Project Structure

```
minionteechs-web-staking/
├── src/
│   ├── Staking.sol          # Main staking contract
│   ├── MockERC20.sol        # Mock ERC20 for testing
│   ├── StakingHelpers.sol   # Helper library
│   └── IStakingEvents.sol   # Event interface
├── test/
│   └── Staking.t.sol        # Comprehensive test suite
├── script/
│   └── Deploy.s.sol         # Deployment scripts
├── foundry.toml             # Foundry configuration
├── .env.example             # Environment template
├── .gitignore               # Git ignore rules
└── README.md                # This file
```

## Prerequisites

- [Foundry](https://book.getfoundry.sh/)
- Rust 1.70.0+
- Git

## Installation

1. Clone the repository:
```bash
git clone https://github.com/minionteechs-web/minionteechs-web-staking.git
cd minionteechs-web-staking
```

2. Install dependencies:
```bash
forge install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Build

```bash
# Build contracts
forge build

# Build with optimization
forge build --optimize
```

## Testing

```bash
# Run all tests
forge test

# Run tests with verbose output
forge test -vv

# Run specific test file
forge test --match-path test/Staking.t.sol

# Run specific test function
forge test --match-test testStakeTier1

# Run with gas reporting
forge test --gas-report

# Generate coverage report
forge coverage
```

## Deployment

### Local Testing (Anvil)

```bash
# Start local blockchain
anvil

# In another terminal, deploy to local network
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Testnet Deployment (Sepolia)

```bash
export DEPLOYER_PRIVATE_KEY=your_private_key_here
export ETHERSCAN_API_KEY=your_etherscan_key_here

forge script script/Deploy.s.sol:DeployMainnetScript \
  --rpc-url https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify
```

### Mainnet Deployment

```bash
# Update STAKING_TOKEN and REWARDS_TOKEN in DeployMainnetScript
forge script script/Deploy.s.sol:DeployMainnetScript \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify
```

## Contract API

### User Functions

#### `stake(uint256 amount, uint256 tier) external`
Stake tokens in a specific tier (1-3).

```solidity
// Stake 1000 tokens in Tier 2 (30 days)
stakingContract.stake(1000e18, 2);
```

#### `withdraw(uint256 amount) external`
Withdraw staked tokens after lock period expires.

```solidity
// Withdraw 500 tokens (must be unlocked)
stakingContract.withdraw(500e18);
```

#### `emergencyWithdraw(uint256 amount) external`
Exit early with a 5% fee (configurable).

```solidity
// Emergency exit - receives 95% of stake
stakingContract.emergencyWithdraw(1000e18);
```

#### `getReward() external`
Claim accumulated rewards.

```solidity
stakingContract.getReward();
```

#### `exit() external`
Withdraw all staked tokens and claim rewards.

```solidity
stakingContract.exit();
```

### View Functions

#### `rewardPerToken() public view returns (uint256)`
Get current reward per token.

#### `earned(address account) public view returns (uint256)`
Get pending rewards for an account.

#### `canWithdraw(address account) public view returns (bool)`
Check if account can withdraw without penalty.

#### `getTierBonus(uint256 tier) public pure returns (uint256)`
Get reward multiplier for a tier.

### Admin Functions

#### `setRewardRate(uint256 _rewardRate) external onlyOwner`
Update reward rate (tokens per second).

#### `setEmergencyWithdrawalFee(uint256 _fee) external onlyOwner`
Update emergency withdrawal fee (in basis points, max 50%).

#### `setFeeRecipient(address _recipient) external onlyOwner`
Set address to receive emergency withdrawal fees.

#### `setPause(bool _paused) external onlyOwner`
Pause or unpause the staking contract.

#### `fundRewards(uint256 amount) external onlyOwner`
Add rewards to the contract.

#### `recoverERC20(address token, uint256 amount) external onlyOwner`
Recover accidentally sent ERC20 tokens.

#### `transferOwnership(address newOwner) external onlyOwner`
Transfer ownership to a new address.

## Test Coverage

The test suite includes:
- ✅ Staking with all tiers
- ✅ Withdrawal with lock validation
- ✅ Emergency withdrawal with fees
- ✅ Reward accrual and claiming
- ✅ Pause/unpause functionality
- ✅ Admin functions
- ✅ Edge cases and error handling
- ✅ Multiple user scenarios

Run `forge coverage` to see detailed coverage report.

## Security Considerations

1. **Reentrancy**: Protected with ReentrancyGuard
2. **Overflow/Underflow**: Uses Solidity 0.8.20+ (checked arithmetic)
3. **Input Validation**: All external functions validate inputs
4. **Access Control**: Owner-only functions protected
5. **Fund Safety**: Reentrancy guard on all fund transfers

## Audit Checklist

- [ ] Code review by security team
- [ ] Formal verification for critical functions
- [ ] Third-party security audit
- [ ] Mainnet testnet deployment
- [ ] Community testing phase
- [ ] Monitoring and incident response plan

## Gas Optimization

- Optimized reward calculations to minimize storage reads
- Efficient tier-based lock time calculations
- Minimal storage updates per operation

## Performance

- Supports unlimited number of stakers
- O(1) stake/withdraw/claim operations
- Reward calculations scale O(1) per user

## Roadmap

- [ ] Multi-token reward system
- [ ] Dynamic APY calculation
- [ ] Staking NFT minting
- [ ] Governance token integration
- [ ] Subgraph indexing
- [ ] Frontend dApp

## Configuration

Key parameters (in Staking.sol):

```solidity
TIER_1_DURATION = 7 days      // 604,800 seconds
TIER_2_DURATION = 30 days     // 2,592,000 seconds
TIER_3_DURATION = 90 days     // 7,776,000 seconds

emergencyWithdrawalFee = 500   // 5% in basis points
```

## Troubleshooting

### Tests failing with "Transfer failed"
- Ensure mock tokens have sufficient balance
- Check token approvals

### Deployment fails with "Invalid tier"
- Ensure tier is 1, 2, or 3

### Rewards not accumulating
- Check reward rate is not zero
- Verify rewards token has sufficient balance in contract

## Development Workflow

1. Make changes to contracts in `src/`
2. Run tests: `forge test`
3. Check gas: `forge test --gas-report`
4. Format code: `forge fmt`
5. Commit and push

## License

MIT License - see LICENSE file for details

## Support

- 📖 [Foundry Documentation](https://book.getfoundry.sh/)
- 💬 [GitHub Issues](https://github.com/minionteechs-web/minionteechs-web-staking/issues)
- 🐦 [@minionteechs](https://twitter.com/minionteechs)

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Write tests for new features
4. Submit a pull request

## Changelog

### v1.0.0 (2025-11-19)
- Initial release
- Tiered staking system
- Emergency withdrawal functionality
- Comprehensive test suite
