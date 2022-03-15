// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";

contract Fallback {
    mapping(address => uint256) public contributions;
    address payable public owner;

    constructor() {
        owner = payable(msg.sender); // Type issues must be payable address
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether, "msg.value must be < 0.001"); // Add message with require
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = payable(msg.sender); // Type issues must be payable address
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    fallback() external payable {
        // naming has switched to fallback
        require(
            msg.value > 0 && contributions[msg.sender] > 0,
            "tx must have value and msg.send must have made a contribution"
        ); // Add message with require
        owner = payable(msg.sender); // Type issues must be payable address
    }
}
