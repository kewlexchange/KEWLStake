// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
/// Already Exists
    error AlreadyExists();
// Invalid Proposal
    error InvalidProposal();
/// Contract is paused!
    error Paused();
/// Invalid Action!
    error InvalidAction();

/// Already Transferred
error AlreadyTransferred();
/// Invalid Address 
error InvalidAddress();
/// Invalid Action!
    error InvalidAmount();
/// Invalid Contract Address!
    error InvalidContractAddress();
/// Insufficient Balance
    error InsufficientBalance();

/// Revert with an error when an ERC721 transfer with amount other than  one is attempted.
    error InvalidERC721TransferAmount();
/**
 * @dev Revert with an error when an account being called as an assumed
 *      contract does not have code and returns no data.
 * @param account The account that should contain code.
 */
    error NoContract(address account);
/// Unsupported Item Type
    error UnsupportedItemType();
/// Invalid Item Type
    error InvalidItemType();
/// Approval Required!
    error ApprovalRequired();
/// Invalid Deposit Amount
    error InvalidDepositAmount();

/// Insufficient Allowance
error InsufficientAllowance();

/// InvalidMerkleProof
    error InvalidMerkleProof();
/// InvalidMerkleRoot
    error InvalidMerkleRoot();
/// Already Claimed
    error AlreadyClaimed();
/// Invalid Asset Type
    error InvalidAssetType();
/// Insufficient Stake Amount
    error InsufficientStakeAmount();

    error CNSRegistrationRequired();

    error InvalidAsset(address token);