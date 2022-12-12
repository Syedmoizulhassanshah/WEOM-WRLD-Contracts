// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./ObjectContractCore.sol";

contract ObjectContractV1 is ObjectContractCore {
    /**
     * @dev updateContractPauseStatus is used to pause/unpause contract status.
     * Requirement:
     * - This function can only called by manager role
     *
     * @param status - bool true/false
     */

    function updateContractPauseStatus(bool status) external returns (bool) {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (status) {
            _pause();
        } else {
            _unpause();
        }

        return status;
    }

    /**
     * @dev updateMintingStatus is used to update mintng status.
     * Requirement:
     * - This function can only called by manager role
     *
     * @param _status - status bool
     *
     * Emits a {UpdatedObjectMintStatus} event.
     */

    function updateMintingStatus(bool _status) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        isMintingEnable = _status;

        emit UpdatedObjectMintStatus(_status, msg.sender);
    }

    /**
     * @dev updateBaseURI is used to update BaseURI.
     * Requirement:
     * - This function can only called by manager role
     *
     * @param _baseURI - New baseURI
     *
     * Emits a {UpdatedBaseURI} event.
     */

    function updateBaseURI(string memory _baseURI) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (bytes(_baseURI).length == 0) {
            revert InvalidParameters("BaseURI zero");
        }

        baseURI = _baseURI;

        emit UpdatedBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev addWhitelistAdmin is used to add whitelist admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param whitelistAddress - Admin to be whitelisted
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
     * @dev removeWhitelistAdmin is used to remove whitelist admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param whitelistAddress - Accounts to be removed
     *
     * Emits a {RemovedWhitelistAdmin} event.
     */

    function removeWhitelistAdmin(address whitelistAddress) external onlyOwner {
        if (adminWhitelistedAddresses[whitelistAddress] == AdminRoles.NONE) {
            revert NotExists();
        }

        adminWhitelistedAddresses[whitelistAddress] = AdminRoles.NONE;

        emit RemovedWhitelistAdmin(whitelistAddress, msg.sender);
    }

    /**
     * @dev mintObject is used to create a new object only by whitelist admin.
     * Requirement:
     * - This function can only called by whitelisted admin
     *
     * @param objectId - object Id
     * @param to - address to mint the object
     * @param name - name of the object
     * @param objectType - object type
     * @param metadataHash - object metadata hash
     *
     * Emits a {ObjectMinted} event.
     */

    function mintObject(
        address to,
        uint256 objectId,
        string memory name,
        string memory objectType,
        string memory metadataHash
    ) external {
        if (!isMintingEnable) {
            revert MintingStatusPaused();
        }
        _validationObjectsParameters(to, name, objectType, metadataHash);
        _isWhitelistedAdmin(AdminRoles.MINTER);

        _storeObjectsInformation(objectId, name, objectType, metadataHash);
        _safeMint(to, objectId);

        emit ObjectMinted(objectId, metadataHash, to, msg.sender);
    }

    /**
     * @dev mintBulkObjects is used to create a new object only by whitelist admin.
     * Requirement:
     * - This function can only called by whitelisted admin
     *
     *   @param objectInfo - bulk mint land in the form of a tuple.
     */

    function mintBulkObjects(bulkMintObjects[] memory objectInfo) external {
        if (!isMintingEnable) {
            revert MintingStatusPaused();
        }
        _isWhitelistedAdmin(AdminRoles.MINTER);

        for (uint256 i = 0; i < objectInfo.length; i++) {
            _validationObjectsParameters(
                objectInfo[i].to,
                objectInfo[i].name,
                objectInfo[i].objectType,
                objectInfo[i].metadataHash
            );
            _storeObjectsInformation(
                objectInfo[i].objectId,
                objectInfo[i].name,
                objectInfo[i].objectType,
                objectInfo[i].metadataHash
            );

            _safeMint(objectInfo[i].to, objectInfo[i].objectId);
        }
    }

    /**
     * @dev getObjectByID is used to get object info by id.
     * Requirement:
     * - This function can called by anyone
     *
     * @param objectId - objectId to get object info
     *
     */

    function getObjectByID(uint256 objectId)
        external
        view
        returns (Objects memory)
    {
        if (!_exists(objectId)) {
            revert NotExists();
        }
        return object[objectId];
    }

    /**
     * @dev getObjectByAddress is used to get object info by wallet address.
     * Requirement:
     * - This function can called by anyone
     *
     * @param userAddress - address to get object info
     *
     */

    function getObjectsByAddress(address userAddress)
        external
        view
        returns (ReturnObjectsInfo[] memory)
    {
        ReturnObjectsInfo[] memory objectInfo = new ReturnObjectsInfo[](
            balanceOf(userAddress)
        );

        if (balanceOf(userAddress) == 0) revert NotExists();

        uint256 objectIndex;
        for (uint256 i = 0; i < balanceOf(userAddress); i++) {
            uint256 objectId = tokenOfOwnerByIndex(userAddress, i);
            objectInfo[objectIndex].objectId = objectId;
            objectInfo[objectIndex].name = object[objectId].name;
            objectInfo[objectIndex].objectType = object[objectId].objectType;
            objectInfo[objectIndex].metadataHash = object[objectId]
                .metadataHash;
            objectIndex++;
        }

        return objectInfo;
    }

    /**
     * @dev tokenURI is used to get tokenURI link.
     *
     * @param objectId - ID of object
     */

    function tokenURI(uint256 objectId)
        public
        view
        override(ERC721Upgradeable)
        returns (string memory)
    {
        if (!_exists(objectId)) {
            revert NotExists();
        }
        return string(abi.encodePacked(baseURI, object[objectId].metadataHash));
    }
}
