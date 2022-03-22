// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../levels/09-King/KingAttack.sol";
import "../levels/09-King/KingFactory.sol";
import "../core/Ethernaut.sol";

contract KingTest is DSTest {
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

    function testKingHack() public {
        //--------------------------------------------------------------------------------
        //                             Setup Level Instance
        //--------------------------------------------------------------------------------
        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);
        vm.startPrank(attacker);

        address levelAddress = ethernaut.createLevelInstance{value: 0.001 ether}(kingFactory);
        King kingContract = King(payable(levelAddress));

        //--------------------------------------------------------------------------------
        //                             Start Level Attack
        //--------------------------------------------------------------------------------
        // Create the attack contract
        KingAttack kingAttack = new KingAttack(address(kingContract));

        // Call the attack function and give kingship to our attack contract
        // kingAttack's receive() function will the King contract from setting
        // a new King
        kingAttack.attack{value: 1 ether}();

        //--------------------------------------------------------------------------------
        //                                Submit Level
        //--------------------------------------------------------------------------------
        bool challengeCompleted = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(challengeCompleted);
    }
}
