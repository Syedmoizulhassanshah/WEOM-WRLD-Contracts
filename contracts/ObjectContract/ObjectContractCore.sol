// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./utils/CustomErrors.sol";

contract ObjectContractCore is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable
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

    struct bulkMintObjects {
        uint256 objectId;
        address to;
        string name;
        string objectType;
        string metadataHash;
    }

    enum AdminRoles {
        NONE,
        MINTER,
        MANAGER
    }

    mapping(uint256 => Objects) public object;
    mapping(address => AdminRoles) public adminWhitelistedAddresses;

    event UpdatedBaseURI(string baseURI, address updatedBy);
    event ObjectMinted(
        uint256 objectId,
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
            revert InvalidParameters("Input cannot be empty");
        }
        if (_validationContractAddress(to)) {
            revert InvalidParameters("To address cannot be contract address");
        }
        if (bytes(metadataHash).length != 46) {
            revert InvalidParameters("Metadata hash not correct");
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
            revert NotExists();
        }
    }

    function _storeObjectsInformation(
        uint256 objectId,
        string memory name,
        string memory objectType,
        string memory metadataHash
    ) internal {
        object[objectId].metadataHash = metadataHash;
        object[objectId].name = name;
        object[objectId].objectType = objectType;
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

    function _beforeConsecutiveTokenTransfer(
        address from,
        address to,
        uint256 i, /*first*/
        uint96 size
    )
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        whenNotPaused
    {
        super._beforeConsecutiveTokenTransfer(from, to, i, size);
    }
}
