// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract LandContract is
    Initializable,
    ERC721Upgradeable,
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
    uint256 public nftMintingLimitPerAddress;
    bool public isPublicSaleActive;
    bool public isMintingPause;

    struct PolygonCoordinates {
        string longitude;
        string latitude;
    }

    struct Land {
        string longitude;
        string latitude;
        string metadataHash;
        PolygonCoordinates[] polygonCoordinates;
    }

    mapping(address => uint256) public nftLimit;
    mapping(uint => Land) public land;
    mapping(address => AdminRoles) public adminWhitelistedAddresses;

    error LandNotExist();
    error InvalidMetadataHash();
    error NotAPartOfWhitelist();
    error AddressIsAlreadyWhitelisted();
    error NotWhitelistedAddress();
    error InvalidBaseURI();
    error MintingLimitReached();
    error PlatformMintingLimitReached();
    error MaxMintingLimitReached();
    error UsersMintingLimitReached();
    error PublicSaleIsNotActive();
    error PublicSaleActiveYouCannotMint();
    error MintingStatusPausedYouCannotMint();

    event SetBaseURI(string baseURI, address addedBy);
    event LandMinted(uint tokenId, address mintedBy, string metadataHash);
    event RootUpdated(bytes32 updatedRoot, address updatedBy);
    event AddedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event RemovedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event UpdatedWhitelistUsersMintingLimit(
        uint256 limit,
        bytes32 whitelistedRoot,
        address updatedBy
    );
    event UpdatedplatformMintingLimit(uint256 limit, address updatedBy);
    event UpdatedPublicMintingLimit(uint256 limit, address updatedBy);
    event UpdatedMaxMintingLimit(uint256 limit, address updatedBy);
    event updatedNftMintingLimitPerAddress(
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
        uint _nftMintingLimitPerAddress,
        uint _platformMintingLimit
    ) public initializer {
        __ERC721_init("LandContract", "W-Land");
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        baseURI = "https://gateway.pinata.cloud/ipfs/";

        maxMintingLimit = _maxMintingLimit;
        nftMintingLimitPerAddress = _nftMintingLimitPerAddress;
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

    function _verifyMetadataHash(string memory metadataHash) internal pure {
        if (bytes(metadataHash).length != 46) {
            revert InvalidMetadataHash();
        }
    }

    function _storeLandInformation(
        uint tokenId,
        string memory longitude,
        string memory latitude,
        string memory metadataHash,
        PolygonCoordinates[] memory coordinates
    ) internal {
        land[tokenId].longitude = longitude;
        land[tokenId].latitude = latitude;
        land[tokenId].metadataHash = metadataHash;

        for (uint i = 0; i < coordinates.length; ) {
            land[tokenId].polygonCoordinates.push(
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

    function contractPause() public {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _pause();
    }

    function contractUnPause() public {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        _unpause();
    }

    /**
     * @dev updateMintingStatus is used to update miintng status.
     * Requirement:
     * - This function can only called by owner of the Contract
     * @param _status - status of drone Id
     * Emits a {MintingStatusUpdated} event.
     */

    function updateMintingStatus(bool _status) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        isMintingPause = _status;

        emit MintingStatusUpdated(_status, msg.sender);
    }

    /**
     * @dev setBaseURI is used to set BaseURI.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _baseURI - New baseURI
     *
     * Emits a {SetBaseURI} event.
     */

    function setBaseURI(string memory _baseURI) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (bytes(_baseURI).length != 34) {
            revert InvalidBaseURI();
        }

        baseURI = _baseURI;

        emit SetBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev updateMaxMintingLimit is used to update minting limit.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _maxMintingLimit - New _maxMintingLimit
     *
     * Emits a {UpdatedMaxMintingLimit} event.
     */

    function updateMaxMintingLimit(uint _maxMintingLimit) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        maxMintingLimit += _maxMintingLimit;

        emit UpdatedMaxMintingLimit(maxMintingLimit, msg.sender);
    }

    /**
     * @dev updatePlatformMintingLimit is used to update platform minting limit.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _platformMintingLimit - New _platformMintingLimit
     *
     * Emits a {UpdatedplatformMintingLimit} event.
     */

    function updatePlatformMintingLimit(uint _platformMintingLimit) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        platformMintingLimit += _platformMintingLimit;
        publicMintingLimit = maxMintingLimit - platformMintingLimit;

        emit UpdatedplatformMintingLimit(_platformMintingLimit, msg.sender);
    }

    /**
     * @dev updatePublicMintingLimit is used to update public minting limit.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _publicMintingLimit - New _publicMintingLimit
     *
     * Emits a {UpdatedPublicMintingLimit} event.
     */

    function updatePublicMintingLimit(uint _publicMintingLimit) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (_publicMintingLimit >= maxMintingLimit) {
            revert MaxMintingLimitReached();
        }

        publicMintingLimit += _publicMintingLimit;

        emit UpdatedPublicMintingLimit(_publicMintingLimit, msg.sender);
    }

    /**
     * @dev updateWhitelistUsersMintingLimit is used to update whitelistUsersMintingLimit and whitelistedRoot.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _whitelistUsersMintingLimit - New whitelistUsersMintingLimit
     * @param _whitelistedRoot - New whitelistedRoot
     *
     * Emits a {UpdatedWhitelistUsersMintingLimit} event.
     */

    function updateWhitelistUsersMintingLimit(
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
            nftMintingLimitPerAddress;

        publicMintingLimit = publicMintingLimit - whitelistUsersMintingLimit;

        emit UpdatedWhitelistUsersMintingLimit(
            whitelistUsersMintingLimit,
            usersWhitelistRootHash,
            msg.sender
        );
    }

    function isValid(bytes32[] memory proof, bytes32 leaf)
        public
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, usersWhitelistRootHash, leaf);
    }

    /**
     * @dev addWhitelistAdmin is used to add whitelsit admin account.
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
            revert AddressIsAlreadyWhitelisted();
        }
        adminWhitelistedAddresses[whitelistAddress] = allowPermission;

        emit AddedWhitelistAdmin(whitelistAddress, msg.sender);
    }

    /**
     * @dev removeWhitelistAdmin is used to remove whitelsit admin account.
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
     * @dev updateNftMintingLimitPerAddress is used to update nft minting limit per address.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param _nftMintingLimitPerAddress - New limit nftMintingLimitPerAddress
     *
     * Emits a {updatedNftMintingLimitPerAddress} event.
     */

    function updateNftMintingLimitPerAddress(uint256 _nftMintingLimitPerAddress)
        external
    {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        nftMintingLimitPerAddress = _nftMintingLimitPerAddress;

        emit updatedNftMintingLimitPerAddress(
            nftMintingLimitPerAddress,
            msg.sender
        );
    }

    /**
     * @dev mintLandWhitelistUsers is used to create a new land for white list users.
     * Requirement:
     * - This function can only called by whitelisted users
     *
     * @param tokenId - land Id
     * @param to - address to mint the land
     * @param metadataHash - land metadata hash
     * @param longitude - longitude
     * @param latitude - latitud
     * @param coordinates - polygonCoordinates
     * @param proof - proof of whitelist users
     *
     * Emits a {LandMinted} event.
     */

    function mintLandWhitelistUsers(
        address to,
        uint256 tokenId,
        string memory longitude,
        string memory latitude,
        PolygonCoordinates[] memory coordinates,
        string memory metadataHash,
        bytes32[] memory proof
    ) public {
        _verifyMetadataHash(metadataHash);

        if (isPublicSaleActive == true) {
            revert PublicSaleActiveYouCannotMint();
        }
        if (!isValid(proof, keccak256(abi.encodePacked(msg.sender)))) {
            revert NotAPartOfWhitelist();
        }
        if (nftLimit[msg.sender] >= nftMintingLimitPerAddress) {
            revert MintingLimitReached();
        }
        if (whitelistUsersMintingCount >= whitelistUsersMintingLimit) {
            revert UsersMintingLimitReached();
        }
        whitelistUsersMintingCount++;

        nftLimit[msg.sender] += 1;

        _safeMint(to, tokenId);

        _storeLandInformation(
            tokenId,
            longitude,
            latitude,
            metadataHash,
            coordinates
        );

        emit LandMinted(tokenId, to, metadataHash);
    }

    /**
     * @dev mintLandWhitelistAdmin is used to create a new land only by whitelist admin.
     * Requirement:
     * - This function can only called by whitelisted admin
     *
     *  * @param tokenId - land Id
     * @param to - address to mint the land
     * @param metadataHash - land metadata hash
     * @param longitude - longitude
     * @param latitude - latitud
     * @param coordinates - polygonCoordinates
     *
     * Emits a {LandMinted} event.
     */

    function mintLandWhitelistAdmin(
        address to,
        uint256 tokenId,
        string memory longitude,
        string memory latitude,
        PolygonCoordinates[] memory coordinates,
        string memory metadataHash
    ) public {
        _isWhitelistedAdmin(AdminRoles.MINTER);
        _verifyMetadataHash(metadataHash);

        if (isMintingPause != true) {
            revert MintingStatusPausedYouCannotMint();
        }

        if (platformMintingCount >= platformMintingLimit) {
            revert PlatformMintingLimitReached();
        }

        _safeMint(to, tokenId);

        _storeLandInformation(
            tokenId,
            longitude,
            latitude,
            metadataHash,
            coordinates
        );

        platformMintingCount++;

        emit LandMinted(tokenId, to, metadataHash);
    }

    /**
     * @dev mintLandPublic is used to create a new land for public.
     * Requirement:
     * - This function is for public minting.
     *
     * @param tokenId - land Id
     * @param to - address to mint the land
     * @param metadataHash - land metadata hash
     * @param longitude - longitude
     * @param latitude - latitude
     * @param coordinates - polygonCoordinates

     *
     * Emits a {LandMinted} event.
     */

    function mintLandPublic(
        address to,
        uint256 tokenId,
        string memory longitude,
        string memory latitude,
        PolygonCoordinates[] memory coordinates,
        string memory metadataHash
    ) public {
        _verifyMetadataHash(metadataHash);

        if (isPublicSaleActive != true) {
            revert PublicSaleIsNotActive();
        }
        if (nftLimit[msg.sender] >= nftMintingLimitPerAddress) {
            revert MintingLimitReached();
        }
        if (publicUsersMintingCount >= publicMintingLimit) {
            revert UsersMintingLimitReached();
        }

        publicUsersMintingCount++;
        nftLimit[msg.sender] += 1;

        _safeMint(to, tokenId);

        _storeLandInformation(
            tokenId,
            longitude,
            latitude,
            metadataHash,
            coordinates
        );

        emit LandMinted(tokenId, to, metadataHash);
    }

    function getLandInfo(uint tokenId)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            PolygonCoordinates[] memory
        )
    {
        if (!_exists(tokenId)) {
            revert LandNotExist();
        }

        PolygonCoordinates[] memory coordinates = new PolygonCoordinates[](
            land[tokenId].polygonCoordinates.length
        );

        for (uint i = 0; i < land[tokenId].polygonCoordinates.length; ) {
            coordinates[i].longitude = land[tokenId]
                .polygonCoordinates[i]
                .longitude;
            coordinates[i].latitude = land[tokenId]
                .polygonCoordinates[i]
                .latitude;

            unchecked {
                i++;
            }
        }

        return (
            land[tokenId].metadataHash,
            land[tokenId].longitude,
            land[tokenId].latitude,
            coordinates
        );
    }

    /**
     * @dev updateActivePublicSale is used to active the public sale.
     *
     * @param active - to true/falsee
     *
     * @return bool .
     */

    function updateActivePublicSale(bool active) public returns (bool) {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (whitelistUsersMintingCount != whitelistUsersMintingLimit) {
            publicMintingLimit +=
                whitelistUsersMintingLimit -
                whitelistUsersMintingCount;
        }

        isPublicSaleActive = active;

        return true;
    }

    /**
     * @dev tokenURI is used to get tokenURI link.
     *
     * @param _tokenId - ID of drone
     *
     * @return string .
     */

    function tokenURI(uint _tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(_tokenId)) {
            revert LandNotExist();
        }
        return string(abi.encodePacked(baseURI, land[_tokenId].metadataHash));
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
