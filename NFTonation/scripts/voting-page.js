const hre = require("hardhat");
const {BigNumber, Contract, ethers, providers, Signer} = require("ethers");
import {abi} from "./abi"
import {ethereum} from "./start-page";

const contractAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";

let provider;
let signer;
let contract_ro;
let contract_rw;

export async function setupContracts() {
    provider = await new providers.Web3Provider(ethereum)
    signer = provider.getSigner()
    contract_ro = new ethers.Contract(contractAddress, abi, provider)
    contract_rw = new ethers.Contract(contractAddress, abi, signer)
    console.log(contract_rw)
}

