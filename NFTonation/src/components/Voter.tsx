import React, {ReactElement, useEffect, useState} from "react";
import {BigNumber, Contract, ethers, providers, Signer} from "ethers";
import {abi} from "./abi";
import Test from "./Test";

export function Voter(): ReactElement {

    const contractAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";
    const [isMMInstalled, setIsMMInstalled] = useState<boolean>(false);
    const [ethAddress, setEthAddress] = useState<string | null>(null);
    const [ethBalance, setEthBalance] = useState<BigNumber>(BigNumber.from(0));
    const ethereum = (window as any).ethereum;
    const [addEthAmount, setAddEthAmount] = useState<BigNumber>(BigNumber.from(0))
    const [orgChosen, setOrgChosen] = useState<string>("Org1")
// let [provider, setProvider] = useState<any>(null);
    let [signer, setSigner] = useState<Signer>();
    let [contract_rw, setContrRWrite] = useState<Contract>()
// let contract_rw : any = null;
    let [contract_ro, setContrROnly] = useState<Contract>()
    let [testBtnHidden, setTestBtnHidden] = useState<boolean>(false)
// let contract_ro : any = null;

    useEffect(() => {
        if (ethereum) {
            //check if Metamask wallet is installed
            setIsMMInstalled(true);
        } else {
            alert('Install MetaMask first');
        }
    }, [ethereum]);

    async function setupContracts(): Promise<void> {
        const provider = await new providers.Web3Provider(ethereum);
        // console.log(provider);
        setSigner(provider.getSigner());
        // console.log(signer);
        setContrROnly(new ethers.Contract(contractAddress, abi, provider));
        setContrRWrite(new ethers.Contract(contractAddress, abi, signer));
        // console.log(contract_ro);
        const nonce = await signer?.getTransactionCount('latest');
        console.log(nonce)
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
            .then((accounts: string[]) => {
                setEthAddress(accounts[0]);
            })
            .catch((error: any) => {
                alert(`Something went wrong: ${error}`);
            });
    }

    useEffect(() => {
        console.log("contract_ro:", contract_ro);

    }, [contract_ro]);

    useEffect(() => {
        setTestBtnHidden(true)
        console.log("testbtn:", testBtnHidden);
    }, [ethAddress]);

    async function getBalance(): Promise<void> {
        ethereum
            .request({
                method: "eth_getBalance",
                params: [ethAddress, 'latest']
            })
            .then((balance: BigNumber) => {
                setEthBalance(balance);
                console.log(ethers.utils.formatEther(balance));
            })
    }

    async function getEntries() {
        if (contract_ro) {
            let entries = await contract_ro.getAllEntries()
            console.log(typeof entries)
        }
    }

    async function addETH() {
        if (contract_rw) {
            await contract_rw.addETH({value: 1})
        }
    }

    async function vote() {
        if (contract_rw) {
            await contract_rw.setAccount(orgChosen)
        }
    }

    const inputHandler = (event: React.ChangeEvent<HTMLInputElement>) => {
        const addEth = event.target.value;
        setAddEthAmount(BigNumber.from(addEth));
    };

    const handleRadio = (event: React.ChangeEvent<HTMLInputElement>) => {
        const org = event.target.value
        setOrgChosen(org);
        console.log("Org chosen:", org);
    }

    return (
        <div>
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
                        <div>
                            {testBtnHidden && <Test />}
                        </div>
                        <div>
                            <input value={ethers.utils.formatEther(addEthAmount)} onChange={inputHandler}/>
                            <button onClick={addETH}>Add ETH</button>
                        </div>
                        <div>
                            <form>
                                <input type="radio" value="org1" id="org1" name="vote"
                                       onChange={handleRadio}/>
                                <label htmlFor="org1">Org1</label>

                                <input type="radio" value="org2" id="org2" name="vote"
                                       onChange={handleRadio}/>
                                <label htmlFor="org2">Org2</label>
                                <button onClick={vote}>Submit Vote</button>
                            </form>
                        </div>
                    </div>
                ) : (
                    <p>Install Your Metamask wallet</p>
                )
            }
        </div>
    )
}
