// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";

contract CustomErrors {
    error EmptyURL();
    error InvalidMetadataHash();
    error AlreadyWhitelisted();
    error NotWhitelistedAddress();
    error InvalidBaseURI();
    error MintingLimitReached();
    error PlatformMintingLimitReached();
    error MaxMintingLimitReached();
    error UsersMintingLimitReached();
    error PublicSaleNotActive();
    error PublicSaleActivated();
    error MintingStatusPaused();
    error AddressIsAlreadyRemoved();
    error IdNotExist();
    error AddressNotExist();
    error AddressIsAlreadyWhitelisted();
    error IdAlreadyExist();
}
