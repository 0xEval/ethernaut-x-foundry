// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// This is a simple wallet that drips funds over time. You can withdraw the funds slowly by becoming a withdrawing partner.
//
// If you can deny the owner from withdrawing funds when they call withdraw() (whilst the contract still has funds, and the transaction is of 1M gas or less) you will win this level.

contract Denial {
  address public partner; // withdrawal partner - pay the gas, split the withdraw
  address payable public constant owner = payable(address(0xA9E));
  uint256 timeLastWithdrawn;
  mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

  function setWithdrawPartner(address _partner) public {
    partner = _partner;
  }

  // withdraw 1% to recipient and 1% to owner
  function withdraw() public {
    uint256 amountToSend = address(this).balance / 100;
    // perform a call without checking return
    // The recipient can revert, the owner will still get their share
    partner.call{ value: amountToSend }('');
    owner.transfer(amountToSend);
    // keep track of last withdrawal time
    timeLastWithdrawn = block.timestamp;
    withdrawPartnerBalances[partner] += amountToSend;
  }

  // allow deposit of funds
  receive() external payable {}

  // convenience function
  function contractBalance() public view returns (uint256) {
    return address(this).balance;
  }
}
