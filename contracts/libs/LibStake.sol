// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../structs/Structs.sol";

library LibStake {

    struct Layout {
        uint256 poolId;
        PoolEntry[] pools;        
    }

    bytes32 internal constant STORAGE_SLOT = keccak256('com.kewl.stake.data');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
