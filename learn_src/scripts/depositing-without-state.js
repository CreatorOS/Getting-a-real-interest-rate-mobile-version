// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require('hardhat');
const hre = require('hardhat');
const BN = require('bn.js');

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [deployer] = await ethers.getSigners();
  const ContractFactory = await hre.ethers.getContractFactory('SmartBankAccount');
  const contract = await ContractFactory.deploy();

  await contract.deployed();

  console.log('SmartBankAccount deployed to:', contract.address);
  try {
    await contract.addBalance({ value: ethers.utils.parseEther('1').toHexString() });
    const userBalance = new BN((await contract.getBalance(deployer.address)).toString());
    console.log('User BankAccount balance:', userBalance.toString());
    if (userBalance.toString() === '0') {
      console.log('Test Passed');
      process.exit(0);
    } else {
      console.log('Test Failed');
      process.exit(1);
    }
  } catch (error) {
    console.log('Error:', error);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
