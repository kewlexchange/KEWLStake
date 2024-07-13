// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "../structs/Structs.sol";
interface IPool {
    function getPoolInfo() external view returns(PoolInfo memory);
    function getUserInfo(address _user) external view returns(StakingInfo[] memory stakings);
}
