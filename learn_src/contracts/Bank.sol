// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


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
    
    function addBalance() public payable {
        balances[msg.sender] = msg.value;
        totalContractBalance = totalContractBalance + msg.value;
        
        // send ethers to mint()
        ceth.mint{value: msg.value}(); 
    }
    
    function getBalance(address userAddress) public view returns(uint256) {
        
    }
    
    function withdraw() public payable {
        
        //CAN YOU OPTIMIZE THIS FUNCTION TO HAVE FEWER LINES OF CODE?
        
    }
    
    function addMoneyToContract() public payable {
        totalContractBalance += msg.value;
    }

    
}

