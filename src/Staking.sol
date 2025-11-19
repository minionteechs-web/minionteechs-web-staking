// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StakingRewards
 * @notice Production-grade staking rewards contract with emergency features
 * - Stake ERC20 token `stakingToken`
 * - Rewards distributed in ERC20 `rewardsToken`
 * - rewardRate is rewardsPerSecond (token units per second)
 * - Reentrancy protection and pull-based reward claiming
 * - Emergency withdrawal capability
 * - Pausable contract
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ReentrancyGuard {
    uint256 private _status;
    constructor() { _status = 1; }
    modifier nonReentrant() {
        require(_status == 1, "Reentrant");
        _status = 2;
        _;
        _status = 1;
    }
}

contract Pausable {
    bool public paused;
    address public owner;
    
    event Paused();
    event Unpaused();
    
    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }
    
    function setPause(bool _paused) external onlyOwner {
        paused = _paused;
        if (_paused) emit Paused();
        else emit Unpaused();
    }
}

contract StakingRewards is ReentrancyGuard, Pausable {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;
    
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    
    // Reward accounting
    uint256 public rewardRate; // rewards per second
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    
    // Staking tiers and lock periods
    uint256 public constant TIER_1_DURATION = 7 days;
    uint256 public constant TIER_2_DURATION = 30 days;
    uint256 public constant TIER_3_DURATION = 90 days;
    
    mapping(address => uint256) public stakeLockTime;
    mapping(address => uint256) public tier; // 1, 2, or 3
    
    // Emergency withdrawal
    uint256 public emergencyWithdrawalFee = 500; // 5% in basis points
    address public feeRecipient;
    
    // Events
    event Staked(address indexed user, uint256 amount, uint256 tier);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);
    event OwnerTransferred(address oldOwner, address newOwner);
    event EmergencyWithdrawal(address indexed user, uint256 amount, uint256 fee);
    event RewardsFunded(uint256 amount);

    constructor(address _stakingToken, address _rewardsToken, uint256 _rewardRate) {
        require(_stakingToken != address(0) && _rewardsToken != address(0), "Zero address");
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        owner = msg.sender;
        feeRecipient = msg.sender;
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
        paused = false;
    }

    /* ========== VIEWS ========== */

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) return rewardPerTokenStored;
        return rewardPerTokenStored + ((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / totalSupply;
    }

    function earned(address account) public view returns (uint256) {
        return (balanceOf[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18 + rewards[account];
    }
    
    function getTierBonus(uint256 _tier) public pure returns (uint256) {
        if (_tier == 1) return 100; // 1x
        if (_tier == 2) return 150; // 1.5x
        if (_tier == 3) return 200; // 2x
        return 100;
    }
    
    function canWithdraw(address account) public view returns (bool) {
        return block.timestamp >= stakeLockTime[account];
    }

    /* ========== MUTATIVE ========== */

    function _updateReward(address account) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }

    function stake(uint256 amount, uint256 _tier) external nonReentrant whenNotPaused {
        require(amount > 0, "Cannot stake 0");
        require(_tier >= 1 && _tier <= 3, "Invalid tier");
        
        _updateReward(msg.sender);
        
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        tier[msg.sender] = _tier;
        
        // Set lock time based on tier
        if (_tier == 1) stakeLockTime[msg.sender] = block.timestamp + TIER_1_DURATION;
        else if (_tier == 2) stakeLockTime[msg.sender] = block.timestamp + TIER_2_DURATION;
        else stakeLockTime[msg.sender] = block.timestamp + TIER_3_DURATION;
        
        emit Staked(msg.sender, amount, _tier);
    }

    function withdraw(uint256 amount) public nonReentrant whenNotPaused {
        require(amount > 0, "Cannot withdraw 0");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        require(canWithdraw(msg.sender), "Tokens locked");
        
        _updateReward(msg.sender);
        
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }
    
    function emergencyWithdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot withdraw 0");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        
        _updateReward(msg.sender);
        
        uint256 fee = (amount * emergencyWithdrawalFee) / 10000;
        uint256 net = amount - fee;
        
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        
        require(stakingToken.transfer(msg.sender, net), "Transfer failed");
        require(stakingToken.transfer(feeRecipient, fee), "Fee transfer failed");
        
        emit EmergencyWithdrawal(msg.sender, amount, fee);
    }

    function getReward() public nonReentrant whenNotPaused {
        _updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            require(rewardsToken.transfer(msg.sender, reward), "Reward transfer failed");
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(balanceOf[msg.sender]);
        getReward();
    }

    /* ========== ADMIN ========== */

    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        _updateReward(address(0));
        rewardRate = _rewardRate;
        emit RewardRateUpdated(_rewardRate);
    }
    
    function setEmergencyWithdrawalFee(uint256 _fee) external onlyOwner {
        require(_fee <= 5000, "Fee too high"); // Max 50%
        emergencyWithdrawalFee = _fee;
    }
    
    function setFeeRecipient(address _recipient) external onlyOwner {
        require(_recipient != address(0), "Zero address");
        feeRecipient = _recipient;
    }
    
    function fundRewards(uint256 amount) external onlyOwner {
        require(rewardsToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit RewardsFunded(amount);
    }
    
    function recoverERC20(address token, uint256 amount) external onlyOwner {
        require(token != address(stakingToken), "Cannot recover staking token");
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        emit OwnerTransferred(owner, newOwner);
        owner = newOwner;
    }
}
