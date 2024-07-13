// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {SolidStateDiamond} from "@solidstate/contracts/proxy/diamond/SolidStateDiamond.sol";
import '@solidstate/contracts/token/ERC1155/base/IERC1155Base.sol';
import '@solidstate/contracts/token/ERC721/base/IERC721Base.sol';
import '@solidstate/contracts/introspection/ERC165/base/ERC165BaseStorage.sol';

contract KEWL is SolidStateDiamond {
    using ERC165BaseStorage for ERC165BaseStorage.Layout;
    string private _name;
    string private _symbol;

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        ERC165BaseStorage.layout().supportedInterfaces[type(IERC1155).interfaceId] = true;
        ERC165BaseStorage.layout().supportedInterfaces[type(IERC721).interfaceId] = true;
    }
}