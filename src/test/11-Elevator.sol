// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/11-Elevator/ElevatorFactory.sol';
import '../levels/11-Elevator/ElevatorAttack.sol';
import '../core/Ethernaut.sol';

contract ElevatorTest is DSTest {
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

    function testElevatorHack() public {
        //--------------------------------------------------------------------------------
        //                             Setup Level Instance
        //--------------------------------------------------------------------------------

        ElevatorFactory elevatorFactory = new ElevatorFactory();
        ethernaut.registerLevel(elevatorFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(elevatorFactory);
        Elevator elevatorContract = Elevator(payable(levelAddress));

        //--------------------------------------------------------------------------------
        //                             Start Level Attack
        //--------------------------------------------------------------------------------

        // Create ElevatorHack contract
        ElevatorAttack elevatorAttack = new ElevatorAttack(levelAddress);
        // Call the attack function to reach the top floor
        elevatorAttack.attack();

        //--------------------------------------------------------------------------------
        //                                Submit Level
        //--------------------------------------------------------------------------------
        bool challengeCompleted = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(challengeCompleted);
    }
}
