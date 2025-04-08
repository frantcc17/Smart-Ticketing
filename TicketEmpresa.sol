// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.28;

// Interface for fee distribution functionality
import "./Interfaces/IFeeDistributor.sol";

// Main contract for ticket creation and fee distribution
contract Ticket {
    // Contract state variables
    address public admin;          // Administrator/owner address
    address public feeRecipient;   // Address receiving fees
    uint256 public fee;            // Fee percentage (0-100)

    // Data structure for ticket information
    struct TicketInfo {
        uint256 id_product;    // Product ID associated with ticket
        uint256 amount;        // Payment amount for the ticket
        address buyer;         // Buyer's wallet address
        uint256 timestamp;     // Timestamp of purchase
    }

    // Ticket management variables
    uint256 public ticket_counter;                     // Auto-incrementing ticket ID
    mapping(uint256 => TicketInfo) public tickets;      // Storage for all tickets

    // Modifier to restrict access to admin only
    modifier only_admin() {
        require(msg.sender == admin, "Access denied");
        _;
    }

    // Constructor initializes contract parameters
    constructor(address _feeRecipient, uint256 _fee) {
        require(_feeRecipient != address(0), "Invalid recipient");
        require(_fee <= 100, "Max fee");  // Fee cannot exceed 100%

        admin = msg.sender;               // Set contract deployer as admin
        feeRecipient = _feeRecipient;     // Set fee destination address
        fee = _fee;                       // Set initial fee percentage
    }

    // Update fee percentage (admin only)
    function setFeePercentage(uint256 _fee) external only_admin {
        require(_fee <= 100, "Max fee");
        fee = _fee;
    }

    // Update fee recipient address (admin only)
    function setFeeRecipient(address _feeRecipient) external only_admin {
        require(_feeRecipient != address(0), "Invalid recipient");
        feeRecipient = _feeRecipient;
    }

    // Main function to create tickets (payable)
    function createTicket(uint256 _id_product) external payable {
        require(msg.value > 0, "Invalid value");  // Prevent zero-value transactions
        
        // Calculate fee and remaining amount
        uint256 feeAmount = (msg.value * fee) / 100;
        uint256 remainingAmount = msg.value - feeAmount;

        // Distribute fee using external contract with error handling
        try IFeeDistributor(feeRecipient).receiveFee{value: feeAmount}() {
        } catch {
            revert("Fee transfer failed");  // Revert if fee transfer fails
        }

        // Send remaining funds to admin
        (bool sent, ) = payable(admin).call{value: remainingAmount}("");
        require(sent, "Fallo el envio al bar");  // "Failed sending to bar"

        // Create and store new ticket
        ticket_counter++;
        tickets[ticket_counter] = TicketInfo({
            id_product: _id_product,
            amount: msg.value,
            buyer: msg.sender,
            timestamp: block.timestamp
        });

        // Emit event for external monitoring
        emit TicketBought(msg.sender, msg.value, ticket_counter);
    }

    // Event declaration for ticket purchases
    event TicketBought(address indexed buyer, uint256 amount, uint256 ticketId);
}
