// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "../interfaces/IKERC20.sol";
import {StakingInfo, PoolInfo} from "../structs/Structs.sol";
contract Pool {
    error InvalidAction();

    event HANDLE_STAKE(
        address indexed user,
        uint256 stakingId,
        uint256 amount,
        uint256 timestamp
    );
    event HANDLE_UNSTAKE(
        address indexed user,
        uint256 stakingId,
        uint256 amount,
        uint256 reward,
        uint256 timestamp
    );
    event HANDLE_HARVEST(
        address indexed user,
        uint256 stakingId,
        uint256 amount,
        uint256 reward,
        uint256 timestamp
    );

    mapping(address => StakingInfo[]) userStakingInfo;
    PoolInfo private poolInfo;
    address private constant OWNER = 0x700Ff3371Befd82FdD207Ce40B866905B1B9990b;

    modifier onlyFactory() {
        if (msg.sender != poolInfo.factory) {
            revert InvalidAction();
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != OWNER) {
            revert InvalidAction();
        }
        _;
    }

    constructor(
        address _factory,
        address _token,
        address _reward,
        uint256 _amount,
        uint256 expiredAt
    ) {
        poolInfo.valid = true;
        poolInfo.factory = _factory;
        poolInfo.totalReward = _amount;

        poolInfo.expiredAt = expiredAt;
        poolInfo.createdAt = block.timestamp;
        poolInfo.rewardedAt = block.timestamp;
        poolInfo.rewardPerSecond = _amount / ((expiredAt - block.timestamp));

        poolInfo.rewardToken = IKERC20(_reward);
        poolInfo.stakeToken = IKERC20(_token);


        poolInfo.tokenName = poolInfo.stakeToken.name();
        poolInfo.tokenSymbol = poolInfo.stakeToken.symbol();
        poolInfo.tokenDecimals = poolInfo.stakeToken.decimals();

        poolInfo.rewardName = poolInfo.rewardToken.name();
        poolInfo.rewardSymbol = poolInfo.rewardToken.symbol();
        poolInfo.rewardDecimals = poolInfo.rewardToken.decimals();

        poolInfo.tokenPrecision = uint256( 10 ** (uint256(30) -  poolInfo.rewardDecimals));
        poolInfo.pool = address(this);

        poolInfo.name = string(
            abi.encodePacked(
                "KEWL - STAKE ",
                 poolInfo.tokenName,
                " EARN ",
                 poolInfo.rewardSymbol
            )
        );
        poolInfo.symbol = string(
            abi.encodePacked(
                "KEWL - ",
                poolInfo.tokenSymbol,
                "x",
                 poolInfo.rewardSymbol
            )
        );
    }

    function name() public view returns (string memory) {
        return poolInfo.name;
    }

    function symbol() public view returns (string memory) {
        return poolInfo.symbol;
    }

    function updateRewardDebt(uint256 amount, uint256 stakingId, address user) internal {
        StakingInfo storage stakingInfo = userStakingInfo[user][stakingId];
        if(!stakingInfo.valid){
            revert InvalidAction();
        }
        stakingInfo.joinedAt = block.timestamp;
        stakingInfo.unlockedAt = block.timestamp + 7 days;
        stakingInfo.rewardDebt = amount == 0 ? 0 : (amount * poolInfo.accumulatedTokenPerShare) /  poolInfo.tokenPrecision;
    }

    function updateRewardPerSecond(uint256 rewardPerSecond, bool update) external onlyOwner{
        poolInfo.rewardPerSecond = rewardPerSecond;

        if(update){
            massUpdatePools();
        }
    }


    function calculateMultiplier(uint256 _from,uint256 _to) internal view returns (uint256) {
        _from = _from > poolInfo.createdAt ? _from : poolInfo.createdAt;
        if (_from > poolInfo.expiredAt || _to < poolInfo.createdAt) {
            return 0;
        }
        if (_to > poolInfo.expiredAt) {
            return poolInfo.expiredAt - _from;
        }
        return _to - _from;
    }

    function massUpdatePools() internal {
        if ((poolInfo.totalDeposit > 0) && (block.timestamp > poolInfo.rewardedAt)) {
            uint256 multiplier = calculateMultiplier(poolInfo.rewardedAt, block.timestamp);
            uint256 calculatedRewardAmount = multiplier * poolInfo.rewardPerSecond;
            poolInfo.accumulatedTokenPerShare = poolInfo.accumulatedTokenPerShare + (calculatedRewardAmount * poolInfo.tokenPrecision) / (poolInfo.totalDeposit-poolInfo.totalWithdraw);
        }
        poolInfo.rewardedAt = block.timestamp;
    }

    function pendingRewards(address user,uint256 stakingId) public view returns (uint256) {
        StakingInfo storage stakingInfo = userStakingInfo[user][stakingId];
        if (!stakingInfo.valid) {
            return 0;
        }

        if (stakingInfo.leavedAt > 0) {
            return 0;
        }

        uint256 accRewardPerShare = poolInfo.accumulatedTokenPerShare;
        if (block.timestamp > poolInfo.rewardedAt && poolInfo.totalDeposit > 0) {
            uint256 multiplier = calculateMultiplier(stakingInfo.joinedAt,block.timestamp);
            uint256 totalReward = multiplier * poolInfo.rewardPerSecond;
            accRewardPerShare = accRewardPerShare + (totalReward * poolInfo.tokenPrecision) / (poolInfo.totalDeposit-poolInfo.totalWithdraw);
        }
        uint256 rewardDebt = stakingInfo.rewardDebt;
        uint256 depositAmount = stakingInfo.depositAmount;
        uint256 rewardAmount = ((depositAmount * accRewardPerShare) / (poolInfo.tokenPrecision)) - rewardDebt;
        return rewardAmount;
    }

    function updateAndPayOutPendingRewards(address user, uint256 stakingId) internal {
            uint256 rewardAmount = pendingRewards(user,stakingId);
            if(rewardAmount > 0){
                poolInfo.rewardToken.transfer(user, rewardAmount);
                poolInfo.totalRewardWithdraw += rewardAmount;
                StakingInfo storage stakingInfo = userStakingInfo[user][stakingId];
                stakingInfo.totalClaimedRewardAmount += rewardAmount;
            }
    }


    function getPoolInfo() external view returns(PoolInfo memory){
        return poolInfo;
    }

    function stake(address _user, uint256 _amount) external onlyFactory {
        uint256 stakingId = userStakingInfo[_user].length;
        userStakingInfo[_user].push(
            StakingInfo({
                valid: true,
                id: stakingId,
                depositAmount: _amount,
                totalClaimedRewardAmount: 0,
                rewardDebt: 0,
                createdAt:block.timestamp,
                joinedAt: block.timestamp,
                rewardedAt: block.timestamp,
                unlockedAt: block.timestamp + 7 days,
                leavedAt: 0,
                pendingRewards:0,
                user: _user
            })
        );
        poolInfo.totalDeposit += _amount;
        poolInfo.joinedUserCount += 1;
        updateRewardDebt(_amount, stakingId, _user);
        massUpdatePools();
        emit HANDLE_STAKE(_user, stakingId, _amount, block.timestamp);
    }

    function unstake(address _user, uint256 stakingId) external onlyFactory {
        StakingInfo storage stakingInfo = userStakingInfo[_user][stakingId];
        if (!stakingInfo.valid) {
            revert InvalidAction();
        }

        if (stakingInfo.leavedAt > 0) {
            revert InvalidAction();
        }


        uint256 rewardAmount = pendingRewards(_user, stakingId);
        poolInfo.stakeToken.transfer(
            stakingInfo.user,
            stakingInfo.depositAmount
        );
        
        massUpdatePools();
        updateAndPayOutPendingRewards(_user,stakingId);
        updateRewardDebt(0,stakingId,_user);

        stakingInfo.valid = false;
        poolInfo.totalWithdraw += stakingInfo.depositAmount;
        poolInfo.leavedUserCount += 1;
        stakingInfo.leavedAt = block.timestamp;

        emit HANDLE_UNSTAKE(
            _user,
            stakingInfo.id,
            stakingInfo.depositAmount,
            rewardAmount,
            block.timestamp
        );
    }

    function harvest(address _user, uint256 stakingId) external onlyFactory {
        StakingInfo storage stakingInfo = userStakingInfo[_user][stakingId];
        if (!stakingInfo.valid) {
            revert InvalidAction();
        }

        if (stakingInfo.leavedAt > 0) {
            revert InvalidAction();
        }

        massUpdatePools();
        uint256 rewardAmount = pendingRewards(_user,stakingId);
        updateAndPayOutPendingRewards(_user,stakingId);
        updateRewardDebt(stakingInfo.depositAmount,stakingId,_user);

        emit HANDLE_HARVEST(
            _user,
            stakingInfo.id,
            stakingInfo.depositAmount,
            rewardAmount,
            block.timestamp
        );
    }

    function getUserInfo(address _user) external view returns(StakingInfo[] memory stakings){
        uint256 length = userStakingInfo[_user].length; 
        stakings =  new StakingInfo[](length);

        for(uint256 i; i <length; ){
            stakings[i] = userStakingInfo[_user][i];
            stakings[i].pendingRewards =  pendingRewards(_user,i); 
            unchecked{
                i++;
            }
        }
        return stakings;
    }

    function rewardBalance() external view returns(uint256){
        return poolInfo.rewardToken.balanceOf(address(this));
    }

    function tokenBalance() external view returns(uint256){
        return poolInfo.rewardToken.balanceOf(address(this));
    }

    // Emergency Functions
    function recoverETH() external onlyOwner{
        uint256 amount =  address(this).balance;
        if(amount > 0){
            address to = msg.sender;
            (bool success, ) = to.call{value: amount}(new bytes(0));
            require(success);
        }
    }

    function recoverCustomETHAmount(uint256 amount, address receiver) external onlyOwner{
        if(receiver == address(0)){
            revert InvalidAction();
        }
        if( (amount > 0)  && (amount <= address(this).balance)){
            (bool success, ) = receiver.call{value: amount}(new bytes(0));
            require(success);
        }
    }

    function recoverERC(address _tokenAddr) external onlyOwner{
        if(_tokenAddr != address(0)){
            uint256 amount = IKERC20(_tokenAddr).balanceOf(address(this));
            if(amount > 0){
                IKERC20(_tokenAddr).transfer(msg.sender, amount);
            }
        }
    }

    function recoverERCCustom(address _tokenAddr, uint256 _amount, address _to) external onlyOwner{
        if(_to == address(0)){
            revert InvalidAction();
        }
        if(_tokenAddr == address(0)){
            revert InvalidAction();
        }
        if(_amount > 0){
            IKERC20(_tokenAddr).transfer(_to, _amount);
        } 
    }
}
