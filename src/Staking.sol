// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StakingRewards
 * @notice Minimal production-grade staking rewards contract (Synthetix-style)
 * - Stake ERC20 token `stakingToken`
 * - Rewards distributed in ERC20 `rewardsToken`
 * - rewardRate is rewardsPerSecond (token units per second)
 * - Uses reentrancy guard and pull-based reward claiming
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
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

contract StakingRewards is ReentrancyGuard {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;
    address public owner;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    // reward accounting
    uint256 public rewardRate; // rewards per second
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);
    event OwnerTransferred(address oldOwner, address newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "owner only");
        _;
    }

    constructor(address _stakingToken, address _rewardsToken, uint256 _rewardRate) {
        require(_stakingToken != address(0) && _rewardsToken != address(0), "zero addr");
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        owner = msg.sender;
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }

    /* ========== VIEWS ========== */

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) return rewardPerTokenStored;
        return rewardPerTokenStored + ( (block.timestamp - lastUpdateTime) * rewardRate * 1e18 ) / totalSupply;
    }

    function earned(address account) public view returns (uint256) {
        return (balanceOf[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) ) / 1e18 + rewards[account];
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

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        _updateReward(msg.sender);

        // transfer tokens to contract
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "transfer failed");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(amount > 0, "Cannot withdraw 0");
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        _updateReward(msg.sender);

        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        require(stakingToken.transfer(msg.sender, amount), "transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant {
        _updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            require(rewardsToken.transfer(msg.sender, reward), "reward transfer failed");
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

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero addr");
        emit OwnerTransferred(owner, newOwner);
        owner = newOwner;
    }
}
