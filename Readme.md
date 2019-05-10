Module 7 - Remittance
---------------------

### Story:
**Create a smart contract whereby:**
* There are three people: **Alice, Bob & Carol**.
    * Alice wants to send funds to Bob, but she only has ether 
    & Bob does not care about **Ethereum** and wants to be paid in local currency.
    * luckily, Carol runs an exchange shop that converts ether to local currency.
* Therefore, to get the funds to Bob, Alice will allow the funds to be transferred through Carol's exchange shop. 
* Carol will collect the ether from Alice and give the local currency to Bob.

**The steps involved in the operation are as follows:**
1. Alice creates a *Remittance* contract with *Ether* in it and a *puzzle*.
    - Alice sends a one-time-password to Bob; over SMS, say.
    - Alice sends another one-time-password to Carol; over email, say.
2. Bob treks to Carol's shop.
    - Bob gives Carol his one-time-password.
3. Carol submits both passwords to Alice's remittance contract.
    - Only when both passwords are correct does the contract yield the Ether to Carol.
    - Carol gives the local currency to Bob.
4. Bob leaves.
5. Alice is notified that the transaction went through.
Since they each have only half of the puzzle, Bob & Carol need to meet in person so they can supply both passwords 
to the contract. This is a security measure. It may help to understand this use-case as similar 
to a 2-factor authentication.

### Setting up your environment 
* Check if Node.js and truffle are installed by typing in your 
terminal: 
    * `node -v` 
    * and then `truffle version`
* Install [Ganache](https://truffleframework.com/ganache)
* Initialize truffle `truffle init` to build a basic Truffle project
* Create package.json file  by typing `npm init`
* Install OpenZeeplin library `npm install openzeppelin-solidity`
* Write contracts in the contracts folder.
* Modify `truffle-config.js` file (`truffle.js` for Mac). 
* Run `truffle compile` to compile the contract
    * Please check the required version of the Solidity compiler (for all .sol files including imported libraries) 
    * by running `truffle version`. 
    * If needed, run `npm uninstall -g truffle` 
    * and the `npm install -g truffle`
* Create `2_splitter_migration.js` in the migrations folder.
