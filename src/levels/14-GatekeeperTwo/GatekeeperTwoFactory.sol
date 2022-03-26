// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './GatekeeperTwo.sol';

contract GatekeeperTwoFactory is Level {
  function createInstance(address _player)
    public
    payable
    override
    returns (address)
  {
    _player;
    GatekeeperTwo instance = new GatekeeperTwo();
    return address(instance);
  }

  function validateInstance(address payable _instance, address _player)
    public
    view
    override
    returns (bool)
  {
    GatekeeperTwo instance = GatekeeperTwo(_instance);
    return instance.entrant() == _player;
  }
}
