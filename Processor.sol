// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./Address.sol";
import "./Ownable.sol";

contract PaymentProcessor is Ownable {
    using Address for address;
    
    address payable thisContract;
    
    address[] public _signers = [
  	    0x4CC8DE5bfB3Ee7bb6a6e8474AdC7BE21D75Bd856,
  	    0x762986B8EE42642f4e134b86fD04E2573f4E64ED,
  	    0xF06BF61831C996CCFFAF081b8A3cF6eFDBd86275,
  	    0xE2c2Ce56F0b18c8Bc4a524E4491796BF1Ce02F31
  	    ];
    
    mapping(address => bool) public _signatureStatus;
    
    constructor() {
        for(uint256 i = 0; i < _signers.length; i++) {
            _signatureStatus[_signers[i]] = false;
        }
    }
    
    fallback() external payable {

  	}
  	
  	function setThisContract(address payable _address) external onlyOwner {
  	    thisContract = _address;
  	}
  	
  	function loadContract(uint256 _amountInWei) external payable {
  	    require(thisContract.send(msg.value), "RECIEVER MUST BE THE CONTRACT");
  	    thisContract.call{value : _amountInWei};
  	}
  	
  	function viewBalance() external view returns(uint256) {
  	    return thisContract.balance;
  	}
  	
  	function viewSignStatus(address _signer) external view returns(bool) {
  	    return _signatureStatus[_signer];
  	}
  	
  	function signForPayment() external {
  	    for(uint256 i = 0; i < _signers.length; i++) {
  	        if(msg.sender == _signers[i]) {
  	            _signatureStatus[_signers[i]] = true;
  	        }
  	    }
  	}
  	
  	function viewThisContract() external view returns(address) {
  	    return thisContract;
  	}
  	
  	function releasePayment(address payable[] calldata _recievers, uint256[] calldata _values) external {
  	    
  	    uint256 trueCount = 0;
  	    
  	    for(uint256 i = 0; i < _signers.length; i ++) {
  	        if(_signatureStatus[_signers[i]] == true) {
  	            trueCount = trueCount + 1;
  	        }
  	    }
  	    
  	    for(uint256 j = 0; j < _signers.length; j++) {
  	        _signatureStatus[_signers[j]] = false;
  	    }
  	    
  	    require(viewSendAbility() == true, "NOT AUTHORIZED TO SEND");
  	    require(trueCount >= 3, "NOT ENOUGH SIGNERS APPROVED");
  	    require(_recievers.length == _values.length, "INCORRECT DATA PROVIDED");
  	  
  	    for(uint256 ii = 0; ii < _recievers.length; ii++) {
  	        Address.sendValue(_recievers[ii], _values[ii]);
  	    }
  	}
  	
  	function viewSendAbility() public view returns(bool) {
  	    for(uint256 i = 0; i < _signers.length; i ++) {
  	        if(msg.sender == _signers[i]) {
  	            return true;
  	        }
  	    }
  	    return false;
  	}
  	
}
