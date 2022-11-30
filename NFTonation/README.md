# Setup NFTonation

1. Start hardhat: `npx hardhat node`
2. Start react: `npm start`
7. In Metamask -> Settings -> Networks -> Localhost set the `Chain ID` to `31337` (you may have to restart your browser)
7. Import one of the private keys from the Hardhat terminal into the Metamask wallet as a new account
8. Switch Metamask to Localhost, it should connect to the Hardhat node
3. Add smart contract from react project to Remix and compile
4. Copy the complete abi from the compiler page and paste it into the react project: `abi.ts`
4. Connect Remix environment to Hardhat local
5. Deploy TON first, and copy its address from the generated contract
6. Deploy NFTonation using the TON address
7. Copy-paste the NFTonation address to the react project: `StartPage.tsx` -> `contractAddress=0x...`
7. Open localhost:3000
9. Activate `Customize transaction nonce` in the Metamask advanced settings
8. `Connect your wallet` using one of the Hardhat accounts
9. **`NOTE: LOCAL HARDHAT NODE TAKES SOMETIMES UP TO 30 MINUTES TO MINE A TRANSACTION`**
10. In Remix, you can activate `listen on all transaction` so you see your transactions from the frontend, too


# Voting
1. Connect your wallet
2. Go to voting page
3. on the bottom, trigger `Toggle Vote`, this should enable the voting
4. If asked for a Nonce, try `Show Nonce` and check the console
5. `Log all Voters` should console.log a string with the current voter and their status
6. Choose an org and vote for it
7. Then wait, the vote count should update automatically
8. If you want to vote again, try `Reset Vote Status` and then try again (you may have to wait a few seconds)
9. To go to the login page, use `Toggle View`
10. `Add me as a voter` and `Transfer NFT` are not implemented yet, or have no use
