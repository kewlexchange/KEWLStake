// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
interface IQuery {
    function getAssetURI(address _contract, uint256 _tokenId) external view returns(string memory);
    function getRoyaltiesInfo(address _contract,uint256 _tokenId,uint256 _salePrice) external view returns(address,uint256);
    function getPublicAssetURI(address _contract, uint256 _tokenId) external view returns(string memory);
    function getPublicRoyaltiesInfo(address _contract,uint256 _tokenId,uint256 _salePrice) external view returns(address,uint256);
}
