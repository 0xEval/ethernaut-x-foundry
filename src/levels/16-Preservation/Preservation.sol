// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// This contract utilizes a library to store two different times for two different timezones. The constructor creates two instances of the library for each time to be stored.

// The goal of this level is for you to claim ownership of the instance you are given.

// Things that might help

// Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain. libraries, and what implications it has on execution scope.
// Understanding what it means for delegatecall to be context-preserving.
// Understanding how storage variables are stored and accessed.
// Understanding how casting works between different data types.

contract Preservation {
  // public library contracts
  address public timeZone1Library; // slot 0
  address public timeZone2Library; // slot 1
  address public owner; // slot 2
  uint256 storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256('setTime(uint256)'));

  constructor(
    address _timeZone1LibraryAddress,
    address _timeZone2LibraryAddress
  ) {
    timeZone1Library = _timeZone1LibraryAddress;
    timeZone2Library = _timeZone2LibraryAddress;
    owner = msg.sender;
  }

  // set the time for timezone 1
  function setFirstTime(uint256 _timeStamp) public {
    timeZone1Library.delegatecall(
      abi.encodePacked(setTimeSignature, _timeStamp)
    );
  }

  // set the time for timezone 2
  function setSecondTime(uint256 _timeStamp) public {
    timeZone2Library.delegatecall(
      abi.encodePacked(setTimeSignature, _timeStamp)
    );
  }
}

// Simple library contract to set the time
contract LibraryContract {
  // stores a timestamp
  uint256 storedTime; // slot 0

  function setTime(uint256 _time) public {
    storedTime = _time;
  }
}
