// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract LandContractV2 is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    string public baseURI;
    bytes32 public usersWhitelistRoot;

    struct Land {
        string metadataHash;
    }

    mapping(uint256 => Land) public land;
    mapping(address => bool) public adminWhitelistedAddresses;

    error LandNotExist();
    error InvalidMetadataHash();
    error NotAPartOfWhitelist();
    error AddressIsAlreadyWhitelisted();
    error NotWhitelistedAddress();
    error InvalidBaseURI();

    event SetBaseURI(string baseURI, address addedBy);
    event LandMinted(uint256 tokenId, address mintedBy, string metadataHash);
    event RootUpdated(bytes32 updatedRoot, address updatedBy);
    event AddedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event RemovedWhitelistAdmin(address whitelistedAddress, address updatedBy);
    event ContractPaused(string message, address pausedBy);
    event ContractUnPaused(string message, address unPausedBy);

    function initialize(bytes32 _whitelistedRoot) public initializer {
        __ERC721_init("LandContract", "W-Land");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();

        baseURI = "https://gateway.pinata.cloud/ipfs/";

        usersWhitelistRoot = _whitelistedRoot;

        emit SetBaseURI(baseURI, msg.sender);
    }

    modifier isWhitelistedAdmin() {
        if (!adminWhitelistedAddresses[msg.sender]) {
            revert NotWhitelistedAddress();
        }
        _;
    }

    function contractPause() public onlyOwner {
        _pause();

        emit ContractPaused("Pause", msg.sender);
    }

    function contractUnPause() public onlyOwner {
        _unpause();

        emit ContractUnPaused("UnPause", msg.sender);
    }

    /**
     * @dev setBaseUri is used to set BaseURI.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _baseURI - New baseURI
     *
     * Emits a {SetBaseURI} event.
     */
    function setBaseUri(string memory _baseURI) external onlyOwner {
        if (bytes(_baseURI).length != 34) {
            revert InvalidBaseURI();
        }

        baseURI = _baseURI;

        emit SetBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev updateUsersWhitelistedRoot is used to update root of merkle proof.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _usersWhitelistedRoot - New merkle root
     *
     * Emits a {RootUpdated} event.
     */
    function updateUsersWhitelistedRoot(bytes32 _usersWhitelistedRoot)
        external
        onlyOwner
    {
        usersWhitelistRoot = _usersWhitelistedRoot;

        emit RootUpdated(usersWhitelistRoot, msg.sender);
    }

    function isValid(bytes32[] memory proof, bytes32 leaf)
        public
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, usersWhitelistRoot, leaf);
    }

    /**
     * @dev addWhitelistedAdmin is used to add whitelsit admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param whitelistAddress - Admin to be whitelisted
     *
     * Emits a {AddedWhitelistAdmin} event.
     */
    function addWhitelistedAdmin(address whitelistAddress) external onlyOwner {
        if (adminWhitelistedAddresses[whitelistAddress]) {
            revert AddressIsAlreadyWhitelisted();
        }
        adminWhitelistedAddresses[whitelistAddress] = true;

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
        if (!adminWhitelistedAddresses[whitelistAddress]) {
            revert NotWhitelistedAddress();
        }

        adminWhitelistedAddresses[whitelistAddress] = false;

        emit RemovedWhitelistAdmin(whitelistAddress, msg.sender);
    }

    /**
     * @dev mintLand is used to create a new land.
     * Requirement:
     * @param metadataHash - land metadata
     * @param tokenId - land Id
     * @param to - address to mint the land
     *
     * Emits a {LandMinted} event.
     */
    function mintLand(
        address to,
        uint256 tokenId,
        string memory metadataHash,
        bytes32[] memory proof
    ) public {
        if (!isValid(proof, keccak256(abi.encodePacked(msg.sender)))) {
            revert NotAPartOfWhitelist();
        }
        if (bytes(metadataHash).length != 46) {
            revert InvalidMetadataHash();
        }

        _safeMint(to, tokenId);

        land[tokenId] = Land(metadataHash);

        emit LandMinted(tokenId, to, metadataHash);
    }

    /**
     * @dev tokenURI is used to get tokenURI link.
     *
     * @param _tokenId - ID of drone
     *
     * @return string .
     */

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        if (!_exists(_tokenId)) {
            revert LandNotExist();
        }
        return string(abi.encodePacked(baseURI, land[_tokenId].metadataHash));
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

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
