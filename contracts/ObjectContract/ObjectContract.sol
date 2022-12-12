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

contract ObjectContract is
    Initializable,
    ERC721Upgradeable,
    CustomErrors,
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
        string twoDimensional;
        string threeDimensional;
        string metadataHash;
    }

    enum AdminRoles {
        NONE,
        MINTER,
        MANAGER
    }

    mapping(uint256 => Objects) public object;
    mapping(address => AdminRoles) public adminWhitelistedAddresses;

    event UpdatedBaseURI(string baseURI, address addedBy);
    event ObjectMinted(uint256 objectId, address mintedBy, string metadataHash);
    event AddedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event RemovedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event MintingStatusUpdated(bool status, address updatedBy);
    event ConstructorInitialized(string baseURI, address updatedBy);

    function initialize() public initializer {
        __ERC721_init("ObjectContract", "W-Objects");
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        baseURI = "https://gateway.pinata.cloud/ipfs/";

        emit ConstructorInitialized(baseURI, msg.sender);
    }

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
            revert NotWhitelistedAddress();
        }
    }

    function _verifyMetadataHash(string memory metadataHash) internal pure {
        if (bytes(metadataHash).length != 46) {
            revert InvalidMetadataHash();
        }
    }

    /**
     * @dev _storeObjectsInformation is used to store the object information.
     * Requirement:
     * - This is an internal function
     */

    function _storeObjectsInformation(
        uint256 objectId,
        string memory name,
        string memory objectType,
        string memory twoDimensional,
        string memory threeDimensional,
        string memory metadataHash
    ) internal {
        object[objectId].metadataHash = metadataHash;
        object[objectId].name = name;
        object[objectId].objectType = objectType;
        object[objectId].twoDimensional = twoDimensional;
        object[objectId].threeDimensional = threeDimensional;
    }

    /**
     * @dev updateContractPauseStatus is used to pause/unpause contract status.
     * Requirement:
     * - This function can only called by manager role
     *
     * @param status - bool true/false
     */

    function updateContractPauseStatus(bool status) public returns (bool) {
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
     * Emits a {MintingStatusUpdated} event.
     */

    function updateMintingStatus(bool _status) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        isMintingEnable = _status;

        emit MintingStatusUpdated(_status, msg.sender);
    }

    /**
     * @dev updateBaseURI is used to set BaseURI.
     * Requirement:
     * - This function can only called by manager role
     *
     * @param _baseURI - New baseURI
     *
     * Emits a {UpdatedBaseURI} event.
     */

    function updateBaseURI(string memory _baseURI) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

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
            revert AlreadyWhitelisted();
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
            revert NotWhitelistedAddress();
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
     * @param twoDimensional - twoDimensional object
     * @param threeDimensional - threeDimensional object
     * @param metadataHash - object metadata hash
     *
     * Emits a {ObjectMinted} event.
     */

    function mintObject(
        address to,
        uint256 objectId,
        string memory name,
        string memory objectType,
        string memory twoDimensional,
        string memory threeDimensional,
        string memory metadataHash
    ) public {
        _isWhitelistedAdmin(AdminRoles.MINTER);
        _verifyMetadataHash(metadataHash);

        if (!isMintingEnable) {
            revert MintingStatusPaused();
        }

        _safeMint(to, objectId);

        _storeObjectsInformation(
            objectId,
            name,
            objectType,
            twoDimensional,
            threeDimensional,
            metadataHash
        );

        emit ObjectMinted(objectId, to, metadataHash);
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
        public
        view
        returns (Objects memory)
    {
        if (!_exists(objectId)) {
            revert IdNotExist();
        }
        return object[objectId];
    }

    /**
     * @dev getObjectByAddress is used to get object info by wallet address.
     * Requirement:
     * - This function can called by anyone
     *
     * @param _address - address to get object info
     *
     */

    function getObjectByAddress(address _address)
        public
        view
        returns (Objects[] memory)
    {
        Objects[] memory objectInfo = new Objects[](balanceOf(_address));

        if (balanceOf(_address) == 0) revert AddressNotExist();

        uint256 objectIndex;
        for (uint256 i = 0; i < balanceOf(_address); i++) {
            console.log(balanceOf(_address));
            uint256 tokenId = tokenOfOwnerByIndex(_address, i);
            console.log(tokenId);
            objectInfo[objectIndex].name = object[tokenId].name;
            objectInfo[objectIndex].objectType = object[tokenId].objectType;
            objectInfo[objectIndex].twoDimensional = object[tokenId]
                .twoDimensional;
            objectInfo[objectIndex].threeDimensional = object[tokenId]
                .threeDimensional;
            objectInfo[objectIndex].metadataHash = object[tokenId].metadataHash;
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
            revert IdNotExist();
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
