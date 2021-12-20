// SPDX-License-Identifier: Unlicensed
// This is my take on a simple Multi Signature Wallet. In this case this means that anyone can send funds (ether) to this contract,
// but to withdraw money from the contract the transaction has to be signed by two of the owners. These rights can only be distributed by
// the creator of the contract.

pragma solidity ^0.8.0;

contract MultiSigWallet {
    // Setup for the Contract. #
    // Every submitted transaction is assigned an index (transactionCount) to reference that specific transaction in the following functions.
    // Mapping is set up to show who is an owner, hence can sign a transaction.
    address public _owner;
    mapping(address => bool) public owners;
    event deposition(address from, address to, uint256 amount);
    event transactionSigned(uint256 index, address signer);
    event transactionSubmitted(uint256 index, uint256 amount, address to);
    event transactionExecuted(uint256 index, uint256 amount, address to);
    uint256 public transactionCount = 0;

    // Most of the function in this contract should only be accessible by owners of the contract and that's what this modifier is for.
    modifier isOwner() {
        require(
            owners[msg.sender] == true,
            "You don't have the rights to do that!"
        );
        _;
    }
    // Set the required signatures to 2.
    uint256 signaturesRequired = 2;
    //Set up a struct that stores the variables of a signle transaction and map an incrementing index to every transaction
    struct Transaction {
        uint256 amount;
        address to;
        address[] signers;
        bool transactionExecuted;
    }

    Transaction[] _transactions;
    // The following mapping is used to keep track of which address has already signed a transaction,
    // so that a single address can't sign a transaction twice and therefore make it valid.
    mapping(address => mapping(uint256 => bool)) signerToTransaction;

    // Give the creator of the contract the owner rights.
    constructor() {
        _owner = msg.sender;
        owners[msg.sender] = true;
    }

    // Submit a transaction and sign it with the current address.
    // Also emit the corresponding event and increment the transactionCount.
    function submitTransaction(uint256 amount, address to)
        public
        payable
        isOwner
        returns (uint256)
    {
        require(address(this).balance >= amount, "Not enough funds");
        uint256 index = _transactions.length;
        address[] memory emptyArray;
        Transaction memory transaction = Transaction(
            amount,
            to,
            emptyArray,
            false
        );
        _transactions.push(transaction);
        _transactions[index].signers.push(msg.sender);
        signerToTransaction[msg.sender][index] = true;
        emit transactionSubmitted(index, amount, to);
        return index;
    }

    // Sign a transaction by referencing it with an index.
    // If the transaction is signed twice, the executeTransaction function is called.

    function signTransaction(uint256 index) public isOwner {
        require(
            signerToTransaction[msg.sender][index] != true,
            "You already signed this transaction"
        );
        require(
            _transactions.length > index,
            "There is no transaction with that index!"
        );
        _transactions[index].signers.push(msg.sender);
        if (_transactions[index].signers.length == signaturesRequired) {
            executeTransaction(index);
        }
    }

    // Transaction of funds if the transaction is signed by enough addresses
    function executeTransaction(uint256 index) internal isOwner {
        payable(_transactions[index].to).transfer(_transactions[index].amount);
        _transactions[index].transactionExecuted = true;
        emit transactionExecuted(
            index,
            _transactions[index].amount,
            _transactions[index].to
        );
    }

    // Return addresses that have already signed a specific transaction
    function showSigners(uint256 index) public view returns (address[] memory) {
        require(
            _transactions.length > index,
            "There is no transaction with that index!"
        );
        return _transactions[index].signers;
    }

    // Return data of a specific transaction.
    function showTransaction(uint256 index)
        public
        view
        returns (Transaction memory)
    {
        require(
            _transactions.length > index,
            "There is no transaction with that index!"
        );
        return _transactions[index];
    }

    // Return current balance of the contract.
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getLength() public view returns (uint256) {
        return _transactions.length;
    }

    // Give an address the owner rights.
    function makeSomeoneOwner(address subject) public isOwner {
        require(owners[subject] == false, "Already an owner");
        owners[subject] = true;
    }

    receive() external payable {
        emit deposition(msg.sender, address(this), msg.value);
    }
}
