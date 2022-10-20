import { useEffect, useState } from "react";
import logo from './NFTonation.png';
import './App.css';
import {BigNumber, Contract, ethers, providers, Signer} from "ethers";
import { abi } from "./abi";


function App() : JSX.Element {
    const contractAddress = "0xd9145CCE52D386f254917e481eB44e9943F39138";
    const [isMMInstalled, setIsMMInstalled] = useState<boolean>(false);
    const [ethAddress, setEthAddress] = useState<string | null>(null);
    const [ethBalance, setEthBalance] = useState<BigNumber>(BigNumber.from(0));
    const ethereum = (window as any).ethereum;
    // let [provider, setProvider] = useState<any>(null);
    let [signer, setSigner] = useState<Signer>();
    let [contract_rw, setContrRWrite] = useState<Contract>()
    // let contract_rw : any = null;
    let [contract_ro, setContrROnly] = useState<Contract>()
    // let contract_ro : any = null;

  useEffect(() => {
    if(ethereum){
        //check if Metamask wallet is installed
        setIsMMInstalled(true);
    } else {
        alert('Install MetaMask first');
    }
  },[ethereum]);

    async function setupContracts(): Promise<void> {
        const provider = await new providers.Web3Provider(ethereum);
        // console.log(provider);
        setSigner(provider.getSigner());
        // console.log(signer);
        setContrROnly(new ethers.Contract(contractAddress, abi, provider));
        setContrRWrite(new ethers.Contract(contractAddress, abi, signer));
        // console.log(contract_ro);
    }

  //Does the User have an Ethereum wallet/account?
  async function connectMetamaskWallet(): Promise<void> {
      setEthAddress(null);
      setEthBalance(BigNumber.from(0));
    //to get around type checking
    ethereum
        .request({
          method: "eth_requestAccounts",
        })
        .then((accounts : string[]) => {
          setEthAddress(accounts[0]);
        })
        .catch((error: any) => {
          alert(`Something went wrong: ${error}`);
        });
  }

  useEffect(() => {
      console.log(contract_ro);

  }, [contract_ro]);

  async function getBalance(): Promise<void> {
    ethereum
        .request({
          method: "eth_getBalance",
          params: [ethAddress, 'latest']
        })
        .then((balance : BigNumber) => {
          setEthBalance(balance);
          console.log(ethers.utils.formatEther(balance));
        })
  }

  function getEntries() {
      debugger;
      if(contract_ro) {
          console.log(contract_ro.getAllEntries());
      }
  }


    return (
        <div className="App">
            <header className="App-header">
                <img src={logo} className="App-logo" alt="logo" />
            {
                isMMInstalled ? (
                    <div>
                        <div>
                            <button onClick={connectMetamaskWallet}>Connect Your Metamask Wallet</button>
                            <output>{ethAddress}</output>
                        </div>
                        <div>
                            <button onClick={setupContracts}>Setup Contracts</button>
                            {contract_ro && <output>OK</output>}
                        </div>
                        <div>
                            <button onClick={getBalance}>Get Balance</button>
                            <output>{ethers.utils.formatEther(ethBalance)} ETH</output>
                        </div>
                        <div>
                            <button onClick={getEntries}>Get Entries</button>
                        </div>
                        {/*<output>{getEntries()}</output>*/}
                    </div>
                ) : (
                    <p>Install Your Metamask wallet</p>
                )
            }
            </header>
        </div>
    );
}

export default App;
