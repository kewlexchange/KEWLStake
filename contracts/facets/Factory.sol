// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "../libs/Modifiers.sol";
import "../libs/LibSettings.sol";
import "../libs/LibStake.sol";
import "../interfaces/IKERC20.sol";
import "../interfaces/IWETH.sol";
import "../structs/Structs.sol";
import "../interfaces/IPool.sol";
import "../tokens/Pool.sol";

contract Factory is Modifiers {


function createNativePool(address token, address reward, uint256 amount, uint256 expiredAt) internal{
    LibStake.Layout storage stakeInfo = LibStake.layout();

    IKERC20 rewardInfo = IKERC20(reward);

    if(reward != LibSettings.layout().WETH9){
        revert InvalidAction();
    }

    if(expiredAt <= block.timestamp){
        revert InvalidAction();
    }
    
    if(amount == 0){
        revert InvalidAmount();
    }

    if(msg.value != amount){
        revert InvalidAction();
    }

    IWETH(LibSettings.layout().WETH9).deposit{value: msg.value}();

    uint256 poolId = stakeInfo.pools.length;
    address pool = address(new Pool(address(this),token,reward,amount,expiredAt));

    if(!rewardInfo.transferFrom(msg.sender, pool, amount)){
        revert InvalidAction();
    }
    stakeInfo.pools.push(PoolEntry({id:poolId,pool:pool}));
}

function createTokenPool(address token, address reward, uint256 amount, uint256 expiredAt) internal{
    LibStake.Layout storage stakeInfo = LibStake.layout();
    IKERC20 tokenInfo = IKERC20(token);
    IKERC20 rewardInfo = IKERC20(reward);

    if(expiredAt <= block.timestamp){
        revert InvalidAction();
    }
    
    if(amount == 0){
        revert InvalidAmount();
    }

    if (rewardInfo.balanceOf(msg.sender) < amount) {
        revert InsufficientBalance();
    }

    if (rewardInfo.allowance(msg.sender, address(this)) < amount) {
        revert InsufficientAllowance();
    }


    uint256 poolId = stakeInfo.pools.length;
    address pool = address(new Pool(address(this),token,reward,amount,expiredAt));

    if(!rewardInfo.transferFrom(msg.sender, pool, amount)){
        revert InvalidAction();
    }
    stakeInfo.pools.push(PoolEntry({id:poolId,pool:pool}));
}

function create(address token, address reward, uint256 amount, uint256 expiredAt) external payable nonReentrant whenNotPaused whenNotContract(msg.sender){
        bool isNativeCurrency  =  msg.value > 0 ? true : false;


        if(isNativeCurrency){
            createNativePool(token,reward,amount,expiredAt);
        }else{
            createTokenPool(token,reward,amount,expiredAt);
        }
}

function fetch() external view returns(PoolInfo[] memory pools){
    LibStake.Layout storage libStake = LibStake.layout();
    uint256 length = libStake.pools.length;
    pools =  new PoolInfo[](length);
    for(uint256 i; i<length; ){
        pools[i] = IPool(libStake.pools[i].pool).getPoolInfo();
        unchecked{
            i++;
        }
    }
}

function allPoolsLength() external view returns(uint256){
    return LibStake.layout().pools.length;
}

function get(uint256 poolId) external view returns(PoolInfo memory){
    return IPool(LibStake.layout().pools[poolId].pool).getPoolInfo();
}

function stake(uint256 poolId, uint256 amount) payable external  nonReentrant whenNotPaused whenNotContract(msg.sender) {
        LibStake.Layout storage stakeInfo = LibStake.layout();
        if(stakeInfo.pools.length < poolId){
            revert InvalidAction();
        }
        PoolEntry memory poolEntry = stakeInfo.pools[poolId];
        PoolInfo memory pool = IPool(poolEntry.pool).getPoolInfo();

        if(!pool.valid){
            revert InvalidAction();
        }

        if(pool.expiredAt < block.timestamp){
            revert InvalidAction();
        }

        if (pool.stakeToken.balanceOf(msg.sender) < amount) {
            revert InsufficientBalance();
        }

        if (pool.stakeToken.allowance(msg.sender, address(this)) < amount) {
            revert InsufficientAllowance();
        }

        if(!pool.stakeToken.transferFrom(msg.sender, pool.pool, amount)){
            revert InvalidAction();
        }

        pool.totalDeposit+=amount;

        Pool(pool.pool).stake(msg.sender, amount);
}

function unstake(uint256 poolId, uint256 stakingId) external  nonReentrant whenNotPaused whenNotContract(msg.sender) {
    LibStake.Layout storage stakeInfo = LibStake.layout();
        if(stakeInfo.pools.length < poolId){
            revert InvalidAction();
        }
        PoolEntry memory poolEntry = stakeInfo.pools[poolId];
        PoolInfo memory pool = IPool(poolEntry.pool).getPoolInfo();

        if(!pool.valid){
            revert InvalidAction();
        }

        Pool(pool.pool).unstake(msg.sender,stakingId);
}

function pendingRewardsByPoolId(uint256 poolId, address user, uint256 stakingId ) external view returns(uint256){
        LibStake.Layout storage stakeInfo = LibStake.layout();
        if(stakeInfo.pools.length < poolId){
            revert InvalidAction();
        }
        PoolEntry memory poolEntry = stakeInfo.pools[poolId];
        PoolInfo memory pool = IPool(poolEntry.pool).getPoolInfo();

        if(!pool.valid){
            revert InvalidAction();
        }
        return Pool(pool.pool).pendingRewards(user,stakingId);
}

function pendingRewardsByPoolAddress(address pool, address user, uint256 stakingId ) external view returns(uint256){
        PoolInfo memory poolInfo = IPool(pool).getPoolInfo();
        if(!poolInfo.valid){
            revert InvalidAction();
        }
        return Pool(poolInfo.pool).pendingRewards(user,stakingId);
}

function harvest(uint256 poolId, uint256 stakingId) external  nonReentrant whenNotPaused whenNotContract(msg.sender) {
        LibStake.Layout storage stakeInfo = LibStake.layout();
        if(stakeInfo.pools.length < poolId){
            revert InvalidAction();
        }

        PoolEntry memory poolEntry = stakeInfo.pools[poolId];
        PoolInfo memory pool = IPool(poolEntry.pool).getPoolInfo();

        if(!pool.valid){
            revert InvalidAction();
        }

        return Pool(pool.pool).harvest(msg.sender,stakingId);
}

function getUserInfoByPoolAddress(address pool, address user) external view returns(StakingInfo[] memory stakingInfo){
    return IPool(pool).getUserInfo(user);
}

function getUserInfoByPoolId(uint256 poolId, address user) external view returns(StakingInfo[] memory stakingInfo){
    address pool = LibStake.layout().pools[poolId].pool;
    return IPool(pool).getUserInfo(user);
}

}
