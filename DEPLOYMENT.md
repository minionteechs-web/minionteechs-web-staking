# Deployment Guide

## Pre-Deployment Checklist

- [ ] Code audit completed
- [ ] All tests passing (100% coverage)
- [ ] Gas optimization review
- [ ] Security review
- [ ] Testnet deployment successful
- [ ] Team review approved
- [ ] Mainnet parameters configured
- [ ] Emergency procedures documented
- [ ] Monitoring setup ready
- [ ] Support team trained

## Environment Setup

### 1. Install Required Tools

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install Node.js (for additional tools)
# https://nodejs.org/

# Verify installation
forge --version
```

### 2. Configure Environment Variables

Create `.env` file:

```bash
# API Keys
ALCHEMY_API_KEY=your_alchemy_key
ETHERSCAN_API_KEY=your_etherscan_key

# Private Keys (NEVER commit!)
DEPLOYER_PRIVATE_KEY=0x...

# Contract Configuration
STAKING_TOKEN_ADDRESS=0x...
REWARDS_TOKEN_ADDRESS=0x...
REWARD_RATE=1000000000000000000  # 1e18

# Network
RPC_URL=https://eth-mainnet.g.alchemy.com/v2/...
```

### 3. Load Environment

```bash
source .env
# or on Windows:
# type .env
```

## Local Testing (Anvil)

### Start Local Network

```bash
# Terminal 1
anvil

# Output:
# Listening on 127.0.0.1:8545
# Accounts:
# Account #0: 0x...
# Private Key: 0x...
```

### Deploy Locally

```bash
# Terminal 2
forge script script/Deploy.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast
```

### Interact Locally

```bash
# Check contract balance
cast call <CONTRACT_ADDRESS> "balanceOf(address)(uint256)" <USER_ADDRESS>

# Send transaction
cast send <CONTRACT_ADDRESS> "stake(uint256,uint256)" "1000000000000000000" "1" \
  --rpc-url http://localhost:8545 \
  --private-key $DEPLOYER_PRIVATE_KEY
```

## Testnet Deployment (Sepolia)

### 1. Get Testnet Funds

- Visit [Sepolia Faucet](https://sepoliafaucet.com/)
- Request testnet ETH (1-2 ETH)

### 2. Configure for Testnet

```bash
# Update .env
ALCHEMY_API_KEY=your_sepolia_alchemy_key
ETHERSCAN_API_KEY=your_etherscan_api_key
DEPLOYER_PRIVATE_KEY=0x...your_testnet_pk
RPC_URL=https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY
```

### 3. Deploy to Sepolia

```bash
forge script script/Deploy.s.sol \
  --rpc-url https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvv
```

### 4. Verify on Etherscan

```bash
forge verify-contract <CONTRACT_ADDRESS> StakingRewards \
  --rpc-url https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

## Mainnet Deployment

### 1. Pre-Deployment

```bash
# Test deployment locally
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Simulate on testnet
forge script script/Deploy.s.sol \
  --rpc-url https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --broadcast \
  --verify
```

### 2. Verify Configuration

```bash
# Check deployer balance
cast balance $DEPLOYER_PRIVATE_KEY --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY

# Ensure sufficient gas funds (5 ETH recommended)
```

### 3. Deploy to Mainnet

```bash
# Use DeployMainnetScript after updating token addresses
forge script script/Deploy.s.sol:DeployMainnetScript \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvv
```

### 4. Verify Contract on Etherscan

```bash
forge verify-contract <MAINNET_CONTRACT_ADDRESS> StakingRewards \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### 5. Post-Deployment

```bash
# Confirm contract code
cast code <CONTRACT_ADDRESS> --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY

# Check contract is initialized
cast call <CONTRACT_ADDRESS> "owner()(address)" \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY

# Verify reward rate
cast call <CONTRACT_ADDRESS> "rewardRate()(uint256)" \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY
```

## Multi-Chain Deployment

### Supported Chains

1. **Ethereum Mainnet**
   - RPC: `https://eth-mainnet.g.alchemy.com/v2/`
   - Etherscan: `https://etherscan.io/`

2. **Polygon**
   - RPC: `https://polygon-mainnet.g.alchemy.com/v2/`
   - Etherscan: `https://polygonscan.com/`

3. **Arbitrum**
   - RPC: `https://arb-mainnet.g.alchemy.com/v2/`
   - Etherscan: `https://arbiscan.io/`

### Deployment Script

```bash
# Deploy to specific chain
CHAIN=arbitrum
forge script script/Deploy.s.sol:DeployMainnetScript \
  --rpc-url $(cast rpc-url $CHAIN) \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify
```

## Gas Optimization

### Check Gas Usage

```bash
# Gas estimate
forge create src/Staking.sol:StakingRewards \
  --rpc-url http://localhost:8545 \
  --constructor-args <STAKING_TOKEN> <REWARDS_TOKEN> 1000000000000000000

# Detailed gas report
forge test --gas-report
```

### Optimize Parameters

- Reduce optimizer runs: `optimizer_runs = 100` (faster deployment)
- Increase for production: `optimizer_runs = 1000000` (better runtime)

## Monitoring Post-Deployment

### Set Up Alerts

1. **Block Explorer Alerts**
   - Monitor transaction activity
   - Set up Etherscan alerts

2. **Contract Monitoring**
   - Track function calls
   - Monitor balance changes
   - Alert on high gas usage

3. **Subgraph Indexing**
   - Deploy TheGraph subgraph
   - Real-time data queries

### Health Checks

```bash
#!/bin/bash
CONTRACT=0x...
RPC=https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY

# Check contract is responsive
curl -X POST $RPC \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "method":"eth_call",
    "params":[{"to":"'$CONTRACT'","data":"0x8da5cb5b"}],
    "id":1
  }'
```

## Rollback Procedures

### Emergency Pause

```bash
cast send <CONTRACT_ADDRESS> "setPause(bool)" true \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $DEPLOYER_PRIVATE_KEY
```

### Recover Funds

```bash
cast send <CONTRACT_ADDRESS> "recoverERC20(address,uint256)" <TOKEN> <AMOUNT> \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $DEPLOYER_PRIVATE_KEY
```

## Troubleshooting

### Common Errors

**"Insufficient funds for gas"**
```bash
# Check balance
cast balance $DEPLOYER_ADDRESS --rpc-url $RPC_URL

# Solution: Send more ETH to deployer
```

**"Contract verification failed"**
```bash
# Wait 30 seconds for indexing
sleep 30

# Retry verification
forge verify-contract <ADDRESS> StakingRewards \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --rpc-url $RPC_URL
```

**"Constructor args mismatch"**
```bash
# Verify constructor arguments
cast call <CONTRACT_ADDRESS> "owner()(address)" --rpc-url $RPC_URL

# Use cast to reconstruct args
cast calldata "constructor(address,address,uint256)" <TOKEN1> <TOKEN2> <RATE>
```

## Documentation

- [Foundry Book](https://book.getfoundry.sh/)
- [Etherscan API](https://docs.etherscan.io/)
- [Alchemy API](https://docs.alchemy.com/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/)
