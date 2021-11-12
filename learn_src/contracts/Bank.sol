// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface cETH {
    // define functions of COMPOUND we'll be using

    function mint() external payable; // to deposit to compound

    function redeem(uint256 redeemTokens) external returns (uint256); // to withdraw from compound

    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);
}

contract SmartBankAccount {
    uint256 totalContractBalance = 0;

    address COMPOUND_CETH_ADDRESS = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    function getContractBalance() public view returns (uint256) {
        return totalContractBalance;
    }

    mapping(address => uint256) balances;

    function addBalance() public payable {
        balances[msg.sender] = msg.value;
    }

    function getBalance(address userAddress) public view returns (uint256) {
        // write logic to get balance of userAddress
    }

    function withdraw() public payable {
        address payable withdrawTo = payable(msg.sender);
        uint256 amountToTransfer = getBalance(msg.sender);

        // write redeem logic here

        balances[msg.sender] = 0;

        withdrawTo.transfer(amountToTransfer);
    }

    function addMoneyToContract() public payable {}
}
