// SPDX-License-Identifier: MIT License

pragma solidity >=0.7.0 <0.9.0;

contract Token {
    address payable public owner;

    uint256 tokenAmount;
    uint256 totalBalance;

    struct record {
        uint256 balance;
        bool exists;
    }

    mapping(address => record) accounts;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Mint(address indexed to, uint256 value);

    event Sell(address indexed from, uint256 value);

    constructor() {
        owner = payable(msg.sender);
        tokenAmount = 0;
        totalBalance = 0;

        accounts[msg.sender].exists = true;
    }

    function totalSupply() public view returns (uint256) {
        return tokenAmount;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return accounts[_account].balance;
    }

    function getName() public view returns (string memory) {
        return "Staring";
    }

    function getSymbol() public view returns (string memory) {
        return "STAR";
    }

    function getPrice() public view returns (uint128) {
        return 600 wei;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(value > 0, "Error: Cannot transfer 0.");
        require(balanceOf(msg.sender) >= value, "Error: Not enough token in your account.");
        require(accounts[to].exists, "Error: Receiver account not exists.");

        accounts[msg.sender].balance -= value;
        accounts[to].balance += value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function mint(address to, uint256 value) public returns (bool) {
        require(msg.sender == owner, "Error: Only owner can mint tokens.");

        require(totalBalance >= (totalSupply() + value) * getPrice(), "Error: Minting failed due to insufficient balance in the contract.");

        accounts[to].exists = true;
        accounts[to].balance += value;  
        tokenAmount += value;
        
        emit Mint(to, value);

        return true;
    }

    function sell(uint256 value) public returns (bool) {
        require(value > 0, "Error: Cannot sell 0.");
        require(balanceOf(msg.sender) >= value, "Error: Not enough token in your account.");

        accounts[msg.sender].balance -= value;
        tokenAmount -= value;
        payable(msg.sender).transfer(value * getPrice());

        emit Sell(msg.sender, value);

        return true;
    }

    function close() public {
        require(msg.sender == address(owner), "Error: Only owner can close the contract.");

        selfdestruct(owner);
    }

    fallback() external payable {
        totalBalance += msg.value;
    }

    receive() external payable {
        totalBalance += msg.value;
    }
}