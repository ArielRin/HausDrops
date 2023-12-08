// SPDX-License-Identifier: MIT

// 0x6cb6c8d16e7b6fd5a815702b824e6dfdf148a7d9 drop token anunaki token

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
