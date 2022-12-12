// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../utils/CustomErrors.sol";
import "./UserStateCore.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

contract UserStateContractV1 is UserStateCore {
    using ECDSAUpgradeable for bytes32;

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
            revert Invalid("Not whitelist address");
        }
    }

    function _validationUser(
        uint256 _userID,
        address _walletAddress,
        string memory _stateMetadataHash
    ) internal view {
        if (_userID == 0) {
            revert Invalid("UserId cannot be zero");
        }

        if (userWalletAddressExists[_walletAddress]) {
            revert AlreadyExists("User Wallet Address");
        }

        if (bytes(userState[_userID].email).length > 0) {
            revert AlreadyExists("Email");
        }

        if (_validationContractAddress(_walletAddress)) {
            revert Invalid("Address cannot be contract address");
        }

        if (bytes(_stateMetadataHash).length != 46) {
            revert Invalid("User state metadata hash");
        }

        if (stateMetadataHashExists[_stateMetadataHash]) {
            revert AlreadyExists("User state metadata hash");
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
            revert NotExists("GameId");
        }
    }

    function _validationUserID(uint256 _userID) internal view {
        if (_userID == 0) {
            revert Invalid("UserId cannot be zero");
        }

        if (bytes(userState[_userID].email).length == 0) {
            revert NotExists("UserId");
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
            revert Invalid("Address cannot be contract address");
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
            revert Invalid("Address cannot be contract address");
        }

        if (stateIndex > userState[_userID].walletAddresses.length) {
            revert Invalid("State index");
        }
    }

    function _validationAddStateMetadataHash(
        uint256 _userID,
        string memory _stateMetadataHash
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_stateMetadataHash).length != 46) {
            revert Invalid("User state metadata hash");
        }

        if (stateMetadataHashExists[_stateMetadataHash]) {
            revert AlreadyExists("User state metadata hash");
        }
    }

    function _validationUpdateStateMetadataHash(
        uint256 _userID,
        string memory _stateMetadataHash,
        uint256 stateIndex
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_stateMetadataHash).length != 46) {
            revert Invalid("User state metadata hash");
        }

        if (stateMetadataHashExists[_stateMetadataHash]) {
            revert AlreadyExists("User state metadata hash");
        }

        if (stateIndex > userState[_userID].stateMetadataHash.length) {
            revert Invalid("State index");
        }
    }

    function _validationAddGameStateMetadataHash(
        uint256 _userID,
        string memory _gameStateMetadataHash
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_gameStateMetadataHash).length != 46) {
            revert Invalid("Game state metadata hash");
        }

        if (gameStateMetadataHashExists[_gameStateMetadataHash]) {
            revert AlreadyExists("Game state metadata hash");
        }
    }

    function _validationUpdateGameStateMetadataHash(
        uint256 _userID,
        string memory _gameStateMetadataHash,
        uint256 stateIndex
    ) internal view {
        _validationUserID(_userID);

        if (bytes(_gameStateMetadataHash).length != 46) {
            revert Invalid("Game state metadata hash");
        }

        if (gameStateMetadataHashExists[_gameStateMetadataHash]) {
            revert AlreadyExists("Game state metadata hash");
        }

        if (stateIndex > userState[_userID].gameMetadataHash.length) {
            revert Invalid("State index");
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
            revert Invalid("Signature");
        }
    }

    function _verifyOwnerSignature(bytes32 hash, bytes memory signature)
        internal
        view
        returns (bool)
    {
        return (hash.toEthSignedMessageHash().recover(signature) == msg.sender);
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
            revert AlreadyExists("Whitelisted address");
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
            revert Invalid("Not whitelist address");
        }

        adminWhitelistedAddresses[whitelistAddress] = AdminRoles.NONE;

        emit RemovedWhitelistAdmin(whitelistAddress, msg.sender);
    }

    /**
     * @dev addUser is used to just add new users.
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userData - new user's data in the form of a tuple.
     * @param _signature - signature created with the manager role private key for user's data.
     *
     * Emits a {AddedNewUser} event.
     */

    function addUser(
        UserVerification calldata _userData,
        bytes calldata _signature
    ) external nonReentrant returns (uint256 _count) {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _validationSignature(keccak256(abi.encode(_userData)), _signature);
        _validationUser(
            _userData.userID,
            _userData.walletAddress,
            _userData.stateMetadataHash
        );

        userCount++;
        userWalletAddressExists[_userData.walletAddress] = true;
        stateMetadataHashExists[_userData.stateMetadataHash] = true;

        userState[_userData.userID].email = _userData.email;
        userState[_userData.userID].walletAddresses.push(
            _userData.walletAddress
        );
        userState[_userData.userID].stateMetadataHash.push(
            _userData.stateMetadataHash
        );

        emit AddedNewUser(
            _userData.userID,
            _userData.walletAddress,
            _userData.email,
            _userData.stateMetadataHash,
            msg.sender
        );

        return _userData.userID;
    }

    /**
     * @dev addUserNewWalletAddress is used to add new walletAddress of an existing user againt their userID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userData - existing user's ID.
     * @param _signature - signature created with the manager role private key for user's new wallet-address.
     *
     * Emits a {AddedWalletAddress} event.
     */

    function addUserNewWalletAddress(
        AddUserWalletVerification calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _validationSignature(keccak256(abi.encode(_userData)), _signature);
        _validationAddWalletAddress(_userData.userID, _userData.walletAddress);

        userState[_userData.userID].walletAddresses.push(
            _userData.walletAddress
        );
        userWalletAddressExists[_userData.walletAddress] = true;

        emit AddedWalletAddress(
            _userData.userID,
            _userData.walletAddress,
            msg.sender
        );
    }

    /**
     * @dev updateWalletAddress is used to update walletAddress of an existing user againt their userID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userData - new wallet-address which you want to update.
     * @param _signature - signature created with the manager role private key for user's new wallet-address.
     *
     * Emits a {UpdatedWalletAddress} event.
     */

    function updateWalletAddress(
        UpdateUserWalletVerification calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _validationSignature(keccak256(abi.encode(_userData)), _signature);
        _validationUpdateWalletAddress(
            _userData.userID,
            _userData.walletAddress,
            _userData.stateIndex
        );

        userState[_userData.userID].walletAddresses[
            _userData.stateIndex
        ] = _userData.walletAddress;
        userWalletAddressExists[_userData.walletAddress] = true;

        emit UpdatedWalletAddress(
            _userData.userID,
            _userData.walletAddress,
            msg.sender
        );
    }

    /**
     * @dev addStateMetadataHash is used to add new state metadata hash of an existing user against their userID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userData - new state metadata hash which you want to update.
     * @param _signature - signature created with the manager role private key for user's new state metadata hash.
     *
     * Emits a {AddedStateMetadataHash} event.
     */

    function addStateMetadataHash(
        AddUserMetadataVerification calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _validationSignature(keccak256(abi.encode(_userData)), _signature);
        _validationAddStateMetadataHash(
            _userData.userID,
            _userData.stateMetadataHash
        );

        stateMetadataHashExists[_userData.stateMetadataHash] = true;
        userState[_userData.userID].stateMetadataHash.push(
            _userData.stateMetadataHash
        );

        emit AddedStateMetadataHash(
            _userData.userID,
            _userData.stateMetadataHash,
            msg.sender
        );
    }

    /**
     * @dev updateStateMetadataHash is used to update state metadata hash of an existing user againt their userID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userData - new state metadata hash which you want to update.
     * @param _signature - signature created with the manager role private key for user's new state metadata hash.
     *
     * Emits a {UpdatedStateMetadataHash} event.
     */

    function updateStateMetadataHash(
        UpdateUserMetadataVerification calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _validationSignature(keccak256(abi.encode(_userData)), _signature);
        _validationUpdateStateMetadataHash(
            _userData.userID,
            _userData.stateMetadataHash,
            _userData.stateIndex
        );
        stateMetadataHashExists[_userData.stateMetadataHash] = true;
        userState[_userData.userID].stateMetadataHash[
            _userData.stateIndex
        ] = _userData.stateMetadataHash;

        emit UpdatedStateMetadataHash(
            _userData.userID,
            _userData.stateMetadataHash,
            msg.sender
        );
    }

    /**
     * @dev addNewGameState is used to update game-state metadata hash of an existing user against their userID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userData -  tuple which contains new game-state metadata hash and the gameID aginst which you want to update that hash.
     * @param _signature - signature created with the manager role private key for user's new game-state metadata hash.
     *
     * Emits a {AddedGameStateMetadataHash} event.
     */

    function addNewGameState(
        AddGameStateVerification calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _validationSignature(keccak256(abi.encode(_userData)), _signature);
        _validationAddGameStateMetadataHash(
            _userData.userID,
            _userData.gameStateMetadataHash
        );

        gameStateMetadataHashExists[_userData.gameStateMetadataHash] = true;

        userState[_userData.userID].gameIDs.push(_userData.gameID);
        userState[_userData.userID].gameMetadataHash.push(
            _userData.gameStateMetadataHash
        );

        emit AddedGameStateMetadataHash(
            _userData.userID,
            _userData.gameID,
            _userData.gameStateMetadataHash,
            msg.sender
        );
    }

    /**
     * @dev updateGameStateMetadataHash is used to update game-state metadata hash of an existing user againt their userID and gameID.
     *
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userData -  tuple which contains new game-state metadata hash and the gameID aginst which you want to update that hash.
     * @param _signature - signature created with the manager role private key for user's new game-state metadata hash.
     *
     * Emits a {UpdatedGameStateMetadataHash} event.
     */

    function updateGameStateMetadataHash(
        UpdateGameStateVerification calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _validationSignature(keccak256(abi.encode(_userData)), _signature);
        _validationUpdateGameStateMetadataHash(
            _userData.userID,
            _userData.gameStateMetadataHash,
            _userData.gameStateIndex
        );

        gameStateMetadataHashExists[_userData.gameStateMetadataHash] = true;
        userState[_userData.userID].gameMetadataHash[
            _userData.gameStateIndex
        ] = _userData.gameStateMetadataHash;

        emit UpdatedGameStateMetadataHash(
            _userData.userID,
            userState[_userData.userID].gameIDs[_userData.gameStateIndex],
            _userData.gameStateMetadataHash,
            msg.sender
        );
    }

    /**
     * @dev updateAllStates is used to update all states of the existing user against their userID.
     * Requirement:
     * - This function can only be called by manger role.
     *
     * @param _userData - update user's data in the form of a tuple.
     * @param _signature - signature created with the manager role private key for update user's data.
     *
     * Emits a {UpdatedAllUserStates} event.
     */

    function updateAllStates(
        UpdateAllStatesVerification calldata _userData,
        bytes calldata _signature
    ) public nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _validationSignature(keccak256(abi.encode(_userData)), _signature);
        _validationUpdateWalletAddress(
            _userData.userID,
            _userData.walletAddress,
            _userData.stateIndex
        );
        _validationUpdateStateMetadataHash(
            _userData.userID,
            _userData.stateMetadataHash,
            _userData.stateIndex
        );
        _validationUpdateGameStateMetadataHash(
            _userData.userID,
            _userData.gameStateMetadataHash,
            _userData.gameStateIndex
        );

        userState[_userData.userID].walletAddresses[
            _userData.walletIndex
        ] = _userData.walletAddress;
        userWalletAddressExists[_userData.walletAddress] = true;
        gameStateMetadataHashExists[_userData.gameStateMetadataHash] = true;
        stateMetadataHashExists[_userData.stateMetadataHash] = true;

        userState[_userData.userID].stateMetadataHash[
            _userData.stateIndex
        ] = _userData.stateMetadataHash;

        userState[_userData.userID].gameMetadataHash[
            _userData.gameStateIndex
        ] = _userData.gameStateMetadataHash;

        emit UpdatedAllUserStates(
            _userData.userID,
            _userData.walletAddress,
            _userData.stateMetadataHash,
            _userData.gameStateMetadataHash,
            msg.sender
        );
    }

    /**
     * @dev getUserStateMetadataHashByUserID is used to get User state metadata hash info of a user by their userID.
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
     * @dev getGameStateMetadataHashByUserID is used to get Game state metadata hash info of a user by their userID.
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
        returns (string memory gameStateHash)
    {
        _validationUserID(_userID);

        uint256 totalGameIDs = userState[_userID].gameIDs.length;

        for (uint256 i = 0; i < totalGameIDs; i++) {
            if (userState[_userID].gameIDs[i] == _gameID) {
                _validationGameStateMetadataHash(_userID, i);

                return userState[_userID].gameMetadataHash[i];
            }
        }
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
     * @dev getStatesByUserID is used to get all info of a user by their userID.
     *
     * Requirement:
     * - This function can be called by anyone.
     *
     * @param _userID - existing user's ID.
     */

    function getStatesByUserID(uint256 _userID)
        external
        view
        returns (User memory)
    {
        _validationUserID(_userID);

        User memory userDetails;

        userDetails.email = userState[_userID].email;
        userDetails.walletAddresses = userState[_userID].walletAddresses;
        userDetails.stateMetadataHash = userState[_userID].stateMetadataHash;
        userDetails.gameMetadataHash = userState[_userID].gameMetadataHash;
        userDetails.gameIDs = userState[_userID].gameIDs;

        return userDetails;
    }

    /**
     * @dev getAllUsers is used to get info of all exiting user.
     *
     * Requirement:
     * - This function can be called by anyone.
     *
     */

    function getAllUsers() external view returns (User[] memory) {
        User[] memory userDetails = new User[](userCount);

        for (uint256 i = 1; i <= userCount; i++) {
            userDetails[i - 1].email = userState[i].email;
            userDetails[i - 1].walletAddresses = userState[i].walletAddresses;
            userDetails[i - 1].stateMetadataHash = userState[i]
                .stateMetadataHash;
            userDetails[i - 1].gameMetadataHash = userState[i].gameMetadataHash;
            userDetails[i - 1].gameIDs = userState[i].gameIDs;
        }
        return userDetails;
    }
}
