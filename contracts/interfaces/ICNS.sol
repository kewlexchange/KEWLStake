// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.20;
/// @title Interface for WETH9
interface ICNS {
    function isRegistered(address addr) external view returns(bool,address);
}