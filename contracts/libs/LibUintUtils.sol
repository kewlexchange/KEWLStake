// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

library LibUintUtils {
    bytes16 private constant HEX_SYMBOLS = '0123456789abcdef';

    function toString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            bstr[--k] = bytes1((48 + uint8(_i - (_i / 10) * 10)));
            _i /= 10;
        }

        return string(bstr);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0x00';
        }

        uint256 length = 0;

        for (uint256 temp = value; temp != 0; temp >>= 8) {
        unchecked {
            length++;
        }
        }

        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length)
    internal
    pure
    returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';

    unchecked {
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
    }

        require(value == 0, 'UintUtils: hex length insufficient');

        return string(buffer);
    }
}
