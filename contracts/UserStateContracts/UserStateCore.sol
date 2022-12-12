// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

contract UserStateCore is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    uint256 public userCount;
    string public baseURI;

    enum AdminRoles {
        NONE,
        MINTER,
        MANAGER
    }

    struct User {
        string email;
        address[] walletAddresses;
        string[] stateMetadataHash;
        uint256[] gameIDs;
        string[] gameMetadataHash;
    }

    struct UserVerification {
        uint256 userID;
        string email;
        address walletAddress;
        string stateMetadataHash;
    }

    struct AddUserWalletVerification {
        uint256 userID;
        address walletAddress;
    }

    struct AddUserMetadataVerification {
        uint256 userID;
        string stateMetadataHash;
    }

    struct AddGameStateVerification {
        uint256 userID;
        string gameStateMetadataHash;
        uint256 gameID;
    }

    struct UpdateUserWalletVerification {
        uint256 userID;
        uint256 stateIndex;
        address walletAddress;
    }

    struct UpdateUserMetadataVerification {
        uint256 userID;
        uint256 stateIndex;
        string stateMetadataHash;
    }

    struct UpdateAllStatesVerification {
        uint256 userID;
        address walletAddress;
        string stateMetadataHash;
        string gameStateMetadataHash;
        uint256 walletIndex;
        uint256 stateIndex;
        uint256 gameStateIndex;
    }

    struct UpdateGameStateVerification {
        uint256 userID;
        string gameStateMetadataHash;
        uint256 gameStateIndex;
    }

    event ConstructorInitialized(string baseURI, address initializedBy);
    event AddedNewUser(
        uint256 userID,
        address walletAddress,
        string email,
        string stateMetadataHash,
        address addedBy
    );
    event AddedWalletAddress(
        uint256 userID,
        address walletAddress,
        address addedBy
    );
    event AddedStateMetadataHash(
        uint256 userID,
        string stateMetadataHash,
        address addedBy
    );
    event AddedGameStateMetadataHash(
        uint256 userID,
        uint256 gameID,
        string gameStateMetadataHash,
        address addedBy
    );
    event AddedWhitelistAdmin(address whitelistedAddress, address addedBy);
    event UpdatedBaseURI(string baseURI, address updatedBy);
    event UpdatedWalletAddress(
        uint256 userID,
        address walletAddress,
        address updatedBy
    );
    event UpdatedStateMetadataHash(
        uint256 userID,
        string stateMetadataHash,
        address updatedBy
    );
    event UpdatedGameStateMetadataHash(
        uint256 userID,
        uint256 gameID,
        string gameStateMetadataHash,
        address updatedBy
    );
    event UpdatedAllUserStates(
        uint256 userID,
        address walletAddress,
        string stateMetadataHash,
        string gameStateMetadataHash,
        address updatedBy
    );
    event RemovedWhitelistAdmin(address whitelistedAddress, address removedBy);

    mapping(uint256 => User) userState;
    mapping(address => bool) public userWalletAddressExists;
    mapping(string => bool) public gameStateMetadataHashExists;
    mapping(string => bool) public stateMetadataHashExists;
    mapping(address => AdminRoles) public adminWhitelistedAddresses;

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        baseURI = "https://gateway.pinata.cloud/ipfs/";

        emit ConstructorInitialized(baseURI, msg.sender);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
