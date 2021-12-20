import { ethers } from 'ethers';
import {Component} from 'react'
import './App.css';
import Wallet from './artifacts/contracts/MultiSignatureWallet.sol/MultiSigWallet.json'



class App extends Component {
  state = {
    provider: null, 
    signer: null, 
    contract: null, 
    walletBalance: null,
    walletAddress: null,
    index: 0,
    address: "0x0"
  }
  
  componentDidMount = async () => {
    const walletAddress = "0xDC7416D2BA04A9cee9374319E95aA1B2c08554Cf"
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const contract = new ethers.Contract(walletAddress, Wallet.abi, signer)

    const creator = await contract._owner()
    
    setInterval(() => {
      this.getBalance();
      this.requestAccount();
    }, 1000);

    this.setState({contract: contract, creator: creator, walletAddress: walletAddress})
  }
  requestAccount = async () => {
    this.setState({currentAccount: await window.ethereum.request({ method: 'eth_requestAccounts'})})
  }

  
  submitTransaction = async () => {
    if(typeof window.ethereum !== 'undefined') {
      try{
        const {address, amount, contract} = this.state
        const transaction = await contract.submitTransaction(amount, address)
        await transaction.wait()
        console.log(transaction)
      } catch(err) {
        console.log("Error: ", err)
      }
    }
  }

  makeSomeoneOwner = async () => {
    if(typeof window.ethereum !== 'undefined') {
      try {
        const {address, contract} = this.state
        const transaction = await contract.makeSomeoneOwner(address)
        await transaction.wait()
        console.log(transaction)
      } catch(err) {
        console.log("Error: ", err)
      }
    }
  }

  signTransaction = async () => {
    if(typeof window.ethereum !== 'undefined') {
      try {
        const {index, contract} = this.state
        const transaction = await contract.signTransaction(index)
        await transaction.wait()
        console.log(transaction)
      } catch(err) {
        console.log("Error: ", err)
      }
    }
  }

  convertToEther = (value) => {
    const remainder = value.mod(1e14)
    const result = ethers.utils.formatEther(value.sub(remainder))
    return result
  }

  showTransaction = async () => {
    if(typeof window.ethereum !== 'undefined') {
      try {
        const {contract, index} = this.state
        const transaction = await contract.showTransaction(index)
        const blnc = ethers.BigNumber.from(parseInt(Number(transaction.amount._hex), 10).toString())
        const value = this.convertToEther(blnc)
        this.setState({
          amount: value,
          txStatus: transaction.transactionExecuted.toString(),
          recipient: transaction.to,
          signers: transaction.signers
        })
        alert(`Transaction Index: ${index}\n
              Recipient: ${transaction.to}\n
              Transaction signers: ${transaction.signers}\n
              Transaction executed?\t ${transaction.transactionExecuted}\n
              Amount: ${value} ETH`)
        console.log(`Recipient: ${transaction.to}`)
        console.log(`Transaction signers: ${transaction.signers}`)
        console.log(`Transaction executed?: ${transaction.transactionExecuted}`)
        console.log(`Amount: ${value} ETH`)
      } catch(err) {
        console.log("Error: ", err)
      }
    }
  }

  getBalance = async () => {
    if(typeof window.ethereum !== 'undefined') {
      try {
        const balance = await this.state.contract.getBalance()
        const blnc = ethers.BigNumber.from(balance.toString())
        const value = this.convertToEther(blnc)
        this.setState({walletBalance: value})
      } catch(err) {
        console.log("Error: ", err)
      }
    }
  }

  isOwner = async () => {
    if(typeof window.ethereum !== 'undefined') {
      try {
        const {contract, address} = this.state
        const response = await contract.owners(address)
        alert(response.toString())
        console.log(response.toString())
      } catch(err) {
        console.log("Error: ", err)
      }
    }
  }

  logAmount = () => {
    console.log(this.state.amount)
  }
  
  render() {
    return (
      <div className="App">
        <br/>
        <br/>
        <header>Currently selected Account: {this.state.currentAccount}</header>
        <header>Wallet address: {this.state.walletAddress}</header>
        <header>Wallet balance: {this.state.walletBalance} ETH</header>
        <br/>
        <header>Wallet Creator: {this.state.creator}</header>
        <br/>
        <br/>
        <input
            onChange={e => this.setState({address: e.target.value})}
            placeholder="Address"
            value={this.state.address}
          />
        <input
          onChange={e => this.setState({amount: (e.target.value * 10 ** 18).toString()})}
          placeholder="Amount (ETH)"
        />
        <input
          onChange={e => this.setState({index: e.target.value})}
          placeholder="Index"
          value={this.state.index}
        />
        <br/>
        <br/>

        <button onClick={this.logAmount}>Log amount</button>
        <button onClick={this.makeSomeoneOwner}>Make Owner</button>
        <button onClick={this.isOwner}>Check if owner</button>
        <button onClick={this.submitTransaction}>Submit new transaction</button>
        <br/>
        <button onClick={this.showTransaction}>Show Transaction</button>
        <button onClick={this.signTransaction}>Sign Transaction</button>
        <br/>
        <br/>
        <header>Transaction Info for current index</header>
        <header>Amount: {this.state.amount} ETH</header>
        <header>Recipient: {this.state.recipient}</header>
        <header>Signers: {this.state.signers}</header>
        <header>Executed?: {this.state.txStatus}</header>
      </div>
    );
  }
}

export default App;


