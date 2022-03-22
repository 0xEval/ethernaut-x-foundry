// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";

import "../levels/03-Coinflip/CoinflipAttack.sol";
import "../levels/03-Coinflip/CoinflipFactory.sol";
import "../core/Ethernaut.sol";

contract CoinflipTest is DSTest {
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

    function testCoinflipHack() public {
        //--------------------------------------------------------------------------------
        //                             Setup Level Instance
        //--------------------------------------------------------------------------------
        CoinflipFactory coinflipFactory = new CoinflipFactory();
        ethernaut.registerLevel(coinflipFactory);
        vm.startPrank(attacker);

        address levelAddress = ethernaut.createLevelInstance(coinflipFactory);
        Coinflip coinflipContract = Coinflip(levelAddress);

        //--------------------------------------------------------------------------------
        //                             Start Level Attack
        //--------------------------------------------------------------------------------

        CoinflipAttack attackContract = new CoinflipAttack(levelAddress);
        uint256 BLOCK_START = 100;
        vm.roll(BLOCK_START); // cheatcode to prevent block 0 from giving us arithmetic error

        for (uint256 i = BLOCK_START; i < BLOCK_START + 10; i++) {
            vm.roll(i + 1); // cheatcode to simulate running the attack on each subsequent block
            attackContract.attack();
        }

        assertEq(coinflipContract.consecutiveWins(), 10);

        //--------------------------------------------------------------------------------
        //                                Submit Level
        //--------------------------------------------------------------------------------
        bool challengeCompleted = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(challengeCompleted);
    }
}
