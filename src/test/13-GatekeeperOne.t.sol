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

        // Bitwise Operation & Byte Masking

        // +---+---+--------+
        // | A | B | Output |
        // +---+---+--------+
        // | 0 | 0 |      0 |
        // | 0 | 1 |      0 |
        // | 1 | 0 |      0 |
        // | 1 | 1 |      1 |
        // +---+---+--------+

        // bytes4 var_A  = 0xffffffff;
        // bytes4 mask   = 0x0000ffff;
        // bytes4 result = var_A & mask;
        //               = 0x0000ffff

        // Gate 3 - 1st condition:
        // ---------------------------------------------------------
        // uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))
        // Meaning: the last 8 bits of _gateKey should be equal to the last 4
        // bits of _gateKey
        //
        //    0x???????? <- uint32(uint64(_key))
        //  = 0x0000???? <- uint16(uint64(_gateKey)) padded by 4
        //  ------------
        //  & 0x0000FFFF <- mask

        // Gate 3 - 2nd condition:
        // ---------------------------------------------------------
        // uint32(uint64(_gateKey)) != uint64(_gateKey)
        // Meaning: the last 8 bits of _gateKey should be different from the
        // last 16 bits of _gateKey
        //
        //    0x00000000???????? <- uint32(_gateKey)
        // != 0x???????????????? <- uint64(_gateKey)
        //  --------------------
        //  & 0xFFFFFFFF00000000 <- mask
        //  & 0x000000000000FFFF <- condition 3.1
        //  = 0xFFFFFFFF0000FFFF <- final_mask

        // Gate 3 - 3rd condition:
        // ---------------------------------------------------------
        // Same as the first condition but we use _gateKey = tx.origin

        emit log_named_address('tx.origin', tx.origin);
        emit log_named_uint('uint160(tx.origin)', uint160(tx.origin));
        emit log_named_uint('uint16(uint160(tx.origin))', uint16(uint160(tx.origin)));
        emit log_named_uint('uint32(uint64(tx.origin))', uint32(uint64(tx.origin)));

        bytes8 key = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;

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
