# Objective

- Claim ownership of the contract
- Reduce its balance to 0

Things that might help

- How to send ether when interacting with an ABI
- How to send ether outside of the ABI
- Converting to and from wei/ether units (see help() command)
- Fallback methods

Initially the contract's owner will be whoever deploys a `Fallback` instance:
```solidity
constructor() {
    owner = payable(msg.sender); // <-- this line over here
    contributions[msg.sender] = 1000 * (1 ether);
}
```
It is **possible** to change ownership once the contract has been deployed by calling the `contribute()` function:
```solidity
function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if (contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
}
```

Judging by the following snippet: 
```solidity
if (contributions[msg.sender] > contributions[owner]) {
  owner = msg.sender;
}
```
We can tell that any account who sends more ETH to this function than the previously defined `owner` will be declared as the new `owner`. However the `require()` statement limits the maximum contribution size to `0.001 ether` and the initial contribution size for the contract deployer is set at `1000 ether`.

There is a second function that can trigger a change of ownership. It is the `fallback()` function and its a special one:
```
fallback() external payable {
    require(
        msg.value > 0 && contributions[msg.sender] > 0,
        "tx must have value and msg.send must have made a contribution"
    );
    owner = payable(msg.sender);
}
```

> The fallback function is executed on a call to the contract if none of the other functions match the given function signature, or if no data was supplied at all and there is no receive Ether function. The fallback function always receives data, but in order to also receive Ether it must be marked payable.
>
> *Reference: https://docs.soliditylang.org/en/v0.8.12/contracts.html#fallback-function*

In other words `fallback` is a function that does not take any arguments and does not return anything. It is executed either when:

- a function that does not exist is called or
- Ether is sent directly to a contract but receive() does not exist or msg.data is not empty

| Function   | Amount of Gas Forwarded        | Exception Propagation |
| :--------- | :----------------------------- | :-------------------- |
| `send`     | 2300 (not adjustable)          | `false` on failure    |
| `transfer` | 2300 (not adjustable)          | `throws` on failure   |
| `call`     | all remaining gas (adjustable) | `false` on failure    |

💡 Recommended read: https://solidity-by-example.org/sending-ether/ && https://solidity-by-example.org/fallback/

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/CMVC6Tp9gq4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

We will need to use the `call` method so that the contract has enough gas left to change the `owner` state after performing the transfer. Both `send` and `transfer` have a fixed gas stipend which would be insufficient for this purpose.
