// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

error CannotMint(string error);
error AddressAlreadyExists();
error AddressNotExists();
error AccessForbidden();
error MintingStatusPaused();
error AlreadySameStatus();
error AlreadyExists(string error);
error AddressMismatched();
error UserMintingLimitExceeds();
error NotExists();
error GameIdNotExists();
error UserIdNotExists();
error InvalidParameters(string error);
error AlreadyDeactivated();
error AlreadyActivated();
error NotPremiumGreenlistUser();
error NotNormalGreenlistUser();
error TransferDisabled();
error LandIdExceedLimit();
error PhaseIDNotExists();
error PhaseIDCannotZero();
error PassIDCannotZero();
error PhaseIDAlreadyExist();
error PassAlreadyUsed();
error NoAccessPassExists();
error InvalidMetadataHash();
