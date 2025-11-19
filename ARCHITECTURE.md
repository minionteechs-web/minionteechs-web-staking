# Architecture Guide

## System Overview

The MiniotechS Web Staking protocol is a production-grade staking contract system with the following components:

```
┌─────────────────────────────────────┐
│   User Interface (Off-chain)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Staking Contract (Main)            │
│  - Stake/Withdraw/Claim             │
│  - Reward Calculation               │
│  - Lock Period Management           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Supporting Contracts               │
│  - MockERC20 (Testing)              │
│  - StakingHelpers (Utilities)       │
│  - IStakingEvents (Events)          │
└─────────────────────────────────────┘
```

## Core Contracts

### Staking.sol

**Main contract** containing:
- Staking logic with tier support
- Reward distribution algorithm
- Emergency withdrawal mechanism
- Admin functions

**Key Components:**

1. **ReentrancyGuard**: Prevents reentrancy attacks
   ```solidity
   modifier nonReentrant()
   ```

2. **Pausable**: Allows emergency pause
   ```solidity
   modifier whenNotPaused()
   ```

3. **StakingRewards**: Main contract with:
   - `stake(amount, tier)`: User deposits
   - `withdraw(amount)`: Unlock and withdraw
   - `emergencyWithdraw(amount)`: Early exit with fee
   - `getReward()`: Claim rewards
   - Admin functions for management

### MockERC20.sol

**Testing utility** for:
- Simulating staking tokens
- Simulating reward tokens
- Mint/burn functionality
- Standard ERC20 interface

### StakingHelpers.sol

**Utility library** with:
- Tier duration constants
- Reward multiplier calculations
- APY calculations
- Helper functions

### IStakingEvents.sol

**Event definitions** for:
- Staking events
- Reward events
- Admin events
- Centralized event management

## Data Structures

### User Data
```solidity
balanceOf[user]              // Staked amount
rewards[user]                // Pending rewards
tier[user]                   // Staking tier (1-3)
stakeLockTime[user]          // Unlock timestamp
userRewardPerTokenPaid[user] // Reward tracking
```

### Global State
```solidity
totalSupply                  // Total staked
rewardRate                   // Tokens per second
rewardPerTokenStored         // Accumulated rewards
lastUpdateTime               // Last update timestamp
```

## Reward Algorithm

Uses Synthetix-style reward distribution:

1. **Per-token rewards accumulation:**
   ```
   rewardPerToken = rewardPerTokenStored + 
                    (now - lastUpdateTime) * rewardRate / totalSupply
   ```

2. **User rewards calculation:**
   ```
   earned = userBalance * (rewardPerToken - userRewardPerTokenPaid) / 1e18 +
            accumulatedRewards
   ```

3. **Update mechanism:**
   - Called before every state-changing operation
   - Updates global reward per token
   - Updates user's reward accounting
   - Sets user's reward per token paid

## Tier System

### Lock Periods
```
Tier 1: 7 days   (1x rewards)
Tier 2: 30 days  (1.5x rewards)
Tier 3: 90 days  (2x rewards)
```

### Lock Enforcement
- Checks `block.timestamp >= stakeLockTime[user]`
- Emergency withdrawal bypasses lock (with fee)
- Lock period resets on each stake

## Fee Mechanism

**Emergency Withdrawal Fee:**
- Default: 5% (500 basis points)
- Configurable by admin (max 50%)
- Collected by fee recipient
- Incentivizes lock compliance

```
amount_received = staked_amount * (10000 - fee_bps) / 10000
```

## State Transitions

### Staking Flow
```
User calls stake()
    ↓
_updateReward(user) [recalculate rewards]
    ↓
Transfer tokens from user to contract
    ↓
Update balanceOf[user] and totalSupply
    ↓
Set tier and lock time
    ↓
Emit Staked event
```

### Withdrawal Flow
```
User calls withdraw()
    ↓
Check unlock status (canWithdraw)
    ↓
_updateReward(user)
    ↓
Update balanceOf[user] and totalSupply
    ↓
Transfer tokens to user
    ↓
Emit Withdrawn event
```

### Reward Claim Flow
```
User calls getReward()
    ↓
_updateReward(user)
    ↓
Calculate earned rewards
    ↓
Reset rewards[user] to 0
    ↓
Transfer reward tokens to user
    ↓
Emit RewardPaid event
```

## Security Mechanisms

### Reentrancy Protection
- `nonReentrant` modifier on all fund transfers
- `_status` flag (1 = unlocked, 2 = locked)

### Access Control
- `onlyOwner` modifier for admin functions
- Owner can be transferred to new address

### Input Validation
- Zero address checks
- Amount > 0 requirements
- Tier range validation (1-3)
- Balance checks before transfers

### Pull-based Rewards
- Users pull rewards, not push
- Reduces risk of infinite loops
- Allows batch claiming

## Gas Optimization

### Storage Efficiency
- Tightly packed state variables
- Minimal SSTORE operations
- Use of immutable variables

### Computation Efficiency
- O(1) operations for all functions
- Avoid loops in state-changing functions
- Efficient reward calculation

## Testing Strategy

### Unit Tests
- Individual function behavior
- Edge cases
- Error conditions

### Integration Tests
- Multiple user interactions
- Reward distribution across users
- Fee collection and distribution

### Fuzz Tests
- Random input generation
- Bounded parameter testing
- Invariant checking

### Coverage
- Target: 100% code coverage
- Focus on critical paths
- Edge case validation

## Future Enhancements

### Planned Features
1. Multi-token reward system
2. Dynamic APY calculation
3. Staking NFT minting
4. Governance token integration
5. Time-lock upgradeable proxy

### Scalability
1. Sidechain deployment
2. Layer 2 optimization
3. Batch operations
4. Subgraph indexing

### Governance
1. DAO governance
2. Proposal voting
3. Parameter changes via voting
4. Community fund allocation
