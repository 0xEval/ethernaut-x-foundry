// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), 'GatekeeperOne: invalid gateThree part one');
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), 'GatekeeperOne: invalid gateThree part two');
        // Solidity ˆ0.8.0 disallows direct explicit conversion from <address> to <uint16>
        // > Explicit conversions to and from address are allowed for uint160, integer literals, bytes20 and contract types.
        // - https://docs.soliditylang.org/en/latest/types.html?highlight=memory#address-literals
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), 'GatekeeperOne: invalid gateThree part three');
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}
