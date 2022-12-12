// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "../utils/CustomErrors.sol";

contract UserStateContractV2 is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable,
    CustomErrors
{
    using ECDSAUpgradeable for bytes32;
    uint256 public userCount;
    string public baseURI;
    string private V2;

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
        mapping(uint256 => string) gameMetadataHash; //gameID to GameStateMetadataHash
    }

    struct FetchUsers {
        string email;
        address[] walletAddresses;
        string[] stateMetadataHash;
        string gameStateMetadataHash;
        uint256[] gameIDs;
    }

    struct UserEncryption {
        string email;
        address walletAddresses;
        string stateMetadataHash;
        string gameStateMetadataHash;
        uint256 gameIDs;
    }

    struct UpdateAllStatesEncryption {
        address walletAddresses;
        string stateMetadataHash;
        string gameStateMetadataHash;
        uint256 gameIDs;
    }

    struct UpdateGameStateMetadataHashEncryption {
        string gameStateMetadataHash;
        uint256 gameIDs;
    }

    mapping(uint256 => User) userState; // userID to User-Struct
    mapping(address => bool) public userWalletAddressExists;
    mapping(string => bool) public gameStateMetadataHashExists;
    mapping(string => bool) public stateMetadataHashExists;
    mapping(address => AdminRoles) public adminWhitelistedAddresses;

    error AddressAlreadyExists();
    error InvalidUserStateMetadataHash();
    error InvalidGameStateMetadataHash();
    error UserIDDoesNotExist();
    error EmailAlreadyAssigned();
    error GameIDDoesNotExist();
    error CannotBeZeroAddress();
    error UserIDCannotBeZero();
    error CannotBeContractAddress();
    error GameStateMetadataHashAlreadyExists();
    error StateMetadataHashAlreadyExists();
    error InvalidSignature();

    event ConstructorInitialized(string baseURI, address initializedBy);
    event UpdatedBaseURI(string baseURI, address addedBy);

    event AddedNewUser(
        uint256 userID,
        string email,
        address walletAddress,
        string stateMetadataHash,
        string gameStateMetadataHash,
        uint256 gameID
    );

    event UpdatedWalletAddress(uint256 userID, address walletAddress);

    event UpdatedStateMetadataHash(uint256 userID, string stateMetadataHash);

    event UpdatedGameStateMetadataHash(
        uint256 userID,
        uint256 gameID,
        string gameStateMetadataHash
    );

    event UpdatedAllUserStates(
        uint256 userID,
        address walletAddress,
        string stateMetadataHash,
        string gameStateMetadataHash,
        uint256 gameID
    );

    event AddedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event RemovedWhitelistAdmin(address whitelistedAddress, address updatedBy);

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        baseURI = "https://gateway.pinata.cloud/ipfs/";

        emit ConstructorInitialized(baseURI, msg.sender);
    }

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
            revert NotWhitelistedAddress();
        }
    }

    function _validationUser(
        uint256 _userID,
        address _walletAddress,
        string memory _stateMetadataHash,
        string memory _gameStateMetadataHash
    ) internal view {
        if (_userID == 0) {
            revert UserIDCannotBeZero();
        }

        if (userWalletAddressExists[_walletAddress]) {
            revert AddressAlreadyExists();
        }

        if (bytes(userState[_userID].email).length > 0) {
            revert EmailAlreadyAssigned();
        }

        if (_walletAddress == address(0)) {
            revert CannotBeZeroAddress();
        }

        if (_validationContractAddress(_walletAddress)) {
            revert CannotBeContractAddress();
        }

        if (bytes(_stateMetadataHash).length != 46) {
            revert InvalidUserStateMetadataHash();
        }

        if (bytes(_gameStateMetadataHash).length != 46) {
            revert InvalidGameStateMetadataHash();
        }

        if (stateMetadataHashExists[_stateMetadataHash]) {
            revert StateMetadataHashAlreadyExists();
        }

        if (gameStateMetadataHashExists[_gameStateMetadataHash]) {
            revert GameStateMetadataHashAlreadyExists();
        }
    }

    function _validationGameStateMetadataHash(uint256 _userID, uint256 _gameID)
        internal
        view
    {
        if (bytes(userState[_userID].gameMetadataHash[_gameID]).length == 0) {
            revert GameIDDoesNotExist();
        }
    }

    function _validationUserID(uint256 _userID) internal view {
        if (_userID == 0) {
            revert UserIDCannotBeZero();
        }

        if (bytes(userState[_userID].email).length == 0) {
            revert UserIDDoesNotExist();
        }
    }

    function _validationWalletAddresses(uint256 _userID, address _walletAddress)
        internal
        view
    {
        _validationUserID(_userID);

        if (userWalletAddressExists[_walletAddress]) {
            revert AddressAlreadyExists();
        }
        if (_walletAddress == address(0)) {
            revert CannotBeZeroAddress();
        }

        if (_validationContractAddress(_walletAddress) == true) {
            revert CannotBeContractAddress();
        }
    }

    function _validationStateMetadataHash(
        uint256 _userID,
        string memory _stateMetadataHash
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_stateMetadataHash).length != 46) {
            revert InvalidUserStateMetadataHash();
        }

        if (stateMetadataHashExists[_stateMetadataHash]) {
            revert StateMetadataHashAlreadyExists();
        }
    }

    function _validationGameStateMetadataHash(
        uint256 _userID,
        string memory _gameStateMetadataHash
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_gameStateMetadataHash).length != 46) {
            revert InvalidGameStateMetadataHash();
        }

        if (gameStateMetadataHashExists[_gameStateMetadataHash]) {
            revert GameStateMetadataHashAlreadyExists();
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

    /**
     * @dev updateBaseURI is used to update baseURI.
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _baseURI - new baseURI
     *
     * Emits a {UpdatedBaseURI} event.
     */

    function updateBaseURI(string memory _baseURI) external nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        baseURI = _baseURI;

        emit UpdatedBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev addUser is used to just add new users.
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userID - new user's ID.
     * @param _userData - new user's data in the form of a tuple.
     * @param _signature - signature created with the manager role private key for user's data.
     *
     * Emits a {AddedNewUser} event.
     */

    function addUser(
        uint256 _userID,
        UserEncryption calldata _userData,
        bytes calldata _signature
    ) external nonReentrant returns (uint256 _count) {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (
            verifyOwnerSignature(
                keccak256(abi.encode(_userData)),
                _signature
            ) != true
        ) {
            revert InvalidSignature();
        }

        _validationUser(
            _userID,
            _userData.walletAddresses,
            _userData.stateMetadataHash,
            _userData.gameStateMetadataHash
        );

        userCount++;
        userWalletAddressExists[_userData.walletAddresses] = true;
        gameStateMetadataHashExists[_userData.gameStateMetadataHash] = true;
        stateMetadataHashExists[_userData.stateMetadataHash] = true;

        userState[_userID].email = _userData.email;
        userState[_userID].walletAddresses.push(_userData.walletAddresses);
        userState[_userID].stateMetadataHash.push(_userData.stateMetadataHash);
        userState[_userID].gameIDs.push(_userData.gameIDs);
        userState[_userID].gameMetadataHash[_userData.gameIDs] = _userData
            .gameStateMetadataHash;

        emit AddedNewUser(
            _userID,
            _userData.email,
            _userData.walletAddresses,
            _userData.stateMetadataHash,
            _userData.gameStateMetadataHash,
            _userData.gameIDs
        );
        return _userID;
    }

    /**
     * @dev getUserStateMetadataHashByUserID is used to get user state metadata hash info of a user by their userID.
     *
     * Requirement:
     * - This function can be called by anyone.
     *
     * @param _userID - existing user's ID.
     */

    function getUserStateMetadataHashByUserID(uint256 _userID)
        external
        view
        returns (string[] memory)
    {
        _validationUserID(_userID);
        return userState[_userID].stateMetadataHash;
    }

    /**
     * @dev getGameStateMetadataHashByUserID is used to get game state metadata hash info of a user by their userID.
     *
     * Requirement:
     * - This function can be called by anyone.
     *
     * @param _userID - existing user's ID.
     * @param _gameID - existing game's ID against the existing user's ID.
     */

    function getGameStateMetadataHashByUserID(uint256 _userID, uint256 _gameID)
        external
        view
        returns (string memory)
    {
        _validationUserID(_userID);
        _validationGameStateMetadataHash(_userID, _gameID);

        return userState[_userID].gameMetadataHash[_gameID];
    }

    /**
     * @dev getGameIDsByUserID is used to get gameIDs info of a user by their userID.
     *
     * Requirement:
     * - This function can be called by anyone.
     *
     * @param _userID - existing user's ID.
     */

    function getGameIDsByUserID(uint256 _userID)
        external
        view
        returns (uint256[] memory)
    {
        _validationUserID(_userID);
        return userState[_userID].gameIDs;
    }

    /**
     * @dev getWalletAddressesByUserID is used to get walletAddresses info of a user by their userID.
     *
     * Requirement:
     * - This function can be called by anyone.
     *
     * @param _userID - existing user's ID.
     */

    function getWalletAddressesByUserID(uint256 _userID)
        external
        view
        returns (address[] memory)
    {
        _validationUserID(_userID);
        return userState[_userID].walletAddresses;
    }

    /**
     * @dev getUserInfoByUserID is used to get all info of a user by their userID.
     *
     * Requirement:
     * - This function can be called by anyone.
     *
     * @param _userID - existing user's ID.
     */

    function getUserInfoByUserID(uint256 _userID)
        external
        view
        returns (FetchUsers[] memory)
    {
        _validationUserID(_userID);

        FetchUsers[] memory userDetails = new FetchUsers[](1);

        for (uint256 i = 1; i <= 1; i++) {
            userDetails[i - 1].email = userState[_userID].email;
            userDetails[i - 1].walletAddresses = userState[_userID]
                .walletAddresses;
            userDetails[i - 1].stateMetadataHash = userState[_userID]
                .stateMetadataHash;
            userDetails[i - 1].gameStateMetadataHash = userState[_userID]
                .gameMetadataHash[i];
            userDetails[i - 1].gameIDs = userState[_userID].gameIDs;
        }
        return userDetails;
    }

    /**
     * @dev getAllUsers is used to get info of all exiting user.
     *
     * Requirement:
     * - This function can be called by anyone.
     *
     */

    function getAllUsers() external view returns (FetchUsers[] memory) {
        FetchUsers[] memory userDetails = new FetchUsers[](userCount);

        for (uint256 i = 1; i <= userCount; i++) {
            userDetails[i - 1].email = userState[i].email;
            userDetails[i - 1].walletAddresses = userState[i].walletAddresses;
            userDetails[i - 1].stateMetadataHash = userState[i]
                .stateMetadataHash;
            userDetails[i - 1].gameStateMetadataHash = userState[i]
                .gameMetadataHash[i];
            userDetails[i - 1].gameIDs = userState[i].gameIDs;
        }
        return userDetails;
    }

    /**
     * @dev updateWalletAddress is used to update walletAddress of an existing user againt their userID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userID - existing user's ID.
     * @param _walletAddress - new wallet-address which you want to update.
     * @param _signature - signature created with the manager role private key for user's new wallet-address.
     *
     * Emits a {UpdatedWalletAddress} event.
     */

    function updateWalletAddress(
        uint256 _userID,
        address _walletAddress,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (
            verifyOwnerSignature(
                keccak256(abi.encode(_walletAddress)),
                _signature
            ) != true
        ) {
            revert InvalidSignature();
        }

        _validationWalletAddresses(_userID, _walletAddress);

        userState[_userID].walletAddresses.push(_walletAddress);
        userWalletAddressExists[_walletAddress] = true;

        emit UpdatedWalletAddress(_userID, _walletAddress);
    }

    /**
     * @dev updateStateMetadataHash is used to update state metadata hash of an existing user againt their userID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userID - existing user's ID.
     * @param _stateMetadataHash - new state metadata hash which you want to update.
     * @param _signature - signature created with the manager role private key for user's new state metadata hash.
     *
     * Emits a {UpdatedStateMetadataHash} event.
     */

    function updateStateMetadataHash(
        uint256 _userID,
        string memory _stateMetadataHash,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (
            verifyOwnerSignature(
                keccak256(abi.encode(_stateMetadataHash)),
                _signature
            ) != true
        ) {
            revert InvalidSignature();
        }

        _validationStateMetadataHash(_userID, _stateMetadataHash);

        stateMetadataHashExists[_stateMetadataHash] = true;

        userState[_userID].stateMetadataHash.push(_stateMetadataHash);

        emit UpdatedStateMetadataHash(_userID, _stateMetadataHash);
    }

    /**
     * @dev updateGameStateMetadataHash is used to update game-state metadata hash of an existing user againt their userID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userID - existing user's ID.
     * @param _userData -  tuple which contains new game-state metadata hash and the gameID aginst which you want to update that hash.
     * @param _signature - signature created with the manager role private key for user's new game-state metadata hash.
     *
     * Emits a {UpdatedGameStateMetadataHash} event.
     */

    function updateGameStateMetadataHash(
        uint256 _userID,
        UpdateGameStateMetadataHashEncryption calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (
            verifyOwnerSignature(
                keccak256(abi.encode(_userData)),
                _signature
            ) != true
        ) {
            revert InvalidSignature();
        }

        _validationGameStateMetadataHash(
            _userID,
            _userData.gameStateMetadataHash
        );

        gameStateMetadataHashExists[_userData.gameStateMetadataHash] = true;

        if (
            bytes(userState[_userID].gameMetadataHash[_userData.gameIDs])
                .length == 0
        ) {
            userState[_userID].gameIDs.push(_userData.gameIDs);
            userState[_userID].gameMetadataHash[_userData.gameIDs] = _userData
                .gameStateMetadataHash;
        } else {
            userState[_userID].gameMetadataHash[_userData.gameIDs] = _userData
                .gameStateMetadataHash;
        }

        emit UpdatedGameStateMetadataHash(
            _userID,
            _userData.gameIDs,
            _userData.gameStateMetadataHash
        );
    }

    /**
     * @dev updateAllStates is used to update all states of the existing user against their userID.
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userID - existing user's ID.
     * @param _userData - update user's data in the form of a tuple.
     * @param _signature - signature created with the manager role private key for update user's data.
     *
     * Emits a {UpdatedAllUserStates} event.
     */

    function updateAllStates(
        uint256 _userID,
        UpdateAllStatesEncryption calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (
            verifyOwnerSignature(
                keccak256(abi.encode(_userData)),
                _signature
            ) != true
        ) {
            revert InvalidSignature();
        }

        _validationWalletAddresses(_userID, _userData.walletAddresses);
        _validationStateMetadataHash(_userID, _userData.stateMetadataHash);
        _validationGameStateMetadataHash(
            _userID,
            _userData.gameStateMetadataHash
        );

        userState[_userID].walletAddresses.push(_userData.walletAddresses);
        userWalletAddressExists[_userData.walletAddresses] = true;
        gameStateMetadataHashExists[_userData.gameStateMetadataHash] = true;
        stateMetadataHashExists[_userData.stateMetadataHash] = true;

        userState[_userID].stateMetadataHash.push(_userData.stateMetadataHash);

        if (
            bytes(userState[_userID].gameMetadataHash[_userData.gameIDs])
                .length == 0
        ) {
            userState[_userID].gameIDs.push(_userData.gameIDs);
            userState[_userID].gameMetadataHash[_userData.gameIDs] = _userData
                .gameStateMetadataHash;
        } else {
            userState[_userID].gameMetadataHash[_userData.gameIDs] = _userData
                .gameStateMetadataHash;
        }

        emit UpdatedAllUserStates(
            _userID,
            _userData.walletAddresses,
            _userData.stateMetadataHash,
            _userData.gameStateMetadataHash,
            _userData.gameIDs
        );
    }

    /**
     * @dev addWhitelistAdmin is used to add whitelist admin account address.
     *
     * Requirement:
     * - This function can only be called by owner of the contract
     *
     * @param whitelistAddress - Admin account address to be whitelisted
     *
     * Emits a {AddedWhitelistAdmin} event.
     */

    function addWhitelistAdmin(
        address whitelistAddress,
        AdminRoles allowPermission
    ) external onlyOwner {
        if (adminWhitelistedAddresses[whitelistAddress] != AdminRoles.NONE) {
            revert AlreadyWhitelisted();
        }
        adminWhitelistedAddresses[whitelistAddress] = allowPermission;

        emit AddedWhitelistAdmin(whitelistAddress, msg.sender);
    }

    /**
     * @dev removeWhitelistAdmin is used to remove whitelist admin account address.
     *
     * Requirement:
     * - This function can only be called by owner of the contract
     *
     * @param whitelistAddress - Admin account address to be removed
     *
     * Emits a {RemovedWhitelistAdmin} event.
     */

    function removeWhitelistAdmin(address whitelistAddress) external onlyOwner {
        if (adminWhitelistedAddresses[whitelistAddress] == AdminRoles.NONE) {
            revert NotWhitelistedAddress();
        }

        adminWhitelistedAddresses[whitelistAddress] = AdminRoles.NONE;

        emit RemovedWhitelistAdmin(whitelistAddress, msg.sender);
    }

    function verifyOwnerSignature(bytes32 hash, bytes memory signature)
        internal
        view
        returns (bool)
    {
        return hash.toEthSignedMessageHash().recover(signature) == owner();
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner {}
}
