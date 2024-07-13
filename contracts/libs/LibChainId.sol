// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
library LibChainId {

    function getChainId() public view returns (uint256) {
        return block.chainid;
    }

    function safeGetChainId() public view returns (uint256) {
        uint256 chainId;
        (bool success, bytes memory data) = address(this).staticcall(abi.encodeWithSignature("getChainId()"));
        if (success) {
            chainId = abi.decode(data, (uint256));
        } else {
            chainId = 1907;
        }
        return chainId;
    }
}