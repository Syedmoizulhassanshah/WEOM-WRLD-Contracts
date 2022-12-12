// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../utils/CustomErrors.sol";

interface IAccessPass {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    enum PassStatus {
        NOTISSUED,
        UNCLAIMED,
        CLAIMED
    }

    function getAccessPassDetails(
        address account,
        uint256 _passID,
        uint256 _passCopyNumber
    )
        external
        view
        returns (
            PassStatus,
            string memory,
            string memory,
            uint256,
            bytes32,
            address
        );

    function claimPass(
        address account,
        uint256 _passID,
        uint256 _passCopyNumber
    ) external;
}

contract LandContractCore is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    string public baseURI;
    uint256 public maxMintingLimit;
    uint256 public platformMintingLimit;
    uint256 public userMintingLimit;

    uint256 public globalUserMintingLimit;
    uint256 public userMintingCount;
    uint256 public platformMintingCount;

    uint256 public currentPhaseID;
    uint256 public phaseCount;

    bool public isMintingEnabled;
    bool public isPremiumEnabled;
    bool public isTransferAllowed;
    bool public isPartnerTransferAllowed;
    bool public isGreenlistUserMintingAllowed;

    IAccessPass public passInterface;

    struct Land {
        string longitude;
        string latitude;
        string metadataHash;
        string polygonCoordinates;
    }

    struct ReturnLandInfo {
        uint256 landID;
        string longitude;
        string latitude;
        string metadataHash;
        string polygonCoordinates;
    }

    struct BulkMintLandInfo {
        address to;
        uint256[] landID;
        string[] longitude;
        string[] latitude;
        string[] metadataHash;
        string[] polygonCoordinates;
    }

    struct PhaseInfo {
        string name;
        bool phaseStatus;
        bool isActivated;
        bytes32 normalGreenlistRootHash;
        uint256 normalMintLimitPerAddress;
        uint256 phaseMintReserveLimit;
        uint256 phaseMintedCount;
        bytes32 premiumGreenlistRootHash;
        uint256 premiumMintLimitPerAddress;
        mapping(address => uint256) userLandMintedCount;
        UserType userType;
    }

    struct ReturnPhaseInfo {
        string name;
        bool phaseStatus;
        bool isActivated;
        bytes32 normalGreenlistRootHash;
        uint256 normalMintLimitPerAddress;
        bytes32 premiumGreenlistRootHash;
        uint256 premiumMintLimitPerAddress;
        uint256 phaseMintReserveLimit;
        uint256 phaseMintedCount;
    }

    enum AdminRoles {
        NONE,
        MINTER,
        MANAGER
    }

    enum UserType {
        NONE,
        PUBLIC,
        NORMAL,
        PREMIUM
    }

    mapping(uint256 => Land) public land;
    mapping(address => AdminRoles) public adminGreenlistedAddresses;
    mapping(address => bool) public greenlistedPartners;
    mapping(address => uint256) public globalMintCount;
    mapping(uint256 => PhaseInfo) public phase;

    event UpdatedBaseURI(string baseURI, address updatedBy);
    event UpdatedLandMintStatus(bool status, address updatedBy);
    event UpdatedGreenlistUserMintingStatus(bool status, address updatedBy);
    event UpdatedPremiumStatus(bool status, address updatedBy);
    event UpdatedGlobalUserMintingLimit(uint256 newLimit, address updatedBy);
    event LandMintedByAdmin(uint256 landID, address mintedBy);
    event BulkLandMintedByAdmin(address to, uint256[] landID, address mintedBy);
    event BatchLandMintedForPartners(
        address to,
        uint256[] landID,
        address mintedBy
    );
    event AddedGreenlistAdmin(address greenlistedAddress, address addedBy);
    event UpdatedGreenlistPartner(
        address partnergreenlistedAddress,
        address addedBy
    );
    event RemovedGreenlistAdmin(address greenlistedAddress, address removedBy);
    event ConstructorInitialized(
        string baseURI,
        uint256 platformMintingLimit,
        address updatedBy
    );
    event AddedNewPhase(
        uint256 phaseID,
        string name,
        uint256 phaseMintReserveLimit,
        uint256 normalMintLimitPerAddress,
        bytes32 normalGreenlistRootHash,
        bytes32 premiumGreenlistRootHash,
        uint256 premiumMintLimitPerAddress
    );
    event AddedAccessPassContractAddress(
        address accessPassContractAddress,
        address addedBy
    );
    event UpdatedTransferStatus(bool status, address updatedBy);
    event LandMintedByPhase(uint256 landID, address to);
    event BulkLandMintedByPhase(address to, uint256[] landID, address mintedBy);
    event UpdatedPhaseStatus(uint256 phaseID, bool phaseStatus);

    function initialize(
        uint256 _maxMintingLimit,
        uint256 _platformMintingLimit,
        uint256 _globalUserMintingLimit,
        string memory _baseURI
    ) public initializer {
        __ERC721_init("LAND", "W-Land");
        __Ownable_init();
        __UUPSUpgradeable_init();

        baseURI = _baseURI;
        maxMintingLimit = _maxMintingLimit;
        platformMintingLimit = _platformMintingLimit;
        userMintingLimit = maxMintingLimit - platformMintingLimit;
        globalUserMintingLimit = _globalUserMintingLimit;

        emit ConstructorInitialized(baseURI, platformMintingLimit, msg.sender);
    }

    function validateAccessPassInfo(
        string memory metadataHash,
        uint256 passID,
        IAccessPass.PassStatus passStatus
    ) internal view {
        if (bytes(metadataHash).length != 46) {
            revert InvalidMetadataHash();
        }

        if (passID == 0) {
            revert PassIDCannotZero();
        }

        if (passInterface.balanceOf(msg.sender, passID) == 0) {
            revert NoAccessPassExists();
        }

        if (passStatus == IAccessPass.PassStatus.NOTISSUED) {
            revert NoAccessPassExists();
        }

        if (passStatus == IAccessPass.PassStatus.CLAIMED) {
            revert PassAlreadyUsed();
        }
    }

    function _validateLandInputParameters(
        uint256 landID,
        string memory longitude,
        string memory latitude,
        string memory metadataHash,
        string memory polygonCoordinates
    ) internal view {
        if (landID < 1 || landID > maxMintingLimit) {
            revert LandIdExceedLimit();
        }
        if (
            bytes(longitude).length == 0 ||
            bytes(latitude).length == 0 ||
            bytes(metadataHash).length == 0 ||
            bytes(polygonCoordinates).length == 0
        ) {
            revert InvalidParameters("Input cannot empty");
        }
        if (_exists(landID)) {
            revert AlreadyExists("landID");
        }

        if (!isMintingEnabled) {
            revert MintingStatusPaused();
        }
    }

    function _validationPhaseLandParameters(
        uint256 landID,
        address to,
        UserType userType
    ) internal view {
        if (_exists(landID)) {
            revert AlreadyExists("landID");
        }
        if (
            phase[currentPhaseID].phaseMintedCount >=
            phase[currentPhaseID].phaseMintReserveLimit
        ) {
            revert CannotMint("Phase limit reached");
        }
        if (globalMintCount[to] >= globalUserMintingLimit) {
            revert CannotMint("Global limit reached");
        }

        if (UserType.PREMIUM == userType) {
            if (
                phase[currentPhaseID].userLandMintedCount[to] >=
                phase[currentPhaseID].premiumMintLimitPerAddress
            ) {
                revert CannotMint("User per address limit reached");
            }
        } else {
            if (
                phase[currentPhaseID].userLandMintedCount[to] >=
                phase[currentPhaseID].normalMintLimitPerAddress
            ) {
                revert CannotMint("User per address limit reached");
            }
        }
    }

    function _isGreenlistedAdmin(AdminRoles requiredRole) internal view {
        if (adminGreenlistedAddresses[msg.sender] != requiredRole) {
            revert AccessForbidden();
        }
    }

    function _validateAdminLandInformation() internal view {
        if (platformMintingCount >= platformMintingLimit) {
            revert CannotMint("Platform limit reached");
        }
    }

    function _validatePhaseInformation(
        address to,
        uint256 newMintCount,
        UserType userType
    ) internal view {
        if (isGreenlistUserMintingAllowed) {
            if (to != msg.sender) {
                revert AddressMismatched();
            }
        } else {
            _isGreenlistedAdmin(AdminRoles.MINTER);
        }

        if (!phase[currentPhaseID].phaseStatus) {
            revert CannotMint("Phase deactivated");
        }

        if (!isMintingEnabled) {
            revert MintingStatusPaused();
        }

        if (UserType.PREMIUM == userType && !isPremiumEnabled) {
            revert CannotMint("Premium phase deactivated");
        }

        if (
            (phase[currentPhaseID].userLandMintedCount[to] + newMintCount) >=
            phase[currentPhaseID].phaseMintReserveLimit
        ) {
            revert CannotMint("GreenlistUsers limit reached");
        }
    }

    function _validateGreenlistUser(
        address to,
        bytes32[] memory proof,
        UserType userType
    ) internal view {
        if (UserType.PREMIUM == userType) {
            if (
                !validatePremiumMerkleProof(
                    proof,
                    keccak256(abi.encodePacked(to))
                )
            ) {
                revert NotPremiumGreenlistUser();
            }
        } else if (UserType.NORMAL == userType) {
            if (
                !validateGreenlistMerkleProof(
                    proof,
                    keccak256(abi.encodePacked(to))
                )
            ) {
                revert NotNormalGreenlistUser();
            }
        }
    }

    function _validationBulkLandParametersLength(
        BulkMintLandInfo memory bulkLandInfo
    ) internal pure {
        if (
            bulkLandInfo.landID.length != bulkLandInfo.longitude.length ||
            bulkLandInfo.landID.length != bulkLandInfo.metadataHash.length ||
            bulkLandInfo.landID.length != bulkLandInfo.latitude.length ||
            bulkLandInfo.landID.length != bulkLandInfo.polygonCoordinates.length
        ) {
            revert InvalidParameters("Length mismatched");
        }
    }

    function _storeLandInformation(
        uint256 landID,
        string memory longitude,
        string memory latitude,
        string memory metadataHash,
        string memory polygonCoordinates
    ) internal {
        land[landID].longitude = longitude;
        land[landID].latitude = latitude;
        land[landID].metadataHash = metadataHash;
        land[landID].polygonCoordinates = polygonCoordinates;
    }

    function validateGreenlistMerkleProof(bytes32[] memory proof, bytes32 leaf)
        internal
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                proof,
                phase[currentPhaseID].normalGreenlistRootHash,
                leaf
            );
    }

    function validatePremiumMerkleProof(bytes32[] memory proof, bytes32 leaf)
        internal
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                proof,
                phase[currentPhaseID].premiumGreenlistRootHash,
                leaf
            );
    }

    function _validateNewPhaseInformation(
        uint256 phaseID,
        string memory name,
        uint256 normalMintLimitPerAddress,
        uint256 phaseMintReserveLimit
    ) internal view {
        if (phaseID == 0) {
            revert PhaseIDCannotZero();
        }
        if (bytes(phase[phaseID].name).length != 0) {
            revert PhaseIDAlreadyExist();
        }
        if (phaseCount != 0 && phase[currentPhaseID].phaseStatus) {
            revert AlreadyActivated();
        }
        if (bytes(name).length == 0) {
            revert InvalidParameters("Name cannot empty");
        }
        if (normalMintLimitPerAddress == 0) {
            revert InvalidParameters("Limit cannot zero");
        }
        if (phaseMintReserveLimit == 0) {
            revert InvalidParameters("Reseve limit cannot zero");
        }
        if ((userMintingCount + phaseMintReserveLimit) > userMintingLimit) {
            revert UserMintingLimitExceeds();
        }
    }

    function _validateNewPremiumPhaseInformation(
        bytes32 premiumGreenlistRootHash,
        uint256 premiumMintLimitPerAddress
    ) internal pure {
        if (premiumMintLimitPerAddress == 0) {
            revert InvalidParameters("Limit cannot zero");
        }
        if (bytes32(premiumGreenlistRootHash).length == 0) {
            revert InvalidParameters("Root hash empty");
        }
    }

    function _validateNewPhaseParameters(uint256 phaseID) internal view {
        if (phaseID == 0) {
            revert InvalidParameters("PhaseID cannot zero");
        }

        if (phase[phaseID].isActivated) {
            revert AlreadyActivated();
        }

        if (bytes(phase[phaseID].name).length == 0) {
            revert NotExists();
        }

        if (currentPhaseID != 0) {
            revert AlreadyActivated();
        }
    }

    function _batchMint(BulkMintLandInfo calldata landInfo, bool isPhaseMinting)
        internal
    {
        for (uint256 i = 0; i < landInfo.landID.length; i++) {
            _validateLandInputParameters(
                landInfo.landID[i],
                landInfo.longitude[i],
                landInfo.latitude[i],
                landInfo.metadataHash[i],
                landInfo.polygonCoordinates[i]
            );
            _storeLandInformation(
                landInfo.landID[i],
                landInfo.longitude[i],
                landInfo.latitude[i],
                landInfo.metadataHash[i],
                landInfo.polygonCoordinates[i]
            );

            if (isPhaseMinting) {
                phase[currentPhaseID].userLandMintedCount[msg.sender]++;
            }

            _safeMint(landInfo.to, landInfo.landID[i]);
        }
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId)
        public
        virtual
        override(IERC721Upgradeable, ERC721Upgradeable)
    {
        if (!isTransferAllowed) {
            revert TransferDisabled();
        }

        super.approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override(IERC721Upgradeable, ERC721Upgradeable)
    {
        if (!isTransferAllowed) {
            revert TransferDisabled();
        }
        super.setApprovalForAll(operator, approved);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(IERC721Upgradeable, ERC721Upgradeable) {
        if (!isTransferAllowed) {
            if (
                !isPartnerTransferAllowed ||
                greenlistedPartners[msg.sender] != true
            ) {
                revert TransferDisabled();
            }
        }

        super.safeTransferFrom(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(IERC721Upgradeable, ERC721Upgradeable) {
        if (!isTransferAllowed) {
            if (
                !isPartnerTransferAllowed ||
                greenlistedPartners[msg.sender] != true
            ) {
                revert TransferDisabled();
            }
        }

        super.safeTransferFrom(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override(IERC721Upgradeable, ERC721Upgradeable) {
        if (!isTransferAllowed) {
            if (
                !isPartnerTransferAllowed ||
                greenlistedPartners[msg.sender] != true
            ) {
                revert TransferDisabled();
            }
        }

        super.safeTransferFrom(from, to, tokenId, data);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 landID
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, landID);
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
