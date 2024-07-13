// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "../libs/Modifiers.sol";
import {LibNFTReceiver} from "../libs/LibNFTReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault is LibNFTReceiver, Modifiers{
    function withdrawETH() external onlyOwner{
        uint256 amount =  address(this).balance;
        if(amount > 0){
            address to = msg.sender;
            (bool success, ) = to.call{value: amount}(new bytes(0));
            require(success);
        }
    }

    function withdrawCustomETHAmount(uint256 amount, address receiver) external onlyOwner{
        if(receiver == address(0)){
            revert InvalidAction();
        }
        if( (amount > 0)  && (amount <= address(this).balance)){
            (bool success, ) = receiver.call{value: amount}(new bytes(0));
            require(success);
        }
    }

    function withdrawERC(address _tokenAddr) external onlyOwner{
        if(_tokenAddr != address(0)){
            uint256 amount = IERC20(_tokenAddr).balanceOf(address(this));
            if(amount > 0){
                IERC20(_tokenAddr).transfer(msg.sender, amount);
            }
        }
    }

    function withdrawCustomERC(address _tokenAddr, uint256 _amount, address _to) external onlyOwner{
        if(_to == address(0)){
            revert InvalidAction();
        }
        if(_tokenAddr == address(0)){
            revert InvalidAction();
        }
        if(_amount > 0){
            IERC20(_tokenAddr).transfer(_to, _amount);
        }
        
    }

}
