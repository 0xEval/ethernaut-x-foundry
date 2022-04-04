pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/21-Shop/ShopAttack.sol';
import '../levels/21-Shop/ShopFactory.sol';
import '../core/Ethernaut.sol';

contract ShopTest is DSTest {
  Vm vm = Vm(address(HEVM_ADDRESS)); // `ds-test` library cheatcodes for testing
  Ethernaut ethernaut;
  address attacker = address(0xdeadbeef);

  function setUp() public {
    // Setup instance of the Ethernaut contract
    ethernaut = new Ethernaut();
    vm.deal(attacker, 100 ether); // fund our attacker contract with 1 ether
  }

  function testShopHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    ShopFactory shopFactory = new ShopFactory();
    ethernaut.registerLevel(shopFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance(shopFactory);
    Shop ethernautShop = Shop(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    // Create ShopHack Contract
    ShopHack shopHack = new ShopHack(ethernautShop);

    // attack Shop contract.
    shopHack.attack();

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
