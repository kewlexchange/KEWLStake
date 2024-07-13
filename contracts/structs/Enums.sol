// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
    enum TAssetType {
        // 0: ETH on mainnet, MATIC on polygon, etc.
        NATIVE,
        // 1: ERC20 items (ERC777 and ERC20 analogues could also technically work)
        ERC20,
        // 2: ERC721 items
        ERC721,
        // 3: ERC1155 items
        ERC1155
    }

    enum StakePoolPeriodInfo{
        MONTHLY, //Aylık
        QUARTER_OF_YEAR, // 3 Aylık
        HALF_OF_YEAR, // 6 Aylık
        YEAR_ONE, // 1 Yıllık
        YEAR_TWO, // 2 Yıllık
        YEAR_THREE, // 3 Yıllık
        YEAR_FOUR, // 4 Yıllık
        YEAR_FIVE // 5 Yıllık
    }