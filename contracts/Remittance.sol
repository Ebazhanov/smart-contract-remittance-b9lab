pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Remittance is Ownable, Pausable {
    using SafeMath for uint;


    struct transactionList {
        uint transactionAddress;
        bool isTransaction;
        address initiator;
        address receiver;
        uint amount;
        uint expirationTime;
        bytes32 keyHash;
    }


    // functions below are responsible for transaction flow (is it a transaction, get transaction, new transaction  etc.)
    mapping(address => transactionList) public allTransactions;
    address[] public transactionFlow;

    function isTransaction(address transactionAddress) public view returns (bool isIndeed) {
        return allTransactions[transactionAddress].isTransaction;
    }

    function getTransactionCount() public view returns (uint transactionCount) {
        return transactionList.length;
    }

    function newTransaction(address transactionAddress, uint transactionData) public returns (uint rowNumber) {
        if (isTransaction(transactionAddress)) revert("transaction not created");
        allTransactions[transactionAddress].transactionData = transactionData;
        allTransactions[transactionAddress].isTransaction = true;
        return transactionList.push(transactionAddress) - 1;
    }

    function updateTransaction(address transactionAddress, uint transactionData) public returns (bool success) {
        if (!isTransaction(transactionAddress)) revert("transaction not updated");
        allTransactions[transactionAddress].transactionData = transactionData;
        return true;
    }

    mapping(uint => transactionList) flow;
    uint8 secondsPerBlock = 16; //average ETH blockctime completion is 15-17 secs
    uint counter;
    uint fee = 10;
    uint totalFees;

    event LogInitiateRemittance(uint identification, address indexed initiator,
        address recipient, uint amount, uint expirationTime);
    event LogWithdrawal(uint identification, address indexed receiver, uint amount);
    event LogSetFee(uint newFee);
    event LogWithdrawFees(uint counter, uint amountWithdrawn);
    event LogRefund(address initiator, address recipient, uint refund);


    constructor (uint initialFee) public {
        setFee(initialFee);
    }

    function initiateKeyHash(uint tFA, address recipient) external pure returns (bytes32 keyHash1) {
        keyHash1 = keccak256(abi.encodePacked(tFA, recipient));
        return keyHash1;
    }

    function initiateRemittance(address recipient, uint secondsInWeek, bytes32 keyHash1) public payable notPaused() {
        require(msg.value > fee, "Amount not sufficient");
        uint identification = counter++;
        uint amount = msg.value.sub(fee);
        //substract
        totalFees = totalFees.add(fee);
        uint expirationTime = block.number.add(secondsValid.div(secondsPerBlock));
        bytes32 keyHash2 = keccak256(abi.encodePacked(identification, keyHash1));
        flow[identification] = Remit({
            initiator : msg.sender,
            recipient : recipient,
            amount : amount,
            expirationTime : expirationTime,
            keyHash : keyHash2
            });
        emit LogCreateRemittance(identification, msg.sender, recipient, amount, expirationTime);
    }

    function withdrawFunds(uint identification, uint tFA) public notPaused() {
        bytes32 keyHash1 = keccak256(abi.encodePacked(tFA, msg.sender));
        require(keccak256(abi.encodePacked(identification, keyHash1)) == flow[identification].keyHash, "No access allowed");
        uint amountDue = flow[identification].amount;
        require(amountDue > 0, "Insufficient funds");
        flow[identification].amount = 0;
        emit LogWithdrawal(identification, msg.sender, amountDue);
        msg.sender.transfer(amountDue);
    }

    function claimBack(uint identification) public notPaused() {
        require(msg.sender == flow[identification].initiator, "Restricted access, initiator only");
        require(block.number > flow[identification].expirationTime, "Disabled until expires");
        uint amountDue = flow[identification].amount;
        require(amountDue > 0, "Insufficient funds");
        flow[identification].amount = 0;
        emit LogClaimBackExecuted(msg.sender, flow[identification].recipient, amountDue);
        msg.sender.transfer(amountDue);
    }

    function setFee(uint newFee) public onlyOwner() {
        fee = newFee;
        emit LogSetFee(newFee);
    }

    function withdrawFees() private onlyOwner {
        require(totalFees > 0, "Insufficient funds");
        uint amountDue = totalFees;
        totalFees = 0;
        emit LogWithdrawFees(counter, amountDue);
        msg.sender.transfer(amountDue);
    }
}



