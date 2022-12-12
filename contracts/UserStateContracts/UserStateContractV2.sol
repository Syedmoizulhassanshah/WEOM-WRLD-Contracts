// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "./UserStateCore.sol";

contract UserStateContractV1 is UserStateCore {
    using ECDSAUpgradeable for bytes32;

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
            revert AddressAlreadyExists();
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
            revert AddressNotExists();
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

        userIDs[userCount] = _userData.userID;

        userWalletAddressExists[_userData.walletAddress] = true;

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
            userDetails[i - 1].email = userState[userIDs[i]].email;
            userDetails[i - 1].walletAddresses = userState[userIDs[i]]
                .walletAddresses;
            userDetails[i - 1].stateMetadataHash = userState[userIDs[i]]
                .stateMetadataHash;
            userDetails[i - 1].gameMetadataHash = userState[userIDs[i]]
                .gameMetadataHash;
            userDetails[i - 1].gameIDs = userState[userIDs[i]].gameIDs;
        }
        return userDetails;
    }
}
