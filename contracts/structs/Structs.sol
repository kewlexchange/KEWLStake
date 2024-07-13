// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./Enums.sol";
import "../interfaces/IKERC20.sol";

    struct Token{
        bool exists;
        uint256 decimals;
        string name;
        string symbol;
    }


    struct PoolEntry{
      uint256 id;
      address pool;
    }

    struct PoolInfo {
        bool valid;

        uint256 joinedUserCount;
        uint256 leavedUserCount;
      
        uint256 totalReward;
        uint256 totalRewardWithdraw;
        uint256 totalDeposit;
        uint256 totalWithdraw;
        uint256 rewardPerSecond;
        uint256 accumulatedTokenPerShare;
        uint256 tokenPrecision;
        uint256 createdAt;
        uint256 expiredAt;
        uint256 rewardedAt;

        uint256 tokenDecimals;
        uint256 rewardDecimals;

        address factory;
        address pool;
        
        string name;
        string symbol;

        string tokenName;
        string rewardName;

        string tokenSymbol;
        string rewardSymbol;

        IKERC20 rewardToken;
        IKERC20 stakeToken;
    }

    struct StakingInfo {
        bool valid;
        uint256 id;
        uint256 depositAmount;
        uint256 totalClaimedRewardAmount;
        uint256 rewardDebt;
        uint256 createdAt;
        uint256 joinedAt;
        uint256 rewardedAt;
        uint256 unlockedAt;
        uint256 leavedAt;
        uint256 pendingRewards;
        address user;
    }

