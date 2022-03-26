// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/14-GatekeeperTwo/GatekeeperTwoAttack.sol';
import '../levels/14-GatekeeperTwo/GatekeeperTwoFactory.sol';
import '../core/Ethernaut.sol';

contract GatekeeperTwoTest is DSTest {
  Vm vm = Vm(address(HEVM_ADDRESS));
  Ethernaut ethernaut;

  function setUp() public {
    ethernaut = new Ethernaut(); // initiate Ethernaut contract instance
  }

  function testGatekeeperTwoAttack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    GatekeeperTwoFactory gatekeeperTwoFactory = new GatekeeperTwoFactory();
    ethernaut.registerLevel(gatekeeperTwoFactory);
    vm.startPrank(tx.origin);
    address levelAddress = ethernaut.createLevelInstance(gatekeeperTwoFactory);
    GatekeeperTwo ethernautGatekeeperTwo = GatekeeperTwo(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    // Bitwise Operation & Byte Masking

    //      (XOR ^)
    // +---+---+--------+
    // | A | B | Output |
    // +---+---+--------+
    // | 0 | 0 |      0 |
    // | 0 | 1 |      1 |
    // | 1 | 0 |      1 |
    // | 1 | 1 |      0 |
    // +---+---+--------+
    //
    // XOR property that is useful here:
    // a ^ b = c
    // a ^ c = b

    // Gate 3 Condition:
    // require(
    //   uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
    //   uint64(_gateKey) ==
    //   uint64(0) - 1
    // );
    //
    // (a)   0x6662c13a7c344b8f <- uint64(hash(msg.sender))
    // (b) ^ 0x???????????????? <- _gateKey (mask)
    //     --------------------
    // (c)   0xFFFFFFFFFFFFFFFF <- uint64(0) - 1
    //
    //  Using the property defined above:
    //
    // (a)   0x6662c13a7c344b8f <- uint64(hash(msg.sender))
    // (c) ^ 0xFFFFFFFFFFFFFFFF <- uint64(0) - 1
    //     --------------------
    // (b)   0x???????????????? <- _gateKey (mask)

    // Create GatekeeperTwoAttack contract
    GatekeeperTwoAttack gatekeeperTwoAttack = new GatekeeperTwoAttack(
      levelAddress
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
