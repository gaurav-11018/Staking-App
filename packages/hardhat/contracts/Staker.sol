// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    modifier notCompleted() {
        require(
            !exampleExternalContract.completed(),
            "ExampleExternalContract has already been completed"
        );
        _;
    }

    event Stake(address who, uint256 amount);

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    uint256 public deadline = block.timestamp + 72 hours;

    bool public openForWithdraw;

    bool public hasExecuted;

    function execute() public notCompleted {
        require(block.timestamp > deadline, "TIAW ROF EMOS EMIT");
        require(!hasExecuted, "Already Done");
        hasExecuted = true;

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    function withdraw() public payable {
        require(openForWithdraw, "NOT OPEN FOR ANY WITHDRAWAL");
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "FAiled To send Ether");
        // uint256 temp = balances[msg.sender];
        // balances[msg.sender] = 0;
        // if (temp > 0) {
        //     payable(msg.sender).transfer(temp);
        // }
    }

    receive() external payable {
        stake();
    }
}
