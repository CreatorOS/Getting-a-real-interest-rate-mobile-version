# Getting a real interest rate

In the last Quest on [Questbook.app](https://questbook.app) we created a smart account, where anyone could add a balance and start earning interest. If you’ve not done that yet, you should go complete that Quest first, because that is what we're going to use in this Quest.

There was a major flaw in the previous contract we wrote. We did provide an interest for all deposits made on our account, but the interest was coming from the pocket of the creator of the contract (you). If you remember, you had to add some Ethers additionally to make withdrawals with interest possible.

But, that is not how real banks work. Banks are able to give interest on deposits based on the interests they earn by lending loans. How do we do that?

Fortunately there is a project called Compound. Compound is a multi Billion dollar project that is nothing but a few smart contracts written that facilitates giving loans and earning interest. So instead of re-inventing the wheel, we will use Compound and earn real interest using their contracts. That’s the beauty of web3. You can build on top of other’s contracts without their permission!

Just to give a background on Compound, Compound has defined a set of rules using smart contracts for people to park money and for other people to take loans and pay interest. That way people who have parked money earn interest. So we’ll collect ethers from our users and park it on compound. Then when they want to withdraw, we’ll take the interest from Compound and give it to the user.

## Finding the address of compound contract

Let’s go to compound’s official documentation

[https://compound.finance/docs](https://compound.finance/docs)

If you scroll to the bottom it shows you the address of all the contracts that have been deployed by Compound. There is a section called networks.

You’ll see multiple networks like “Mainnet”, “Rinkeby”, … “Ropsten”.

Mainnet is the actual Ethereum. There are other test nets of Ethereum where developers can play around before deploying to actual Ethereum (mainnet).

Under mainnet you will see many rows. Look for cETH.

Compound allows you to deposit various crypto currencies and earn interest on them. We will be using only Ethers as the currency people can deposit money to our smart bank account.

Copy the address against cETH. (stands for compound-ETH). Copy this address and visit :

[https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5](https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5)

This will open the contract on EtherScan. Etherscan is an important tool you need to be aware of when operating on Ethereum. EtherScan is a way to look at all the data on Ethereum. All the contracts, all the transactions, all the function calls are all public on Ethereum and accessible from this website.

By default, the transactions tab is selected.

Here you can see all the transactions that have happened on Compound. Anyone who is depositing money, withdrawing or loaning is all publicly accessible here.

You’ll also see a tab called Contract. Tap on that to see the contract itself. You’ll see the source code for CEther.sol.

Now that you have done Quest 1, you should be able to read what is going on in the contract. There are other contracts that are referenced by this contract using import statements on the top of the file, much like python. You’ll see all those sol files listed below CEther.sol as well.

I don’t really want you to understand the logic of how Compound works yet. All that I want you to notice is that the code doesn’t look very different from the code that we’ve written already! A few hundred lines of Solidity code managing a few billions of dollars! Check out the balance of the top of the link on EtherScan :)

Here’s the only thing you need to know about how Compound works. You give ETH to Compound, it gives you cETH back. When you return the cETH to Compound, Compound gives you ETH back. The number of ETH you’ll get per cETH keeps increasing with time, because Compound is earning interest from the loans it’s giving out. So, the longer you wait, the more ETH you’ll get back for the same cETH you return to Compound. You can find more information on how compound works on their docs, but this is all that you need to know right now for this quest.

## Integrating with Compound

First we will define what are the functions of Compound that we want to use.

We’ll do that by adding an interface. This interface defines what are the functions we’re going to use from Compound. We can reference only public functions from Compound’s contract. You can look at the source code for what mint() does on etherscan ([https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5/#code](https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5/#code)).

```
interface cETH {

    // define functions of COMPOUND we'll be using

    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound

    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint);
    function balanceOf(address owner) external view returns (uint256 balance);
}
```

You will notice that, like we do in interfaces, we’re defining only the signatures of the functions we want to call. I’ve just copy pasted the signatures of the functions that we’ll use to deposit money, withdraw money and calculate our current interest that has been accrued.

Then we initialize the compound contract itself.

```
cETH ceth = cETH(COMPOUND_CETH_ADDRESS);
```

To initialize the contract we must create an object using the interface we created above and the address of the compound contract.

By doing so, we’ve told Solidity as to what functions we will be using and which smart contract we’re targeting.

Quick refresher, every smart contract has an account just like a user. Each of these accounts have an address by which they can be identified and can hold money.

We have initialized the variable COMPOUND_CETH_ADDRESS with the address of the cETH contract on Compound which is on mainnet.

In our Mobile Code Editor we are going to be interacting with the mainnet itself.
But if you were to use other editor environment you would be using a testing network like Ropsten or Rinkeby. Because it costs real ether to interact with the mainnet.

We can use mainnet in our Mobile Code Editor because we are doing something called Mainnet forking to simulate the same state as mainnet locally.

So, now we’re ready to start writing code using compound. That’s what we’ll do next.

## Depositing money to Compound

Let’s start using the functions that we’ve defined in the interface.

We’ll modify our addBalance method.

The way to deposit ethers to compound is to use the mint() function.

If you notice the signature of this function in our interface, it is a payable function. That means we can send ethers to this function.

```
// send ethers to mint()
ceth.mint{value: msg.value}();
```

Note that we’re not only calling `ceth.mint()` but also sending ethers by setting the value for this function call by using `{ value : msg.value }`.

This means that we will send all the ethers that the user sends to addBalance directly to compound.

Before we change the other two functions getBalance and withdraw, we need to understand how Compound works.

When you deposit ETH using the `mint()` function, Compound generates some cETH for you. You can then give cETH to Compound and get back ETH.

Compound exposes how many cETH a certain user holds using the function balanceOf. It also exposes the number of ETH you can withdraw per cETH using exchangeRateStored. exchangeRateStored keeps steadily increasing, that’s how you earn interest on Compound. 1cETH keeps getting more valuable over time. If it returns 1ETH right now it will yield 1.00….01 ETH a couple minutes later.

We want to abstract the user from all these complications. They needn’t know that we’re using Compound internally to generate the interest. So we will take care of this calculation for them.

The current balance that a user can withdraw is the number of cETH they own multiplied by the exchange rate. Solidity doesn’t support floats and doubles. So exchangeRateStored is represented as an integer that must be divided by 10^18.

Let’s modify the getBalance function.

```
function getBalance(address userAddress) public view returns(uint256) {
    uint balance = ceth.balanceOf(userAddress) * ceth.exchangeRateStored() / 1e18;
    console.log('Balance: ', balance);
    return balance;
}
```

`ceth.balanceOf()` gives us the number of cETH the user owns

`ceth.exchangeRateStored()` gives us the number of ETH we’ll get per cETH

## Testing compound functions

Now that we have written functions to add balance and get balance, let's test them.
Click on `Run` button.

In the output of the test 2, you should see that the balance is zero. Oops! Why is that? Where did our money go?

Here is one more concept to understand. Compound doesn’t know who sent money to addBalance() on our contract. Someone sent money to our contract and our contract sent money to compound using ceth.mint{ value: msg.value }();

So all that compound sees is that money has come from the account of our contract. That means it will update the balance associated with the address of the account of our contract. Let’s see if that is true.

So, any money that the contract puts into compound starts attracting an interest.

So we need to calculate how much interest our users get so as to protect our users from the hassles of how compound works. All they need to know is they put in money, and they can withdraw their money safely and earn an interest.

## Maintaining compound tokens' state

Let's recap how compound works

When someone deposits money to compound using ceth.mint() compound takes ETH and allots cETHs to the user.

Then the user can deposit the cETH and claim the ETH back.

So on our contract we need to maintain how many cETHs each user owns so that when that person decides to withdraw, we’re able to claim the appropriate amount from compound and transfer that to the user.

Compound’s mint() doesn’t return us the updated balance. So we need a work around.

We know that when we call the mint() function from our contract’s add balance, compound updates the number of cETH tokens owned by our contract. Compound has absolutely no knowledge of our users. So, we’ll calculate the number of tokens owned by the user of our contract by checking the difference between our contract’s balance of cETH before the mint() transaction and after. The difference is the number of cETH tokens that have been minted because of the user sending money to addBalance. We’ll update balances for that user’s cETH based on this difference.

So now our balances\[\] mapping doesn’t contain the ETH balances, but rather cETH balances.

Let's modify `getBalance()` to fetch cETH balance of an address from `balances` mapping and calculate eth balance based on that.

```
uint balance = balances[userAddress] * ceth.exchangeRateStored() / 1e18;
```

We also need to rewrite our withdraw function to use cETHs and convert them into ETH so that our users never come to know anything about cETH. Ever.

Why don’t you try writing the withdraw function yourself? Feel free to check out the redeem function at [https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5\#code](https://etherscan.io/address/0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5#code)

Also look at this documentation of Compound to see how to use Redeem, before we tell you how to use it : [https://compound.finance/docs/ctokens](https://compound.finance/docs/ctokens)

Once done, check out how you did in the next subquest.

## Withdraw function

Here's what the withdraw function should look like.

```
function withdraw() public payable {

    address payable withdrawTo = payable(msg.sender);
    uint amountToTransfer = getBalance(msg.sender);

    ceth.redeem(balances[msg.sender]);

    balances[msg.sender] = 0;

    withdrawTo.transfer(amountToTransfer);
}
```

The important part here passing balances[msg.sender] as the parameter to ceth.redeem() to only redeem the cETH tokens that the user owns.

To be able to receive money while withdrawing you will need to define a `receive()` function in your contract so that Compound can send money to your contract and thereby to the user withdrawing.

## Next steps

Right now we’ve allowed for people to either deposit or withdraw once. What if i want to deposit in parts? Or withdraw in parts? Can you modify this contract to do that?

We leave this as an exercise for you to google and build yourself.
Try it out and send us what you built!

Feel free to discuss on our [Discord Server](https://discord.gg/vhQmtMhCwX)
