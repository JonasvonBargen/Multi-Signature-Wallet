// SPDX-License-Identifier: Unlicenseddddd
// This is my take on a simple Multi Signature Wallet. In this case this means that anyone can send funds (ether) to this contract, 
// but to withdraw money from the contract the transaction has to be signed by two of the owners. These rights can only be distributed by 
// the creator of the contract. 

pragma solidity ^0.8.0;

contract MultiSigWallet {

    // Setup for the Contract. #
    // Every submitted transaction is assigned an index (transactionCount) to reference that specific transaction in the following functions.
    // Mapping is set up to show who is an owner, hence can sign a transaction.
    address private _owner;
    mapping (address => bool) public owners;
    event deposition (address from, address to, uint amount);
    event transactionSigned (uint index, address signer);
    event transactionSubmitted (uint index, uint amount, address to);
    event transactionExecuted (uint index, uint amount, address to);
    uint public transactionCount = 0;

    // Most of the function in this contract should only be accessible by owners of the contract and that's what this modifier is for.
    modifier isOwner() {
        require(owners[msg.sender] == true, "You don't have the rights to do that!");
        _;
    }
    // Set the required signatures to 2.
    uint signaturesRequired = 2;
    //Set up a struct that stores the variables of a signle transaction and map an incrementing index to every transaction
    struct Transaction {
        uint amount;
        address to;
        address[] signers;
        bool transactionExecuted;
    }
    mapping (uint => Transaction) _transactions;
    // The following mapping is used to keep track of which address has already signed a transaction, 
    // so that a single address can't sign a transaction twice and therefore make it valid.
    mapping (address => mapping(uint => bool)) signerToTransaction;

    // Give the creator of the contract the owner rights.
    constructor() {
        _owner = msg.sender;
        owners[msg.sender] = true;
    }
    // Submit a transaction and sign it with the current address. 
    // Also emit the corresponding event and increment the transactionCount. 
    function submitTransaction (uint amount, address to) public isOwner{
            address[] memory emptyArray;
            _transactions[transactionCount] = Transaction(amount, to, emptyArray, false);
            _transactions[transactionCount].signers.push(msg.sender);
            signerToTransaction[msg.sender][transactionCount] = true;
            emit transactionSubmitted (transactionCount, amount, to);
            transactionCount += 1;

    }
    // Sign a transaction by referencing it with an index.
    // If the transaction is signed twice, the executeTransaction function is called.
    function signTransaction (uint index) public isOwner{
        require(signerToTransaction[msg.sender][index] != true, "You already signed this transaction");
        _transactions[index].signers.push(msg.sender);
        if(_transactions[index].signers.length == signaturesRequired) {
            executeTransaction(index);
        }
    }
    // Transaction of funds if the transaction is signed by enough addresses
    function executeTransaction(uint index) internal isOwner{
        payable(_transactions[index].to).transfer(_transactions[index].amount);
        _transactions[index].transactionExecuted=true;
        emit transactionExecuted(index, _transactions[index].amount, _transactions[index].to);
    }
    // Return addresses that have already signed a specific transaction
    function showSigners (uint index) public view returns (address[] memory){
        return _transactions[index].signers;
    }
    // Return data of a specific transaction.
    function showTransaction (uint index) public view returns(Transaction memory) {
        return _transactions[index];
    }

    
    // Return current balance of the contract.
    function getBalance () public view returns (uint) {
        return address(this).balance;
    }
    // Give an address the owner rights.
    function makeSomeoneOwner (address subject) isOwner public{
        require(owners[subject]=false, "Already an owner");
        owners[subject] = true;
    }

    receive() payable external {
        emit deposition(msg.sender, address(this), msg.value);
    }
    
}

