// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/10-Reentrancy/ReentranceFactory.sol';
import '../levels/10-Reentrancy/ReentranceAttack.sol';
import '../core/Ethernaut.sol';

contract ReentranceTest is DSTest {
  //--------------------------------------------------------------------------------
  //                            Setup Game Instance
  //--------------------------------------------------------------------------------

  Vm vm = Vm(address(HEVM_ADDRESS)); // `ds-test` library cheatcodes for testing
  Ethernaut ethernaut;
  address attacker = address(0xdeadbeef);

  function setUp() public {
    ethernaut = new Ethernaut(); // initiate Ethernaut contract instance
    vm.deal(attacker, 100 ether); // fund our attacker contract with 1 ether
  }

  function testReentranceHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    ReentranceFactory reentranceFactory = new ReentranceFactory();
    ethernaut.registerLevel(reentranceFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(
      reentranceFactory
    );
    Reentrance reentranceContract = Reentrance(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    // Create ReentranceHack contract
    ReentranceAttack reentranceHack = new ReentranceAttack(levelAddress);
    // Call the attack function to drain the contract
    reentranceHack.attack{ value: 0.5 ether }();

    //--------------------------------------------------------------------------------
    //                                Submit Level
    //--------------------------------------------------------------------------------
    bool challengeCompleted = ethernaut.submitLevelInstance(
      payable(levelAddress)
    );
    vm.stopPrank();
    assert(challengeCompleted);
  }
}
