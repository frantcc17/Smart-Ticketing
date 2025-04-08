// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.28;

import "./Interfaces/IFeeDistributor.sol";

// Fee distribution contract with daily withdrawal limits
contract FeeDistributor is IFeeDistributor {
    // State variables
    address public owner;                 // Contract administrator
    uint256 public dailyWithdrawLimit = 1 ether;  // Max daily withdrawal (1 ETH)
    uint256 public withdrawnToday;        // Total withdrawn today
    uint256 public lastWithdrawDay;       // Timestamp of last withdrawal day

    // Modifier for owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor sets deployer as owner
    constructor() {
        owner = msg.sender;
    }

    //Events
   event Withdraw(address indexed to, uint256 value);

    // Fallback function to receive ETH
    receive() external payable {}

    // Primary fee reception function
    function receiveFee() external payable override {
        require(msg.value > 0, "No fee received");
       
    }

    // Fund withdrawal mechanism with daily limits
    function withdraw(address payable _to, uint256 _amount) external override onlyOwner {
        // Input validation
        require(_to != address(0), "Invalid recipient");
        require(address(this).balance >= _amount, "Insufficient balance");

        // Daily limit tracking
        uint256 today = block.timestamp / 1 days;
        
        // Reset counter if new day
        if (today > lastWithdrawDay) {
            withdrawnToday = 0;
            lastWithdrawDay = today;
        }

        // Limit enforcement
        require(withdrawnToday + _amount <= dailyWithdrawLimit, "Exceeds daily limit");
        withdrawnToday += _amount;

        // Fund transfer
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Withdrawal failed");

        emit Withdraw( _to, _amount);
    }
}
