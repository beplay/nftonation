# Variables
## Front-end
- `status`: String literal = "Vote Organization" | "Vote NFT" | "Claim NFT"
- `metamask_active`: boolean -> if a user is logged in with metamask or not
- `voting_status_org`: Int array with size of number of organizations -> store voting progress
- `voting_status_nft`: Int array with size of number of NFTs -> store voting progress

## Smart contract
- `address_first_voters`: array with size of number of NFTs
- `contract_owner_addr`: String array with size of 3 (i.e the three of us)
- `nfts`: String array with size of number of NFTs -> store NFT hashes
- `orgs`: String array with size of number of organizations -> store organization addresses
