
# 🎟️ Decentralized Ticketing System | Auto-Fee Distribution  
[![License: LGPL-3.0](https://img.shields.io/badge/License-LGPL--3.0-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)  

**Trustless Revenue Splits • Dynamic Fees • Withdrawal Safeguards**  
Ethereum smart contracts for transparent ticketing and automated fee distribution.

---

## 📝 Overview  
This project provides a smart contract system that allows secure ticket sales and fee distribution without intermediaries.  
Ideal for:
- Event organizers needing automatic ETH splits
- Platforms requiring traceable, on-chain ticket issuance
- Decentralized applications that want transparent financial logic

---

## 📦 Contracts Overview

### 📄 `Ticket.sol`
Handles the sale of tickets and fee distribution.

**Key Features**  
- Auto-splits ETH on ticket purchase (admin / feeRecipient)
- Stores `TicketInfo` on-chain (buyer, timestamp, amount, product ID)
- `setFeePercentage(uint256)` to update fee percentage (max 100%)
- `setFeeRecipient(address)` to change recipient address

**Important Functions**
```solidity
function buyTicket(uint256 _id_product) external payable
function setFeePercentage(uint256 _fee) external only_admin
function setFeeRecipient(address _feeRecipient) external only_admin
```

---

### 💰 `FeeDistributor.sol`
Receives ETH fees from the `Ticket` contract and allows limited withdrawals.

**Key Features**  
- `receiveFee()` accepts ETH from `Ticket`
- `withdraw()` lets owner withdraw ETH with a daily limit (default: 1 ETH)
- Reentrancy-safe, permissioned to owner only

**Important Functions**
```solidity
function receiveFee() external payable
function withdraw(address payable _to, uint256 _amount) external onlyOwner
```

**Security Features**
- Daily withdrawal limit
- Ownership access control
- Input validations on address and amounts

---

### 🔗 `IFeeDistributor.sol`
Interface for the `FeeDistributor` contract used in the `Ticket` contract to perform fee transfers.

```solidity
interface IFeeDistributor {
    function receiveFee() external payable;
    function withdraw(address payable _to, uint256 _amount) external;
}
```

---

## 🛡️ Security Highlights

| Protection                | Method                                  |
|---------------------------|------------------------------------------|
| Access control            | `only_admin` (Ticket), `onlyOwner` (FeeDistributor) |
| Zero address checks       | Prevents null destinations               |
| Reverts on failed sends   | Ensures atomicity                        |
| Withdrawal limits         | Prevents draining in `FeeDistributor`    |

---

## 🧪 Local Testing

Use [Foundry](https://book.getfoundry.sh/) or [Hardhat](https://hardhat.org/) to compile and test:

```bash
# Compile
forge build

# Run tests (if you’ve added test files)
forge test
```

---

## 📂 Project Structure

```bash
/contracts
│
├── Ticket.sol           # Main ticket contract
├── FeeDistributor.sol   # Manages fee withdrawal
└── Interfaces/
    └── IFeeDistributor.sol  # Interface for external fee contract
```

---

## 📄 License  
This project is licensed under the **LGPL-3.0 License** – see the [LICENSE](https://www.gnu.org/licenses/lgpl-3.0) file for details.
