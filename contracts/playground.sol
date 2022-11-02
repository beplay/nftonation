// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";


contract Slide {
    Ground play;

    constructor(address _play) {
        play = Ground(_play);
    }

    function getThatName() public view returns (string memory) {
        return play.getOwnerName();
    }
}

interface Ground {
    function getOwnerName() external view returns (string memory);
}

contract Play is Ground {
    uint256 state;
    bool isSomething;

    struct Account {
        string name;
        uint256 amount;
        bool valid;
    }

    mapping(address => Account) balances;
    address ownerAddr;
    uint256 ownerEth;
    address[] store;
    uint256 totalBalance = 0;

    address receiver;

    uint256 startTime;

    event Something(string s1);

    constructor() payable {  // constructor() is a key word
        ownerAddr = msg.sender;
        ownerEth = msg.value;
        addEntry('hi', ownerEth, ownerAddr);
        startTime = getBlockTime();

    }

    function addEntry(string memory name, uint256 amount, address addr) internal {
        if (doesExist(addr)) {
            balances[addr].name = name;
            balances[addr].amount += amount;
        } else {
            store.push(addr);
            balances[addr] = Account(name, amount, true);
        }
        totalBalance += amount;
        
    }

    function returnOwnerAddr() external view returns (address) {
        return ownerAddr;
    }

    function getOwnerName() external view returns (string memory) {
        return balances[ownerAddr].name;
    }

    function setAccount(string memory name) external payable {
        requireNoAccount();
        addEntry(name, msg.value, msg.sender);
    }

    function setReceiver(address _receiver) external {
        requireOwner();
        requireHasAccount(_receiver);
        receiver = _receiver;
    }

    function updateName(string memory name) external {
        requireHasAccount();
        requireXSecondsOld(10);
        addEntry(name, 0, msg.sender);
    }

    function addETH(uint256 amount) external payable {
        requireHasAccount();
        addEntry(getName(msg.sender), amount, msg.sender);
        emit Something("Say thank you in the front end");
    }

    function payout() public payable {
        requireXSecondsOld(15);
        requireHasAccount(receiver);
        uint256 bingo = totalBalance;
        totalBalance = 0;
        payable(receiver).transfer(bingo);
    }

    function getName(address addr) public view returns (string memory) {
        return balances[addr].name;
    }

    function getOwnerBalance() external view returns (uint256) {
        return balances[ownerAddr].amount;
    }

    function getAllEntries() external view returns (string memory entries) {
        requireOwner();
        string memory temp = "";
        for (uint256 i = 0; i < store.length; i++) {
            temp = entries;
            entries = string.concat(temp, balances[store[i]].name, "-", Strings.toString(balances[store[i]].amount), "-", 
            Strings.toHexString(store[i]), ";");
        }
        return entries;
    }

    function doesExist(address addr) internal view returns (bool) {
        return balances[addr].valid;
    }

    function getTotalBalance() external view returns (uint256 bal) {
        return totalBalance;
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }

    function requireNoAccount() internal view {
        require(!doesExist(msg.sender), "You already have an account");
    }

    function requireHasAccount() internal view {
        require(doesExist(msg.sender), "You do not have an account, create one first");
    }

    function requireHasAccount(address _addr) internal view {
        require(doesExist(_addr), "No account found for this address");
    }

    function requireOwner() internal view {
        require(msg.sender == ownerAddr, "You are not the owner");
    }

    function requireXSecondsOld(uint256 x) internal view {
        // uint256 timeRef = startTime + (x * 1 seconds);
        // uint256 waitSecs;
        // unchecked{ waitSecs = timeRef - getBlockTime(); }
        // Calculation time for the toString takes forever with large numbers, i.e. when underflow happened...
        // require(getBlockTime() > timeRef, string.concat("You need to wait ", Strings.toString(waitSecs), " seconds"));
        require(getBlockTime() > (startTime + x * 1 seconds), string.concat("you ", "have to wait"));
    }
}
