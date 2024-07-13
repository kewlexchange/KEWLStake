// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.20;
/// @title Interface for WETH9
interface IWETH {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;

    function transferFrom(address src, address dst, uint wad) external;
    function transfer(address dst, uint wad) external;
    }