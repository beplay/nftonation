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
    function showOwnerOf(uint256 _tokenId) external view returns (address);
}

// deploy TON first, then NFTonation

contract TON is ERC721, Ownable, iTON {
    using Counters for Counters.Counter;



    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("NFTonation", "TON") {}

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

    function showOwnerOf(uint256 _tokenId) public view returns (address) {
        return ownerOf(_tokenId);
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

    bool voting_occurred = false;

    event TokenReceived(uint256);
    event VoteSubmitted(string voted);
    event VotingStarted(uint256);
    event VotingDuration(uint256);
    event WinnerToken(address);

    uint256 public startTime;
    uint256 public durationMinutes;

    uint256 tokenId;

    constructor(address tonation) {
        nft = iTON(tonation);
        ownerAddr = msg.sender;
        addOrg("WWF", address(0xbDA5747bFD65F08deb54cb465eB87D40e51B197E));
        addOrg("Unicef", address(0xdD2FD4581271e230360230F9337D5c0430Bf44C0));
        addOrg("Red Cross", address(0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199));
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }

    function getOrgAddLength() external view returns (uint256) {
        return org_addr_length;
    }

    function getVoterAddLength() external view returns (uint256) {
        return voter_addr_length;
    }


    function onERC721Received(address, address, uint256 _tokenId, bytes calldata) external returns (bytes4) {
        setTokenId(_tokenId);
        emit TokenReceived(_tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }

    function setTokenId(uint256 _tokenId) internal {
        tokenId = _tokenId;
    }

    function transferToken() public {
        requireVotingFinished();
        requireReceiverSet();
        nft.transfer(org_receiver, tokenId);
    }

    function showNFTBal(address owner) public view returns (uint256) {
        return nft.showNFTBal(owner);
    }

    function addCurrentVoter() internal {
        addVoter(msg.sender);
    }

    function setReceiver(address _receiver) public {
        requireOwner();
        requireHasOrgAccount(_receiver);
        requireVotingFinished();
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

    function startVoting(uint256 _durationMinutes) public {
        durationMinutes = _durationMinutes;
        requireVoteNotStarted();
        requireContractTokenOwner();
        startTime = getBlockTime();
        voting_occurred = false;
        emit VotingStarted(startTime);
        emit VotingDuration(_durationMinutes);
    }

    function resetVoteStatus() external {
        voters[msg.sender].voted = false;
    }

    function determineWinnerAddr() public view returns (address winner_addr) {
        requireOwner();
        requireVotingFinished();
        (uint256 num_votes, string memory win_org) = getWinner();
        if (num_votes == 0) {
            winner_addr = address(0x0);
        } else {
            winner_addr = getOrgAddr(win_org);
        }
        return winner_addr;
    }

    function getWinnerVotes() public view returns (uint256 num_votes) {
        requireVotingFinished();
        (num_votes, ) = getWinner();
        return num_votes;
    }

    function getWinner() internal view returns (uint256 max_vote, string memory win_org) {
        uint256 temp = 0;
        max_vote = 0;
        for (uint256 i = 0; i < org_addresses.length; i++) {
            temp = orgs[org_addresses[i]].num_votes;
            if (temp >= max_vote) {
                if (temp == max_vote) {
                    max_vote = 0;
                    win_org = "draw";
                } else {
                    max_vote = temp;
                    win_org = orgs[org_addresses[i]].name;
                }
            }
        }
        return (max_vote, win_org);
    }

    function finishVotingProcess() external {
        voting_occurred = true;
        requireVotingFinished();

        address winner_addr = determineWinnerAddr();
        requireAddrNotNull(winner_addr);
        setReceiver(winner_addr);

        transferToken();
        address new_token_owner = nft.showOwnerOf(tokenId);
        emit WinnerToken(new_token_owner);
    }

    function vote(string memory org_name) external {
        requireVotingOpen();
        requireNotVoted();
        addCurrentVoter();

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

    function requireVotingFinished() internal view {
        requirePosVoteDuration();
        require(voting_occurred == true, "Voting has not yet happened");
        require(getBlockTime() > (startTime + durationMinutes * 1 minutes), "Voting still ongoing");
    }

    function requireVotingOpen() internal view {
        require(getBlockTime() <= (startTime + durationMinutes * 1 minutes), "Voting inactive, maybe start it first");
        requirePosVoteDuration();
        requireVoteNotOccurred();
        requireContractTokenOwner();
    }

    function requireVoteNotStarted() internal view {
        requirePosVoteDuration();
        requireVoteNotOccurred();
        requireContractTokenOwner();
    }

    function requireVoteNotOccurred() internal view {
        require(voting_occurred == false, "Voting has already happened");
    }

    function requirePosVoteDuration() internal view {
        require(durationMinutes > 0, "Allow some time for voters to vote");
    }

    function requireAddrNotNull(address _addr) internal pure {
        require(_addr != address(0x0), "Org not found");
    }

    function requireReceiverSet() internal view {
        require(org_receiver != address(0x0), "Set receiver first");
    }

    function requireContractTokenOwner() internal view {
        require(nft.showNFTBal(address(this)) > 0, "You do not have any tokens");
        require(nft.showOwnerOf(tokenId) == address(this), "You do not own this token");
    }

}
