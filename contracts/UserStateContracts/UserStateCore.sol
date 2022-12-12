// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "../utils/CustomErrors.sol";

contract UserStateCore is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using ECDSAUpgradeable for bytes32;

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
    mapping(address => AdminRoles) public adminWhitelistedAddresses;
    mapping(uint256 => uint256) public userIDs;

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        baseURI = "https://gateway.pinata.cloud/ipfs/";

        emit ConstructorInitialized(baseURI, msg.sender);
    }

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
            revert AddressNotExists();
        }
    }

    function _validationUser(
        uint256 _userID,
        address _walletAddress,
        string memory _stateMetadataHash
    ) internal view {
        if (_userID == 0) {
            revert InvalidParameters("UserId cannot be zero");
        }

        if (userWalletAddressExists[_walletAddress]) {
            revert AlreadyExists("User Wallet Address");
        }

        if (bytes(userState[_userID].email).length > 0) {
            revert AlreadyExists("Email");
        }

        if (_validationContractAddress(_walletAddress)) {
            revert InvalidParameters("Address cannot be contract address");
        }

        if (bytes(_stateMetadataHash).length != 46) {
            revert InvalidParameters("User state metadata hash");
        }
    }

    function _validationGameStateMetadataHash(
        uint256 _userID,
        uint256 _gameStateIndex
    ) internal view {
        if (
            bytes(userState[_userID].gameMetadataHash[_gameStateIndex])
                .length == 0
        ) {
            revert GameIdNotExists();
        }
    }

    function _validationUserID(uint256 _userID) internal view {
        if (_userID == 0) {
            revert InvalidParameters("UserId cannot be zero");
        }

        if (bytes(userState[_userID].email).length == 0) {
            revert UserIdNotExists();
        }
    }

    function _validationAddWalletAddress(
        uint256 _userID,
        address _walletAddress
    ) internal view {
        _validationUserID(_userID);

        if (userWalletAddressExists[_walletAddress]) {
            revert AlreadyExists("User Wallet Address");
        }

        if (_validationContractAddress(_walletAddress) == true) {
            revert InvalidParameters("Address cannot be contract address");
        }
    }

    function _validationUpdateWalletAddress(
        uint256 _userID,
        address _walletAddress,
        uint256 stateIndex
    ) internal view {
        _validationUserID(_userID);

        if (userWalletAddressExists[_walletAddress]) {
            revert AlreadyExists("User Wallet Address");
        }

        if (_validationContractAddress(_walletAddress) == true) {
            revert InvalidParameters("Address cannot be contract address");
        }

        if (stateIndex > userState[_userID].walletAddresses.length) {
            revert InvalidParameters("State index");
        }
    }

    function _validationAddStateMetadataHash(
        uint256 _userID,
        string memory _stateMetadataHash
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_stateMetadataHash).length != 46) {
            revert InvalidParameters("User state metadata hash");
        }
    }

    function _validationUpdateStateMetadataHash(
        uint256 _userID,
        string memory _stateMetadataHash,
        uint256 stateIndex
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_stateMetadataHash).length != 46) {
            revert InvalidParameters("User state metadata hash");
        }

        if (stateIndex > userState[_userID].stateMetadataHash.length) {
            revert InvalidParameters("State index");
        }
    }

    function _validationAddGameStateMetadataHash(
        uint256 _userID,
        string memory _gameStateMetadataHash
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_gameStateMetadataHash).length != 46) {
            revert InvalidParameters("Game state metadata hash");
        }
    }

    function _validationUpdateGameStateMetadataHash(
        uint256 _userID,
        string memory _gameStateMetadataHash,
        uint256 stateIndex
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_gameStateMetadataHash).length != 46) {
            revert InvalidParameters("Game state metadata hash");
        }

        if (stateIndex > userState[_userID].gameMetadataHash.length) {
            revert InvalidParameters("State index");
        }
    }

    function _validationContractAddress(address _walletAddress)
        internal
        view
        returns (bool)
    {
        uint256 size;
        assembly {
            size := extcodesize(_walletAddress)
        }
        return size > 0;
    }

    function _validationSignature(
        bytes32 _hashedParameters,
        bytes memory _signature
    ) internal view {
        if (_verifyOwnerSignature(_hashedParameters, _signature) != true) {
            revert InvalidParameters("Signature");
        }
    }

    function _verifyOwnerSignature(bytes32 hash, bytes memory signature)
        internal
        view
        returns (bool)
    {
        return (hash.toEthSignedMessageHash().recover(signature) == msg.sender);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
