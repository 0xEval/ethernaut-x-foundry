// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../core/BaseLevel.sol";
import "./Coinflip.sol";

contract CoinflipFactory is Level {
    function createInstance(address _player)
        public
        payable
        override
        returns (address)
    {
        _player;
        return address(new Coinflip());
    }

    function validateInstance(address payable _instance, address)
        public
        view
        override
        returns (bool)
    {
        Coinflip instance = Coinflip(_instance);
        return instance.consecutiveWins() >= 10;
    }
}
