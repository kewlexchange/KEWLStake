// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "../libs/Modifiers.sol";
contract Settings is Modifiers {

    function setPaused(bool isPaused) external onlyOwner{
        LibSettings.layout().isPaused = isPaused;
    }

    function setKEWLToken(address _kewl) external isValidContract(_kewl) onlyOwner{
        LibSettings.layout().KEWLToken  = _kewl;
    }

    function setWETH9Token(address _weth9) external isValidContract(_weth9) onlyOwner{
        LibSettings.layout().WETH9  = _weth9;
    }

    function setCNS(address _cns) external isValidContract(_cns) onlyOwner{
        LibSettings.layout().CNS = _cns;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner{
        LibSettings.layout().feeReceiver  = _feeReceiver;
    }

    function setFee(uint256 _fee) external onlyOwner{
        LibSettings.layout().fee  = _fee;
    }


}
