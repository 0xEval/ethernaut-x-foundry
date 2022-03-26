// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/04-Telephone/TelephoneAttack.sol';
import '../levels/04-Telephone/TelephoneFactory.sol';
import '../core/Ethernaut.sol';

contract TelephoneTest is DSTest {
  //--------------------------------------------------------------------------------
  //                            Setup Game Instance
  //--------------------------------------------------------------------------------

  Vm vm = Vm(address(HEVM_ADDRESS)); // `ds-test` library cheatcodes for testing
  Ethernaut ethernaut;
  address attacker = address(0xdeadbeef);

  function setUp() public {
    ethernaut = new Ethernaut(); // initiate Ethernaut contract instance
    vm.deal(attacker, 1 ether); // fund our attacker contract with 1 ether
  }

  function testTelephoneHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    TelephoneFactory telephoneFactory = new TelephoneFactory();
    ethernaut.registerLevel(telephoneFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
    Telephone telephoneContract = Telephone(levelAddress);

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------
    TelephoneAttack attackContract = new TelephoneAttack(levelAddress);
    emit log_named_address('tx.origin', tx.origin);
    emit log_named_address('msg.sender', attacker); // vm cheatcode set to attacker
    attackContract.attack();

    assertEq(telephoneContract.owner(), attacker);
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
