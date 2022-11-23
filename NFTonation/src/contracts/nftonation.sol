// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


interface iTON {
    function transfer(address to, uint256 tokenId) external;
    function showNFTBal(address owner) external view returns (uint256);
}

// deploy TON first, then NFTonation

contract TON is ERC721, Ownable, iTON {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 private tokId;


    constructor() ERC721("NFTonation", "TON") {
        tokId = safeMint(address(this));
    }

    function _baseURI() internal pure override returns (string memory) {
        return "Tonation";
    }

    function safeMint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        return tokenId;
    }

    function transfer(address to, uint256 _tokenId) external {
        safeTransferFrom(address(msg.sender)
                      , to
                      , _tokenId
                      , "");
    }

    function showNFTBal(address owner) external view returns (uint256) {
        return balanceOf(owner);
    }

}

contract NFTonation is IERC721Receiver {
    iTON nft;

    struct Voter {
        bool valid;
        bool voted;
    }

    struct Org {
        string name;
        uint256 num_votes;
        bool valid;
    }

    mapping(address => Voter) public voters;
    mapping(address => Org) public orgs;

    address ownerAddr;

    address[] public voter_addresses;
    address[] public org_addresses;

    address org_receiver;
    uint256 private org_addr_length;
    uint256 private voter_addr_length;

    bool vote_open = false;

    event VoteSubmitted(string voted);
    event VotingStarted(uint256);
    event VotingDuration(uint256);

    uint256 public startTime;
    uint256 public durationMinutes;

    uint256 tokenId;

    constructor(address tonation) {
        nft = iTON(tonation);
        ownerAddr = msg.sender;
        addVoter(ownerAddr);
        addOrg("WWF", address(0x1));
        addOrg("Unicef", address(0x2));
        addOrg("Red Cross", address(0x3));
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }

    function requireXMinutesOld(uint256 x) internal view {
        require(getBlockTime() > (startTime + x * 1 minutes), "Vote ongoing");
    }

    function requireVotingOpen() internal view {
        require(vote_open == true, "Voting closed");
        require(getBlockTime() <= (startTime + durationMinutes * 1 minutes), "Voting inactive");
    }

    function getOrgAddLength() external view returns (uint256) {
        return org_addr_length;
    }

    function getVoterAddLength() external view returns (uint256) {
        return voter_addr_length;
    }


    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function transferToken() external {
        requireVoteInactive();
        requireReceiverSet();
        nft.transfer(org_receiver, tokenId);
    }

    function showNFTBal(address owner) public view returns (uint256) {
        return nft.showNFTBal(owner);
    }

    function addCurrentVoter() external {
        addVoter(msg.sender);
    }

    function setReceiver(address _receiver) external {
        requireOwner();
        requireHasOrgAccount(_receiver);
        requireVoteInactive();
        org_receiver = _receiver;
    }

    function addVoter(address addr) internal {
        requireNoAccount();
        voter_addresses.push(addr);
        voters[addr] = Voter(true, false);
        voter_addr_length += 1;
    }

    function addOrg(string memory name, address addr) internal {
        requireNoAccount(addr);
        org_addresses.push(addr);
        orgs[addr] = Org(name, 0, true);
        org_addr_length += 1;
    }

    function startVoting(uint256 _durationMinutes, uint256 _tokenId) public {
        requireVoteInactive();
        startTime = getBlockTime();
        durationMinutes = _durationMinutes;
        vote_open = true;
        tokenId = _tokenId;
        emit VotingStarted(startTime);
        emit VotingDuration(_durationMinutes);
    }

    function resetVoteStatus() external {
        voters[msg.sender].voted = false;
    }

    function toggleVotingProcess() external {
        // requireVoteInactive();
        // startVoting(1);
        vote_open = !vote_open;
    }


    function vote(string memory org_name) external {
        requireVotingOpen();
        requireNotVoted();

        address org_addr = getOrgAddr(org_name);
        requireAddrNotNull(org_addr);
        requireHasOrgAccount(org_addr);

        setVoted();
        orgs[org_addr].num_votes += 1;

        emit VoteSubmitted("voted");
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

    function requireVoteInactive() internal view {
        require(vote_open == false, "Vote ongoing");
    }

    function requireAddrNotNull(address _addr) internal pure {
        require(_addr != address(0x0), "Org not found");
    }

    function requireReceiverSet() internal view {
        require(org_receiver != address(0x0), "Set receiver first");
    }
}
