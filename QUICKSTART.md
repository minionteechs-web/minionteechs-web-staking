# Quick Start Guide

## 🎯 5-Minute Setup

### 1. Install Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Build Project
```bash
cd minionteechs-web-staking
forge build
```

### 3. Run Tests
```bash
forge test -vv
```

### 4. Deploy Locally
```bash
# Terminal 1
anvil

# Terminal 2
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

## 📖 Full Documentation Index

| Document | Purpose | Read Time |
|----------|---------|-----------|
| **README.md** | Project overview & features | 10 min |
| **ARCHITECTURE.md** | System design & components | 15 min |
| **DEPLOYMENT.md** | Deployment procedures | 20 min |
| **SECURITY.md** | Security & vulnerability reporting | 5 min |
| **CONTRIBUTING.md** | How to contribute | 10 min |
| **PROJECT_SUMMARY.md** | Complete project statistics | 10 min |

## 🔑 Key Contract Functions

### User Functions
```solidity
// Stake tokens for 30 days with 1.5x rewards
stake(amount, tier)

// Withdraw after lock expires
withdraw(amount)

// Exit early (with 5% fee)
emergencyWithdraw(amount)

// Claim rewards
getReward()

// Exit completely
exit()
```

### View Functions
```solidity
// Check pending rewards
earned(account)

// Check if unlocked
canWithdraw(account)

// Get rewards per token
rewardPerToken()

// Get tier bonus
getTierBonus(tier)
```

### Admin Functions
```solidity
// Adjust reward rate
setRewardRate(rate)

// Configure emergency fee
setEmergencyWithdrawalFee(fee)

// Pause contract
setPause(true/false)

// Fund rewards
fundRewards(amount)

// Transfer ownership
transferOwnership(newOwner)
```

## 🧪 Testing Commands

```bash
# Run all tests
forge test

# Verbose output
forge test -vv

# Specific test
forge test --match-test testStakeTier1

# Gas report
forge test --gas-report

# Coverage
forge coverage

# Fuzz tests
forge test --match-path test/Staking.fuzz.sol

# Format code
forge fmt
```

## 🚀 Deployment Commands

```bash
# Build
forge build

# Local (Anvil)
anvil
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Testnet (Sepolia)
forge script script/Deploy.s.sol \
  --rpc-url https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast --verify

# Mainnet
forge script script/Deploy.s.sol:DeployMainnetScript \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast --verify
```

## 📊 Staking Tiers

| Tier | Lock Period | Reward Multiplier | Use Case |
|------|-------------|-------------------|----------|
| 1 | 7 days | 1.0x | Flexible staking |
| 2 | 30 days | 1.5x | Medium commitment |
| 3 | 90 days | 2.0x | Long-term yield |

## 💰 Fee Structure

- **Emergency Withdrawal**: 5% (configurable, max 50%)
- **Normal Withdrawal**: 0% (after lock expires)
- **Reward Claiming**: 0%

## 🔐 Security Features

| Feature | Protection |
|---------|-----------|
| Reentrancy Guard | Prevents recursive attacks |
| Input Validation | Checks all parameters |
| Access Control | Owner-only admin functions |
| Pausable | Emergency pause mechanism |
| Fund Recovery | Recover lost ERC20s |
| Lock Enforcement | Prevents early withdrawal |

## 📁 File Organization

```
src/          → Smart contracts
test/         → Test files
script/       → Deployment scripts
*.md          → Documentation
foundry.toml  → Foundry configuration
package.json  → NPM scripts
.env.example  → Environment template
```

## 🎨 Reward Algorithm

```
When user stakes:
  totalSupply += amount
  balanceOf[user] += amount
  Update rewards per token

When user claims:
  earned = balanceOf × (rewardPerToken - paid) / 1e18
  Transfer earned to user
  Reset pending rewards

Continuous:
  rewardPerToken increases by (rewardRate / totalSupply) per second
```

## 📈 APY Calculation

```
APY = (rewardRate × secondsPerYear × tierMultiplier × 100) / totalSupply
```

Example:
- RewardRate: 1 token/sec
- TotalSupply: 1,000,000 tokens
- Tier 3 (2x): APY = (1 × 31,536,000 × 2 × 100) / 1,000,000 = 6.3%

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| "Reentrant" error | Use `nonReentrant` modifier |
| "Paused" error | Unpause with `setPause(false)` |
| "Transfer failed" | Check token approval |
| "Tokens locked" | Wait for lock period to expire |
| "Invalid tier" | Use tier 1, 2, or 3 only |

## 🔗 Useful Links

- [Foundry Docs](https://book.getfoundry.sh/)
- [Solidity Docs](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Etherscan](https://etherscan.io/)

## 💡 Best Practices

1. **Always test locally first**
   ```bash
   forge test -vv
   ```

2. **Check gas before mainnet**
   ```bash
   forge test --gas-report
   ```

3. **Verify contracts on Etherscan**
   ```bash
   forge verify-contract <ADDRESS> StakingRewards --etherscan-api-key $KEY
   ```

4. **Monitor after deployment**
   - Set up block explorer alerts
   - Track transaction volume
   - Monitor gas prices

5. **Keep private keys secure**
   - Never commit `.env`
   - Use environment variables
   - Consider using a hardware wallet

## 📞 Getting Help

1. **Read Documentation**: Start with README.md
2. **Check Tests**: See test/Staking.t.sol for examples
3. **Review Architecture**: Read ARCHITECTURE.md
4. **Check Deployment**: Follow DEPLOYMENT.md
5. **Report Issues**: Use GitHub Issues
6. **Security Issues**: Email security@minionteechs.com

## ✅ Pre-Launch Checklist

- [ ] All tests passing
- [ ] Gas optimized
- [ ] Security reviewed
- [ ] Testnet deployment successful
- [ ] Contract verified on block explorer
- [ ] Monitoring set up
- [ ] Support team trained
- [ ] Emergency procedures documented
- [ ] Governance setup (if needed)
- [ ] Community announcement ready

## 🎉 You're Ready!

Your production-grade staking contract is ready to deploy!

**Next Steps:**
1. Read the full documentation
2. Run the test suite
3. Deploy to testnet
4. Get security audit
5. Launch on mainnet

---

**Questions?** Check the documentation files or open a GitHub issue.
