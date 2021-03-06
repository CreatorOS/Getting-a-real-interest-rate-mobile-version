// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

interface cETH {
    
    // define functions of COMPOUND we'll be using
    
    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    
    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}


contract SmartBankAccount {


    uint totalContractBalance = 0;
    
    address COMPOUND_CETH_ADDRESS = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    function getContractBalance() public view returns(uint){
        return totalContractBalance;
    }
    
    mapping(address => uint) balances;
    mapping(address => uint) depositTimestamps;
    
    function addBalance() public payable {
        uint256 cEthOfContractBeforeMinting = ceth.balanceOf(address(this)); //this refers to the current contract

        
        // send ethers to mint()
        ceth.mint{value: msg.value}();

        uint256 cEthOfContractAfterMinting = ceth.balanceOf(address(this)); // updated balance after minting
        uint cEthOfUser = cEthOfContractAfterMinting - cEthOfContractBeforeMinting; // the difference is the amount that has been created by the mint() function

        balances[msg.sender] = cEthOfUser;
        

        
    }
    
    function getBalance(address userAddress) public view returns(uint256) {
        uint balance = balances[userAddress] * ceth.exchangeRateStored() / 1e18;
        console.log('Balance: ', balance);
        return balance;
    }
    
    function withdraw() public payable {
        
        address payable withdrawTo = payable(msg.sender);
        uint amountToTransfer = getBalance(msg.sender);
        
        ceth.redeem(balances[msg.sender]);
       
        balances[msg.sender] = 0;

        withdrawTo.transfer(amountToTransfer);
    }
    
    function addMoneyToContract() public payable {
        
    }

    receive() external payable {

    }   
    
}


