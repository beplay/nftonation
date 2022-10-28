// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";

contract Voting {

    using Counters for Counters.Counter;

    Counters.Counter public _voterId;
    Counters.Counter public _orgId;

    address public votingAdmin;

    // ORGANISATION

    struct Organisation {
        uint256 orgId;
        string age;
        string name;
        uint256 voteCount;
        address _address;
        string ipfs;
    }

    event OrganisationCreate (
        uint256 indexed orgId,
        string age,
        string name,
        uint256 voteCount,
        address _address,
        string ipfs
    );

    address[] public organisationAddresses;

    mapping (address => Organisation) public organisations;

    // VOTER

    struct Voter {
        uint256 voter_voterId;
        string voter_name;
        address voter_address;
        bool voter_voted;
        uint256 voter_vote;
        string voter_ipfs;
    }

    event VoterCreate (
        uint256 indexed voter_voterId,
        string voter_name,
        address voter_address,
        bool voter_voted,
        uint256 voter_vote,
        string voter_ipfs
    );

    address[] public votedVoters;

    address[] public votersAddress;

    mapping(address => Voter) public voters;

    // Start

    constructor () {
        votingAdmin = msg.sender;
    }

    function setOrganisation(address _address, string memory _age, string memory _name, string memory _ipfs) public {
        require(votingAdmin == msg.sender, "Youre not Admin!");

        _orgId.increment();

        uint256 idNumber = _orgId.current();

        Organisation storage organisation = organisations[_address];

        organisation.age = _age;
        organisation.name = _name;
        organisation.orgId = idNumber;
        organisation.voteCount = 0;
        organisation._address = _address;
        organisation.ipfs = _ipfs;

        organisationAddresses.push(_address);

        emit OrganisationCreate (
            idNumber,
            _age,
            _name,
            organisation.voteCount,
            _address,
            _ipfs
        );

    }

    function getOrganisation() public view returns (address[] memory) {
        return organisationAddresses;
    }

    function getOrganisationLength() public view returns (uint256) {
        return organisationAddresses.length;
    }

    function vote(address _organisationAddress, uint256 _organisationVoteId) external {
        Voter storage voter = voters[msg.sender];

        require(!voter.voter_voted, "You have already voted!");

        voter.voter_voted = true;
        voter.voter_vote = _organisationVoteId;

        votedVoters.push(msg.sender);

        organisations[_organisationAddress].voteCount += 1;
    }

    function getVoterLength() public view returns (uint256) {
        return votersAddress.length;
    }

    function getVotedVoterList() public view returns (address[] memory) {
        return votedVoters;
    }
}