// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./CustomErrors.sol";

contract LandContract is
    Initializable,
    ERC721Upgradeable,
    CustomErrors,
    ERC721EnumerableUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    enum AdminRoles {
        NONE,
        MINTER,
        MANAGER
    }

    string public baseURI;
    bytes32 public usersWhitelistRootHash;
    uint256 public maxMintingLimit;
    uint256 public whitelistUsersMintingLimit;
    uint256 public platformMintingLimit;
    uint256 public publicMintingLimit;
    uint256 public whitelistUsersMintingCount;
    uint256 public publicUsersMintingCount;
    uint256 public platformMintingCount;
    uint256 public landMintingLimitPerAddress;
    bool public isPublicSaleActive;
    bool public isMintingEnable;

    struct PolygonCoordinates {
        string longitude;
        string latitude;
    }

    struct Land {
        string longitude;
        string latitude;
        PolygonCoordinates[] polygonCoordinates;
    }

    mapping(address => uint256) public landMintedCount;
    mapping(uint => Land) public land;
    mapping(address => AdminRoles) public adminWhitelistedAddresses;

    event BaseURIUpdated(string baseURI, address addedBy);
    event LandMintedByWhitelistUser(uint tokenId, address mintedBy);
    event LandMintedByAdmin(uint tokenId, address mintedBy);
    event LandMintedByPublicUser(uint tokenId, address mintedBy);
    event RootUpdated(bytes32 updatedRoot, address updatedBy);
    event AddedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event RemovedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event UpdatedWhitelistUsersMintingLimit(
        uint256 limit,
        bytes32 whitelistedRoot,
        address updatedBy
    );
    event UpdatedLandMintingLimitPerAddress(
        uint256 limitPerAddress,
        address updatedBy
    );
    event MintingStatusUpdated(bool status, address updatedBy);
    event ConstructorInitialized(
        string baseURI,
        uint maxMintingLimit,
        uint platformMintingLimit,
        uint publicMintingLimit,
        address updatedBy
    );

    function initialize(
        uint _maxMintingLimit,
        uint _landMintingLimitPerAddress,
        uint _platformMintingLimit
    ) public initializer {
        __ERC721_init("LandContract", "W-Land");
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();

        baseURI = "https://dev-services.wrld.xyz/assets/getLandMetadataById/";

        maxMintingLimit = _maxMintingLimit;
        landMintingLimitPerAddress = _landMintingLimitPerAddress;
        platformMintingLimit = _platformMintingLimit;
        publicMintingLimit = maxMintingLimit - platformMintingLimit;

        _verifyPlatformLimit();

        emit ConstructorInitialized(
            baseURI,
            maxMintingLimit,
            platformMintingLimit,
            publicMintingLimit,
            msg.sender
        );
    }

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
            revert NotWhitelistedAddress();
        }
    }

    function _verifyPlatformLimit() internal view {
        if (platformMintingLimit >= maxMintingLimit) {
            revert MaxMintingLimitReached();
        }
    }

    /**
     * @dev _storeLandInformation is used to store the land information.
     * Requirement:
     * - This is an internal function
     */

    function _storeLandInformation(
        uint landId,
        string memory longitude,
        string memory latitude,
        PolygonCoordinates[] memory coordinates
    ) internal {
        land[landId].longitude = longitude;
        land[landId].latitude = latitude;

        for (uint i = 0; i < coordinates.length; ) {
            land[landId].polygonCoordinates.push(
                PolygonCoordinates(
                    coordinates[i].longitude,
                    coordinates[i].latitude
                )
            );
            unchecked {
                i++;
            }
        }
    }

    /**
     * @dev updateContractPauseStatus is used to pause/unpause contract status.
     * Requirement:
     *  - This function can only called manger role
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
     * - This function can only called manger role
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
     * @dev updateLandMintingLimitPerAddress is used to update Nft minting limit per address.
     * Requirement:
     * - This function can only called manger role
     * 
     * @param _landMintingLimitPerAddress - new limit
     * 
     * Emits a {UpdatedLandMintingLimitPerAddress} event.
     */

    function updateLandMintingLimitPerAddress(
        uint256 _landMintingLimitPerAddress
    ) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        landMintingLimitPerAddress = _landMintingLimitPerAddress;

        emit UpdatedLandMintingLimitPerAddress(
            _landMintingLimitPerAddress,
            msg.sender
        );
    }

    /**
     * @dev updateBaseURI is used to set BaseURI.
     * Requirement:
     * - This function can only called manger role
     *
     * @param _baseURI - New baseURI
     *
     * Emits a {BaseURIUpdated} event.
     */

    function updateBaseURI(string memory _baseURI) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        baseURI = _baseURI;

        emit BaseURIUpdated(baseURI, msg.sender);
    }

    /**
     * @dev updatePublicSaleStatus is used to active the public sale.
     * Requirement:
     * - Only Manger role can call this method.
     *
     * @param status - to true/false
     */

    function updatePublicSaleStatus(bool status) public returns (bool) {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (whitelistUsersMintingCount != whitelistUsersMintingLimit) {
            publicMintingLimit +=
                whitelistUsersMintingLimit -
                whitelistUsersMintingCount;
        }

        isPublicSaleActive = status;

        return true;
    }

    /**
     * @dev updateWhitelistUsers is used to update whitelistUsersMintingLimit and whitelistedRoot.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _whitelistUsersMintingLimit - New whitelistUsersMintingLimit
     * @param _whitelistedRoot - New whitelistedRoot
     *
     * Emits a {UpdatedWhitelistUsersMintingLimit} event.
     * Emits a {RootUpdated} event.
     */

    function updateWhitelistUsers(
        uint _whitelistUsersMintingLimit,
        bytes32 _whitelistedRoot
    ) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (_whitelistUsersMintingLimit >= maxMintingLimit) {
            revert MaxMintingLimitReached();
        }
        usersWhitelistRootHash = _whitelistedRoot;

        whitelistUsersMintingLimit =
            _whitelistUsersMintingLimit *
            landMintingLimitPerAddress;

        publicMintingLimit = publicMintingLimit - whitelistUsersMintingLimit;

        emit UpdatedWhitelistUsersMintingLimit(
            whitelistUsersMintingLimit,
            usersWhitelistRootHash,
            msg.sender
        );
        emit RootUpdated(
            usersWhitelistRootHash,
            msg.sender
        )
    }

    function isValid(bytes32[] memory proof, bytes32 leaf)
        public
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, usersWhitelistRootHash, leaf);
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
     * @dev mintLandWhitelistUsers is used to create a new land for white list users.
     * Requirement:
     * - This function can only called by whitelisted users
     *
     * @param landId - landId
     * @param to - address to mint land
     * @param longitude - longitude
     * @param latitude - latitud
     * @param coordinates - polygonCoordinates
     * @param proof - proof of whitelist users
     *
     * Emits a {LandMintedByWhitelistUser} event.
     */

    function mintLandWhitelistUsers(
        address to,
        uint256 landId,
        string memory longitude,
        string memory latitude,
        PolygonCoordinates[] memory coordinates,
        bytes32[] memory proof
    ) public {
        if (_exists(landId)) {
            revert IdAlreadyExist();
        }

        if (isPublicSaleActive) {
            revert PublicSaleActivated();
        }
        if (!isValid(proof, keccak256(abi.encodePacked(msg.sender)))) {
            revert NotWhitelistedAddress();
        }
        if (landMintedCount[msg.sender] >= landMintingLimitPerAddress) {
            revert MintingLimitReached();
        }
        if (whitelistUsersMintingCount >= whitelistUsersMintingLimit) {
            revert UsersMintingLimitReached();
        }
        whitelistUsersMintingCount++;

        landMintedCount[msg.sender]++;

        _storeLandInformation(landId, longitude, latitude, coordinates);

        _safeMint(to, landId);

        emit LandMintedByWhitelistUser(landId, to);
    }

    /**
     * @dev mintLandWhitelistAdmin is used to create a new land only by whitelist admin.
     * Requirement:
     * - This function can only called by whitelisted admin with minter role
     *
     * @param landId - landId
     * @param to - address to mint the land
     * @param longitude - longitude
     * @param latitude - latitud
     * @param coordinates - polygonCoordinates
     *
     * Emits a {LandMintedByAdmin} event.
     */

    function mintLandWhitelistAdmin(
        address to,
        uint256 landId,
        string memory longitude,
        string memory latitude,
        PolygonCoordinates[] memory coordinates
    ) public {
        _isWhitelistedAdmin(AdminRoles.MINTER);

        if (_exists(landId)) {
            revert IdAlreadyExist();
        }

        if (!isMintingEnable) {
            revert MintingStatusPaused();
        }

        if (platformMintingCount >= platformMintingLimit) {
            revert PlatformMintingLimitReached();
        }

        platformMintingCount++;

        _storeLandInformation(landId, longitude, latitude, coordinates);

        _safeMint(to, landId);

        emit LandMintedByAdmin(landId, to);
    }

    /**
     * @dev mintLandPublic is used to create a new land for public.
     * Requirement:
     * - This function is for public minting.It can be accessible when minting is enabled and public sale status is true.
     *
     * @param landId - landId
     * @param to - address to mint the land
     * @param longitude - longitude
     * @param latitude - latitude
     * @param coordinates - polygonCoordinates

     *
     * Emits a {LandMintedByPublicUser} event.
     */

    function mintLandPublic(
        address to,
        uint256 landId,
        string memory longitude,
        string memory latitude,
        PolygonCoordinates[] memory coordinates
    ) public {
        if (_exists(landId)) {
            revert IdAlreadyExist();
        }

        if (!isPublicSaleActive) {
            revert PublicSaleNotActive();
        }
        if (landMintedCount[msg.sender] >= landMintingLimitPerAddress) {
            revert MintingLimitReached();
        }
        if (publicUsersMintingCount >= publicMintingLimit) {
            revert UsersMintingLimitReached();
        }

        publicUsersMintingCount++;
        landMintedCount[msg.sender]++;

        _storeLandInformation(landId, longitude, latitude, coordinates);

        _safeMint(to, landId);

        emit LandMintedByPublicUser(landId, to);
    }

    /**
     * @dev getLandsByAddress is used to get land info by wallet address.
     * Requirement:
     * - This function can called by anyone.
     *
     * @param _address - address to get land info
     */

    function getLandsByAddress(address _address)
        public
        view
        returns (Land[] memory)
    {
        Land[] memory landInfo = new Land[](balanceOf(_address));

        if (balanceOf(_address) == 0) revert AddressNotExist();

        uint objectIndex = 0;
        for (uint i = 0; i < balanceOf(_address); i++) {
            uint256 tokenId = tokenOfOwnerByIndex(_address, i);
            landInfo[objectIndex].longitude = land[tokenId].longitude;
            landInfo[objectIndex].latitude = land[tokenId].latitude;
            landInfo[objectIndex].polygonCoordinates = land[tokenId]
                .polygonCoordinates;
            objectIndex++;
        }

        return landInfo;
    }

    /**
     * @dev getLandById is used to get land info by landId.
     * Requirement:
     * - This function can called by anyone
     *
     * @param landId - landId to get land info
     */

    function getLandById(uint landId)
        public
        view
        returns (
            string memory,
            string memory,
            PolygonCoordinates[] memory
        )
    {
        if (!_exists(landId)) {
            revert IdNotExist();
        }

        PolygonCoordinates[] memory coordinates = new PolygonCoordinates[](
            land[landId].polygonCoordinates.length
        );

        for (uint i = 0; i < land[landId].polygonCoordinates.length; ) {
            coordinates[i].longitude = land[landId]
                .polygonCoordinates[i]
                .longitude;
            coordinates[i].latitude = land[landId]
                .polygonCoordinates[i]
                .latitude;

            unchecked {
                i++;
            }
        }

        return (land[landId].longitude, land[landId].latitude, coordinates);
    }

    /**
     * @dev tokenURI is used to get tokenURI link
     * @param landId - ID of land
     * @return string
     */

    function tokenURI(uint landId)
        public
        view
        override(ERC721Upgradeable)
        returns (string memory)
    {
        if (!_exists(landId)) {
            revert IdNotExist();
        }

        return string(abi.encodePacked(baseURI, Strings.toString(landId)));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
