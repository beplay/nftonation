import React, {ReactElement, useEffect, useState} from "react";
import "../styles/StartPage.css"
import "../styles/MetaMask.css"
import "../styles/Header.css"
import "../styles/VotePage.css"
import metamask from "../images/metamask.png"
import voting from "../images/voting.png"
import {BigNumber, Contract, ethers, providers, Signer} from "ethers";
import {abi} from "./abi";
import wwf from "../images/wwf.png";
import unicef from "../images/unicef.png";
import redcross from "../images/red-cross.png";

export function StartPage(): ReactElement {

    const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

    const [isMMInstalled, setIsMMInstalled] = useState<boolean>(false);
    const ethereum = (window as any).ethereum;
    const [ethAddress, setEthAddress] = useState<string | null>(null);
    const [ethBalance, setEthBalance] = useState<BigNumber>(BigNumber.from(0));
    const [showNextView, setShowNextView] = useState<boolean>(false)
    const [nonce, setNonce] = useState<number>(0)
    const [voteInProgress, setVoteInProgress] = useState<boolean>(false)
    const [signer, setSigner] = useState<Signer>();
    const [contract_rw, setContrRWrite] = useState<Contract>()
    const [contract_ro, setContrROnly] = useState<Contract>()
    const [mmAlert, setMMAlert] = useState<boolean>(false)
    const [numVoteWWF, setNumVoteWWF] = useState<number>(0)
    const [numVoteUnicef, setNumVoteUnicef] = useState<number>(0)
    const [numVoteRedCross, setNumVoteRedCross] = useState<number>(0)
    const [orgOverview, setOrgOverview] = useState([
        {name: "WWF", votes: 0},
        {name: "Unicef", votes: 0},
        {name: "Red Cross", votes: 0}
    ])


    useEffect(() => {
        if (ethereum) {
            setIsMMInstalled(true);
        } else {
            console.log(mmAlert)
            setMMAlert(true)
        }
    }, [ethereum]);

    async function setupContracts(): Promise<void> {
        const provider = await new providers.Web3Provider(ethereum)
        setSigner(provider.getSigner())
        setContrROnly(new ethers.Contract(contractAddress, abi, provider))
        setContrRWrite(new ethers.Contract(contractAddress, abi, signer))
        await getNonce()
    }

    function toggleVoteProcess() {
        setVoteInProgress(!voteInProgress)
        contract_rw?.toggleVotingProcess()
    }

    function resetVoteStatus() {
        contract_rw?.resetVoteStatus()
    }

    async function getVoteCount(){
        let votes = await contract_ro?.getVoteCount()
        // console.log(votes)
    //     WWF:1-Unicef:0-Red Cross:3-
        let parse = votes as string
        let arr = parse.split("-")
        // let newState: any
        // arr.forEach((e) => {
        //     newState = orgOverview.map(temp => {
        //         // console.log(e.split(":")[1])
        //         // console.log(temp)
        //         return {
        //             ...temp,
        //             votes: e.split(":")[1]
        //         }
        //     })
        // })
        // setOrgOverview(newState)

        console.log(arr)
    }

    async function getAllVoters() {
        let entries = await contract_rw?.getAllVoters()
        console.log(entries)
    }

    function addNewVoter() {
        contract_rw?.addCurrentVoter()
    }

    function voteWWF() {
        contract_rw?.vote("WWF")
    }

    function voteUnicef() {
        contract_rw?.vote("Unicef")
    }

    function voteRedCross() {
        contract_rw?.vote("Red Cross")
    }

    async function getNonce() {
        const temp = await signer?.getTransactionCount('latest');
        setNonce(temp as number)
    }

    useEffect(() => {
        console.log("Nonce:", nonce)
    }, [nonce])

    function toggleView() {
        setShowNextView(!showNextView)
    }

    async function connectMetamaskWallet(): Promise<void> {
        setEthAddress(null);
        setEthBalance(BigNumber.from(0));
        ethereum
            .request({
                method: "eth_requestAccounts",
            })
            .then((accounts: string[]) => {
                setEthAddress(accounts[0]);
                setupContracts()
            })
            .catch((error: any) => {
                alert(`Something went wrong: ${error}`);
            });
    }

    return (
        <div>
            <div className="start-page" style={{display: !showNextView ? "flex" : "none"}}>
                <div className="start-container">

                    <p>1. Login to Metamask</p>
                    <div className="metamask-button">
                        <button className="button" id="connect-button" onClick={connectMetamaskWallet}>
                            <img src={metamask} alt="metamask logo"/>
                            Connect Your Wallet
                        </button>
                        <div className={mmAlert ? "alert.show" : "alert"} id="install-alert">
                            Please refresh your browser after installing the Metamask plugin
                            <button className="button" id="reload-button">Reload page</button>
                        </div>
                    </div>

                    <p>2. Check you Wallet</p>
                    <div id="wallet-id"><span>
                        {ethAddress ? ethAddress : "Your wallet is not yet connected"}
                    </span></div>

                    <p>3. Go to Voting Page</p>
                    <div className="voting-page-button">
                        <button className="button" id="vote-page-button"
                                disabled={!ethAddress} onClick={toggleView}>
                            <img src={voting} alt="voting logo"/>
                            Go to Voting Page
                        </button>
                    </div>
                </div>
            </div>
            <div>
                <div className="vote-header" style={{display: showNextView ? "flex" : "none"}}>
                    <div id="selected-nft">
                        <div className="nft-display"></div>
                    </div>
                    <div id="contract-timer">
                        <div className="countdown"></div>
                    </div>
                    <div id="connected-wallet">
                        <div id="wallet-display"><p>
                            {ethAddress ? ethAddress : "NO WALLET SELECTED"}
                            </p></div>
                    </div>
                    <div id="navigation"></div>
                </div>
                <div className="vote-page" style={{display: showNextView ? "flex" : "none"}}>
                    <div className="org-card">
                        <img className="org-image" src={wwf} alt="wwf logo"/>
                        <div className="card-info">
                            <div className="org-votes">
                                <span className="votes-number-wwf">200</span>
                                <span className="votes-text">VOTES</span>
                            </div>
                            <div className="line"></div>
                            <div className="org-info">
                                <span className="org-name">WWF</span>
                                <a className="org-website" href="https://www.worldwildlife.org/"
                                   target="_blank" rel="noreferrer">WEBSITE</a>
                            </div>
                        </div>
                        <button className="card-btn btn-wwf" onClick={voteWWF}>VOTE</button>
                    </div>
                    <div className="org-card">
                        <img className="org-image" src={unicef} alt="unicef logo"/>
                        <div className="card-info">
                            <div className="org-votes">
                                <span className="votes-number-unicef">300</span>
                                <span className="votes-text">VOTES</span>
                            </div>
                            <div className="line"></div>
                            <div className="org-info">
                                <span className="org-name">UNICEF</span>
                                <a className="org-website" href="https://www.unicef.org/" target="_blank" rel="noreferrer">WEBSITE</a>
                            </div>
                        </div>
                        <button className="card-btn btn-unicef" onClick={voteUnicef}>VOTE</button>
                    </div>
                    <div className="org-card">
                        <img className="org-image" src={redcross} alt="redcross logo"/>
                        <div className="card-info">
                            <div className="org-votes">
                                <span className="votes-number-redcross">400</span>
                                <span className="votes-text">VOTES</span>
                            </div>
                            <div className="line"></div>
                            <div className="org-info">
                                <span className="org-name">Red-Cross</span>
                                <a className="org-website" href="https://www.redcross.ch/en" target="_blank" rel="noreferrer">WEBSITE</a>
                            </div>
                        </div>
                        <button className="card-btn btn-redcross" onClick={voteRedCross}>VOTE</button>
                    </div>
                </div>
                <div>
                    <button onClick={addNewVoter}>Add me as a Voter</button>
                </div>
                <div>
                    <button onClick={toggleVoteProcess}>Toggle Vote</button>
                    <output>{voteInProgress ? "Vote active" : "Vote stopped"}</output>
                </div>
                <div>
                    <button>Transfer NFT</button>
                </div>
                <div>
                    <button onClick={toggleView}>Toggle View</button>
                </div>
                <div>
                    <button onClick={resetVoteStatus}>Reset Vote Status</button>
                </div>
                <div>
                    <button onClick={getAllVoters}>Log all Voters</button>
                </div>
                <div>
                    <button onClick={getVoteCount}>Get Vote Count</button>
                </div>
                <div>
                    <button onClick={getNonce}>Show Nonce</button>
                </div>
            </div>
        </div>

    )
}

