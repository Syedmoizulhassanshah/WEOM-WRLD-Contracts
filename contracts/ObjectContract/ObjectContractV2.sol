// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../utils/CustomErrors.sol";

contract ObjectContractV2 is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    string public baseURI;
    bool public isPublicSaleActive;
    bool public isMintingEnable;

    struct Objects {
        string name;
        string objectType;
        string metadataHash;
    }

    struct ReturnObjectsInfo {
        uint256 objectId;
        string name;
        string objectType;
        string metadataHash;
    }

    enum AdminRoles {
        NONE,
        MINTER,
        MANAGER
    }

    mapping(uint => Objects) public object;
    mapping(address => AdminRoles) public adminWhitelistedAddresses;

    event UpdatedBaseURI(string baseURI, address updatedBy);
    event ObjectMinted(
        uint objectId,
        string metadataHash,
        address mintedOn,
        address mintedBy
    );
    event AddedWhitelistAdmin(address whitelistedAddress, address addedBy);
    event RemovedWhitelistAdmin(address whitelistedAddress, address removedBy);
    event UpdatedObjectMintStatus(bool status, address updatedBy);
    event ConstructorInitialized(string baseURI, address initializedBy);

    function initialize() public initializer {
        __ERC721_init("ObjectContract", "W-Objects");
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        baseURI = "https://gateway.pinata.cloud/ipfs/";

        emit ConstructorInitialized(baseURI, msg.sender);
    }

    function _validationObjectsParameters(
        address to,
        string memory name,
        string memory objectType,
        string memory metadataHash
    ) internal view {
        if (
            bytes(name).length == 0 ||
            bytes(objectType).length == 0 ||
            bytes(metadataHash).length == 0
        ) {
            revert Invalid("Input cannot be empty");
        }
        if (_validationContractAddress(to)) {
            revert Invalid("Address cannot be contract address");
        }
        if (bytes(metadataHash).length != 46) {
            revert Invalid("Object Metadata Hash");
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

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
            revert Invalid("Not whitelist address");
        }
    }

    function _storeObjectsInformation(
        uint objectId,
        string memory name,
        string memory objectType,
        string memory metadataHash
    ) internal {
        object[objectId].metadataHash = metadataHash;
        object[objectId].name = name;
        object[objectId].objectType = objectType;
    }

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
            revert Invalid("BaseURI cannot be zero");
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
            revert AlreadyExists("Whitelisted address");
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
            revert Invalid("Not whitelist address");
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
            revert NotExists("ObjectId");
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

        if (balanceOf(userAddress) == 0) revert NotExists("UserAddress");

        uint objectIndex;
        for (uint i = 0; i < balanceOf(userAddress); i++) {
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

    function tokenURI(uint objectId)
        public
        view
        override(ERC721Upgradeable)
        returns (string memory)
    {
        if (!_exists(objectId)) {
            revert NotExists("ObjctId");
        }
        return string(abi.encodePacked(baseURI, object[objectId].metadataHash));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 objectId
    )
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, objectId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
