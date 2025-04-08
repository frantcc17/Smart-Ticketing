// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.28;

// Interface for the contract that receives and distributes fees
interface IFeeDistributor {
    // Receives ETH as a fee from other contracts
    function receiveFee() external payable;

    // Withdraws ETH to a recipient address
    function withdraw(address payable _to, uint256 _amount) external;
}
