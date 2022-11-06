// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTonation {
    struct Voter {
        bool valid;
        bool voted;
    }

    struct Org {
        string name;
        uint256 num_votes;
        bool valid;
    }

    mapping(address => Voter) voters;
    mapping(address => Org) orgs;

    address ownerAddr;

    address[] voter_addresses;
    address[] org_addresses;

    address org_receiver;

    bool vote_open = false;
    bool vote_completed = false;

    constructor() {
        ownerAddr = msg.sender;
        addVoter(ownerAddr);
        addOrg("WWF", address(0x1));
        addOrg("Unicef", address(0x2));
        addOrg("Red Cross", address(0x3));
    }

    function addCurrentVoter() external {
        addVoter(msg.sender);
    }

    function setReceiver(address _receiver) external {
        requireOwner();
        requireHasOrgAccount(_receiver);
        requireVoteCompleted();
        org_receiver = _receiver;
    }

    function addVoter(address addr) internal {
        requireNoAccount();
        voter_addresses.push(addr);
        voters[addr] = Voter(true, false);
    }

    function addOrg(string memory name, address addr) internal {
        requireNoAccount(addr);
        org_addresses.push(addr);
        orgs[addr] = Org(name, 0, true);
    }

    function updateVoteOpen() external view {
        // check timer and update vote_open to true if countdown is 0
        // also update vote_completed
        if (!vote_open) {

        }
    }

    function resetVoteStatus() external {
        voters[msg.sender].voted = false;
    }

    function toggleVotingProcess() external {
        vote_open = !vote_open;
    }


    function vote(string memory org_name) external {
        requireVoteOpen();
        requireNotVoted();
        
        address org_addr = getOrgAddr(org_name);
        requireAddrNotNull(org_addr);
        requireHasOrgAccount(org_addr);
        
        setVoted();
        orgs[org_addr].num_votes += 1;
    }

    function setVoted() internal {
        voters[msg.sender].voted = true;
    }

    function getOrgAddr(string memory org_name) public view returns (address addr) {
        string memory name = "";
        for (uint256 i = 0; i < org_addresses.length; i++) {
            name = orgs[org_addresses[i]].name;
            if (compareStrings(name, org_name)) {
                addr = org_addresses[i];
            }
        }
        requireAddrNotNull(addr);
        return addr;
    }

    function getVoteCount() external view returns (string memory vote_count) {
        string memory temp = "";
        for (uint256 i = 0; i < org_addresses.length; i++) {
            temp = vote_count;
            vote_count = string.concat(temp, orgs[org_addresses[i]].name, ":", Strings.toString(orgs[org_addresses[i]].num_votes), "-"); 
        }
        return vote_count;
    }

    function getAllVoters() external view returns (string memory entries) {
        string memory temp = "";
        for (uint256 i = 0; i < voter_addresses.length; i++) {
            temp = entries;
            string memory voted = "";
            if (voters[voter_addresses[i]].voted) voted="voted"; else voted="not voted";
            entries = string.concat(temp, Strings.toHexString(voter_addresses[i]), ":", voted, "-"); 
        }
        return entries;
    }

    function compareStrings(string memory s1, string memory s2) internal pure returns(bool){
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    function requireNotVoted() internal view {
        require(!voters[msg.sender].voted, "You have already voted!");
    }


    function doesVoterExist(address addr) internal view returns (bool) {
        return voters[addr].valid;
    }

    function doesOrgExist(address addr) internal view returns (bool) {
        return orgs[addr].valid;
    }

    function requireNoAccount() internal view {
        require(!doesVoterExist(msg.sender) && !doesOrgExist(msg.sender), "You have already an account");
    }

    function requireNoAccount(address _addr) internal view {
        require(!doesVoterExist(_addr) || !doesOrgExist(_addr), "You have already an account");
    }

    function requireHasOrgAccount(address _addr) internal view {
        require(doesOrgExist(_addr), "No Org account found for this address");
    }

    function requireOwner() internal view {
        require(msg.sender == ownerAddr, "You are not the owner");
    }

    function requireVoteOpen() internal view {
        require(vote_open == true, "No vote ongoing");
    }

    function requireVoteCompleted() internal view {
        require(vote_completed == true, "Voting must happen first");
    }

    function requireAddrNotNull(address _addr) internal pure {
        require(_addr != address(0x0), "Org not found");
    }
}