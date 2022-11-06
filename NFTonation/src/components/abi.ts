export const abi = [
    {
        "inputs": [],
        "name": "addCurrentVoter",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "resetVoteStatus",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_receiver",
                "type": "address"
            }
        ],
        "name": "setReceiver",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "toggleVotingProcess",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "string",
                "name": "org_name",
                "type": "string"
            }
        ],
        "name": "vote",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "inputs": [],
        "name": "getAllVoters",
        "outputs": [
            {
                "internalType": "string",
                "name": "entries",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "string",
                "name": "org_name",
                "type": "string"
            }
        ],
        "name": "getOrgAddr",
        "outputs": [
            {
                "internalType": "address",
                "name": "addr",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getVoteCount",
        "outputs": [
            {
                "internalType": "string",
                "name": "vote_count",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "updateVoteOpen",
        "outputs": [],
        "stateMutability": "view",
        "type": "function"
    }
]
