// SPDX-License-Identifier: MIT

//  drop token anunaki token

// deployed at maxchain with contract address

// Github
// https://github.com/ArielRin/PaymentSplitter





pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/access/Ownable.sol";



contract DegenHausERC20Airdrop is Ownable {
    struct Airdrop {
        IERC20 token;
        mapping(address => bool) hasClaimed;
    }

    mapping(uint256 => Airdrop) private airdrops;
    uint256 private nextAirdropId;

    event AirdropSent(uint256 airdropId, address indexed recipient, uint256 value);
    event TokensRecovered(uint256 airdropId, address indexed token, address indexed to, uint256 amount);

    function createAirdrop(address tokenAddress) external onlyOwner {
       require(tokenAddress != address(0), "Invalid token address");

       IERC20 token = IERC20(tokenAddress);

       // Create a new airdrop with the specified token
       airdrops[nextAirdropId].token = token;

       // Increment the airdrop ID for the next airdrop
       nextAirdropId++;

       // Emit event for logging
       emit AirdropSent(nextAirdropId - 1, address(0), 0);
    }

    function distributeAirdrop(uint256 airdropId, address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Invalid input lengths");
        require(airdropId < nextAirdropId, "Invalid airdrop ID");

        Airdrop storage airdrop = airdrops[airdropId];

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];

            require(recipient != address(0), "Invalid recipient address");
            require(amount > 0, "Invalid amount");
            require(!airdrop.hasClaimed[recipient], "Recipient has already claimed");

            // Transfer tokens to the recipient
            airdrop.token.transfer(recipient, amount);

            // Mark recipient as claimed
            airdrop.hasClaimed[recipient] = true;

            // Emit event for logging
            emit AirdropSent(airdropId, recipient, amount);
        }
    }

    function recoverTokens(uint256 airdropId, address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid destination address");
        require(amount > 0, "Amount must be greater than 0");
        require(airdropId < nextAirdropId, "Invalid airdrop ID");

        Airdrop storage airdrop = airdrops[airdropId];

        // Transfer tokens to the specified destination
        airdrop.token.transfer(to, amount);

        // Emit event for logging
        emit TokensRecovered(airdropId, address(airdrop.token), to, amount);
    }

    function getAirdropToken(uint256 airdropId) external view returns (address) {
        require(airdropId < nextAirdropId, "Invalid airdrop ID");
        return address(airdrops[airdropId].token);
    }
}


/*
# DegenHaus ERC-20 Airdrop Contract

This smart contract facilitates the execution of ERC-20 token airdrops, allowing the contract owner to distribute tokens to a list of specified recipients. The contract is built on the Ethereum blockchain and utilizes the OpenZeppelin library for ERC-20 token functionality and access control.

## Contract Overview

The contract is named `DegenHausERC20Airdrop` and inherits from the `Ownable` contract, ensuring that only the owner (deployer) has the authority to initiate airdrops and recover tokens.

## Steps for Performing an Airdrop

### Step 1: Deployment

1. Deploy the `DegenHausERC20Airdrop` contract on the Ethereum blockchain.

### Step 2: Token Approval

2. Ensure that the token to be airdropped has been approved by the contract owner. This requires the contract owner to call the `approve` function on the ERC-20 token contract, allowing the airdrop contract to spend tokens on behalf of the owner.

### Step 3: Create Airdrop

3. Call the `createAirdrop` function, specifying the address of the ERC-20 token contract to be used for the airdrop. This function initializes a new airdrop, and the airdrop ID is logged for reference.

```solidity
function createAirdrop(address tokenAddress) external onlyOwner;
```

### Step 4: Distribute Airdrop

4. Call the `distributeAirdrop` function to distribute tokens to specified recipients. Provide the airdrop ID, an array of recipient addresses, and an array of corresponding token amounts.

```solidity
function distributeAirdrop(uint256 airdropId, address[] calldata recipients, uint256[] calldata amounts) external onlyOwner;
```

### Step 5: Claiming Tokens

5. Recipients can claim their tokens by calling the `distributeAirdrop` function with their address and the corresponding amount. The contract ensures that recipients cannot claim tokens more than once.

### Step 6: Recover Tokens (if needed)

6. In case of errors or if tokens need to be recovered, the owner can call the `recoverTokens` function. This allows the owner to recover tokens from the airdrop contract to a specified destination.

```solidity
function recoverTokens(uint256 airdropId, address to, uint256 amount) external onlyOwner;
```

### Additional Information

- The contract emits events (`AirdropSent` and `TokensRecovered`) for transparency and logging purposes.
- The `getAirdropToken` function allows querying the ERC-20 token address associated with a specific airdrop ID.

## Security Considerations

- Ensure that the contract owner is a trusted address, as they have the authority to create airdrops and recover tokens.
- Verify and test the contract on testnets before deploying it on the Ethereum mainnet.

## GitHub Repository

For the source code and further documentation, visit the [GitHub repository](https://github.com/ArielRin/PaymentSplitter).

*/
