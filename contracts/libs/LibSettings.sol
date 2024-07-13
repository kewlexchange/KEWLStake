// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../structs/Structs.sol";

library LibSettings {

    struct Layout {
        bool isPaused;
        uint256 fee;
        uint256 loserReward;
        address KEWLToken; // TOKEN
        address CNS;
        address WETH9;
        address REWARDToken;
        address feeReceiver;
    }

    bytes32 internal constant STORAGE_SLOT = keccak256('com.kewl.stake.settings');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
