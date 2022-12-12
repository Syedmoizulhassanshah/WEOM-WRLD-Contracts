// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AccessPass is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable,
    ERC1155HolderUpgradeable,
    ReentrancyGuard
{
    string public name;
    string public symbol;

    uint256 public passIDCount;

    string public baseURI;
    bool public isPassMintingEnabled;
    bool public isClaimEnabled;
    bool public isTransferEnabled;
    address payable public platformAddress;

    enum PassStatus {
        NOTISSUED,
        BOUGHT,
        CLAIMED
    }

    enum AdminRoles {
        NONE,
        MINTER,
        MANAGER
    }

    enum PassTypes {
        WEOM_25m2,
        WEOM_50m2
    }

    struct FetchAccessPasses {
        uint256 passID;
        uint256 passSoldSupply;
        uint256 passTotalSupply;
        PassTypes passType;
        PassStatus status;
        uint256 passPrice;
        string passName;
        bytes32 whitelistRootHash;
        string passMetadata;
        bool passSaleStatus;
        address allowedContractAddress;
    }

    struct AccessPassAllocation {
        PassStatus status;
    }

    struct AccessPassInfo {
        string passName;
        string passMetadata;
        PassTypes passType;
        uint256 passSoldSupply;
        uint256 passTotalSupply;
        bytes32 whitelistRootHash;
        uint256 passPrice;
        address allowedContractAddress;
        bool passSaleStatus;
        mapping(address => mapping(uint256 => AccessPassAllocation)) accessPassAllocation;
    }

    struct PassTypeInfo {
        uint256 count;
        uint256[] passID;
    }

    struct UserPassHoldingInfo {
        uint256 passID;
        uint256 passNumber;
    }

    mapping(uint256 => AccessPassInfo) public accessPassInfo;
    mapping(PassTypes => PassTypeInfo) public passTypeInfo;
    mapping(address => AdminRoles) public adminWhitelistedAddresses;
    mapping(address => UserPassHoldingInfo) public userPassHoldingStatus;

    error NotWhitelistedAddress();
    error MintingDisabled();
    error TokenIdNotExists();
    error TransferDisabled();
    error InvalidPassPrice();
    error PassStatusDeactivated();
    error PassIDCannotBeZero();
    error InvalidPassID();
    error InvalidOwner();
    error AccessForbidden();
    error InvalidMetadataHash();
    error PassIDNotExists();
    error AddressAlreadyExists();
    error AddressNotExists();
    error AlreadyPurchased();
    error NoAccessPassExistsToClaim();
    error ClaimStatusDeactivated();
    error PaymentFailed();

    event AddedNewPass(uint256 passID, string passName, address addedBy);
    event UpdatedTransferStatus(bool status, address updatedBy);
    event UpdatedBaseURI(string baseURI, address updatedBy);
    event UpdatedMintStatus(bool status, address updatedBy);
    event UpdatedSaleStatus(bool status, address updatedBy);
    event UpdatedClaimStatus(bool status, address updatedBy);
    event UpdatedWhitelistRootHash(
        uint256 passID,
        bytes32 whitelistRootHash,
        address updatedBy
    );
    event UpdatedAllowedContractAddress(
        address allowedContractAddress,
        address updatedBy
    );
    event UpdatedPlatformAddress(address platformAddress, address updatedBy);
    event AddedWhitelistAdmin(address whitelistedAddress, address addedBy);
    event RemovedWhitelistAdmin(address whitelistedAddress, address removedBy);
    event ClaimedPass(uint256 passID, PassStatus passStatus, address claimedBy);
    event BoughtPass(
        uint256 passID,
        uint256 passNumber,
        uint256 price,
        address boughtBy
    );
    event MintedPass(
        uint256 PassId,
        uint256 quantity,
        address mintedTo,
        address mintedBy
    );
    event TransferredPass(
        uint256 PassId,
        uint256 quantity,
        address transferredBy,
        address transferredTo
    );

    function initialize(
        string memory _baseURI,
        address _platformAddress,
        bool _isTransferEnabled
    ) public initializer {
        __ERC1155_init("");
        __Ownable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();

        name = "Access Passes";
        symbol = "AP";
        baseURI = _baseURI;
        isClaimEnabled = true;
        platformAddress = payable(_platformAddress);
        isTransferEnabled = _isTransferEnabled;

        emit UpdatedBaseURI(baseURI, msg.sender);
    }

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
            revert AccessForbidden();
        }
    }

    function validateMerkleProof(
        uint256 passID,
        bytes32[] memory proof,
        bytes32 leaf
    ) internal view returns (bool) {
        return
            MerkleProof.verify(
                proof,
                accessPassInfo[passID].whitelistRootHash,
                leaf
            );
    }

    /**
     * @dev updatePlatformAddress is used to update the platformAddress.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param _platformAddress - platformAddress
     *
     * Emits a {UpdatedWhitelistRootHash} event.
     */

    function updatePlatformAddress(address _platformAddress) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        platformAddress = payable(_platformAddress);

        emit UpdatedPlatformAddress(platformAddress, msg.sender);
    }

    /**
     * @dev updateWhitelistRootHash is used to update the whitelistRootHash.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param passID - passID
     * @param whitelistRootHash - updated whitelistRootHash
     *
     * Emits a {UpdatedWhitelistRootHash} event.
     */

    function updateWhitelistRootHash(uint256 passID, bytes32 whitelistRootHash)
        external
    {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        accessPassInfo[passID].whitelistRootHash = whitelistRootHash;

        emit UpdatedWhitelistRootHash(passID, whitelistRootHash, msg.sender);
    }

    /**
     * @dev updatePassMintStatus is used to update the pass minting status for enabling and disabling minting.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param status - true or false value
     *
     * Emits a {UpdatedMintStatus} event.
     */

    function updatePassMintStatus(bool status) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        isPassMintingEnabled = status;

        emit UpdatedMintStatus(status, msg.sender);
    }

    /**
     * @dev updateStatusForSale is used to update the pass sale status.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param status - true or false value
     *
     * Emits a {UpdatedSaleStatus} event.
     */

    function updateSaleStatus(uint256 passID, bool status) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        accessPassInfo[passID].passSaleStatus = status;

        emit UpdatedSaleStatus(status, msg.sender);
    }

    /**
     * @dev updateClaimStatus is used to update the claim status.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param status - true or false value
     *
     * Emits a {UpdatedClaimStatus} event.
     */

    function updateClaimStatus(bool status) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        isClaimEnabled = status;

        emit UpdatedClaimStatus(status, msg.sender);
    }

    /**
     * @dev updateTransferStatus is used to update the isTransferEnabled value for enabling and disabling Passs Transfer.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param status - true or false value
     *
     * Emits a {UpdatedTransferStatus} event.
     */

    function updateTransferStatus(bool status) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        isTransferEnabled = status;

        emit UpdatedTransferStatus(status, msg.sender);
    }

    /**
     * @dev updateAllowedContractAddres is used to update the allowed contract address.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param passID - passID
     * @param allowedContractAddress - new allowed contract address
     *
     * Emits a {UpdatedAllowedContractAddress} event.
     */

    function updateAllowedContractAddres(
        uint256 passID,
        address allowedContractAddress
    ) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        accessPassInfo[passID].allowedContractAddress = allowedContractAddress;

        emit UpdatedAllowedContractAddress(allowedContractAddress, msg.sender);
    }

    /**
     * @dev addWhitelistAdmin is used to add whitelist admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param whitelistAddress - address to be whitelisted
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
            revert AddressNotExists();
        }

        adminWhitelistedAddresses[whitelistAddress] = AdminRoles.NONE;

        emit RemovedWhitelistAdmin(whitelistAddress, msg.sender);
    }

    /**
     * @dev updateBaseURI is used to update baseURI.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param _baseURI - New baseURI
     * Emits a {UpdatedBaseURI} event.
     */

    function updateBaseURI(string memory _baseURI) external {
        _isWhitelistedAdmin(AdminRoles.MANAGER);
        baseURI = _baseURI;

        emit UpdatedBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev addAccessPass is used to add a new access pass.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param   passName - access pass name
     * @param   passType - access pass type
     * @param   passMetadata - access pass metadata hash
     * @param   passPrice - access pass price
     * @param   whitelistRootHash - whitelist root hash
     * @param   allowedContractAddress - whitelist root hash
     *
     ** Emits a {addAccessPass} event.
     */

    function addAccessPass(
        string memory passName,
        PassTypes passType,
        string memory passMetadata,
        uint256 passPrice,
        bytes32 whitelistRootHash,
        address allowedContractAddress
    ) public returns (uint256) {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (passPrice <= 0) {
            revert InvalidPassPrice();
        }

        if (bytes(passMetadata).length != 46) {
            revert InvalidMetadataHash();
        }

        passIDCount++;

        passTypeInfo[passType].count++;
        passTypeInfo[passType].passID.push(passIDCount);
        accessPassInfo[passIDCount].passName = passName;
        accessPassInfo[passIDCount].passType = passType;
        accessPassInfo[passIDCount].whitelistRootHash = whitelistRootHash;
        accessPassInfo[passIDCount].passPrice = passPrice;
        accessPassInfo[passIDCount].passMetadata = passMetadata;
        accessPassInfo[passIDCount]
            .allowedContractAddress = allowedContractAddress;

        emit AddedNewPass(passIDCount, passName, msg.sender);

        return (passIDCount);
    }

    /**
     * @dev mintPass is used to create a new Pass.
     * Requirement:
     * - This function can only called by whitelisted admin with minter role
     *
     * @param passID - pass id to mint
     * @param account - address where to mint
     * @param passSupply -  number of pass to mint
     *
     * Emits a {MintedPass} event.
     */

    function mintPass(
        uint256 passID,
        address account,
        uint256 passSupply
    ) external nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MINTER);

        if (!isPassMintingEnabled) {
            revert PassStatusDeactivated();
        }

        accessPassInfo[passID].passTotalSupply += passSupply;

        _mint(account, passID, passSupply, "");

        emit MintedPass(passID, passSupply, account, msg.sender);
    }

    /**
     * @dev buyPass is used to buy a Pass.
     * Requirement:
     * - This function can only be called by allowlist addresses
     *
     * @param passID - pass id to mint
     * @param proof - allowlist proof to mint
     * Emits a {BoughtPass} event.
     */

    function buyPass(uint256 passID, bytes32[] memory proof)
        external
        payable
        nonReentrant
    {
        if (userPassHoldingStatus[msg.sender].passID > 0) {
            revert AlreadyPurchased();
        }

        if (
            !validateMerkleProof(
                passID,
                proof,
                keccak256(abi.encodePacked(msg.sender))
            )
        ) {
            revert NotWhitelistedAddress();
        }

        if (accessPassInfo[passID].passPrice > msg.value) {
            revert InvalidPassPrice();
        }

        if (!accessPassInfo[passID].passSaleStatus) {
            revert PassStatusDeactivated();
        }

        if (!exists(passID)) {
            revert InvalidPassID();
        }

        (bool sent, ) = platformAddress.call{value: msg.value}("");
        if (!sent) {
            revert PaymentFailed();
        }
        accessPassInfo[passID].passSoldSupply++;
        userPassHoldingStatus[msg.sender].passID = passID;
        userPassHoldingStatus[msg.sender].passNumber = accessPassInfo[passID]
            .passSoldSupply;

        accessPassInfo[passID]
        .accessPassAllocation[msg.sender][accessPassInfo[passID].passSoldSupply]
            .status = PassStatus.BOUGHT;

        _safeTransferFrom(address(this), msg.sender, passID, 1, "");

        emit BoughtPass(
            passID,
            accessPassInfo[passID].passSoldSupply,
            msg.value,
            msg.sender
        );
    }

    /**
     * @dev transferAccessPass is used to transfer pass to account.
     * Requirement:
     * - This function can only called by whitelisted admin with manager role
     *
     * @param passID - pass id
     * @param account - account to transfer
     * @param quantity - amount to transfer
     * Emits a {TransferredPass} event.
     */

    function transferAccessPass(
        uint256 passID,
        address account,
        uint256 quantity
    ) external nonReentrant {
        _isWhitelistedAdmin(AdminRoles.MANAGER);

        if (!exists(passID)) {
            revert TokenIdNotExists();
        }

        _safeTransferFrom(address(this), account, passID, quantity, "");

        emit TransferredPass(passID, quantity, msg.sender, account);
    }

    function testTranferCall(uint256 passID) external nonReentrant {
        userPassHoldingStatus[msg.sender].passID = 0;
        userPassHoldingStatus[msg.sender].passNumber = 0;
        accessPassInfo[passID].passSoldSupply--;

        accessPassInfo[passID]
        .accessPassAllocation[msg.sender][accessPassInfo[passID].passSoldSupply]
            .status = PassStatus.NOTISSUED;

        _safeTransferFrom(msg.sender, address(this), passID, 1, "");
    }

    /**
     * @dev uri is used to get the uri by token ID.
     *
     * Requirement:
     *
     * @param passID - passID
     */

    function uri(uint256 passID) public view override returns (string memory) {
        if (!exists(passID)) {
            revert TokenIdNotExists();
        }
        return
            string(
                abi.encodePacked(baseURI, accessPassInfo[passID].passMetadata)
            );
    }

    /**
     * @dev claimPass is used to set the status of pass number of a specific passID for a access pass to CLAIMED once that access pass is used or owner of the pass can set it CLAIMED if he wants to waste it.
     * Requirement:
     * @param  account - pass account address
     * @param  passID - pass Pass id
     * @param  passNumber - copy number of specific access pass minted at passID
     *
     * Emits a {ClaimPass} event.
     */

    function claimPass(
        address account,
        uint256 passID,
        uint256 passNumber
    ) public {
        if (!isClaimEnabled) {
            revert ClaimStatusDeactivated();
        }

        if (accessPassInfo[passID].allowedContractAddress != msg.sender) {
            revert AccessForbidden();
        }

        if (balanceOf(account, passID) == 0) {
            revert NoAccessPassExistsToClaim();
        }

        if (!exists(passID)) {
            revert PassIDNotExists();
        }

        if (
            accessPassInfo[passID]
            .accessPassAllocation[account][passNumber].status ==
            PassStatus.NOTISSUED
        ) {
            revert InvalidOwner();
        }

        accessPassInfo[passID]
        .accessPassAllocation[account][passNumber].status = PassStatus.CLAIMED;

        emit ClaimedPass(passID, PassStatus.CLAIMED, account);
    }

    function getAccessPassByType(PassTypes passType)
        public
        view
        returns (
            bool,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        bool passSaleStatus;
        uint256 activePassID;
        uint256 passSoldSupply;
        uint256 passTotalSupply;
        uint256 passPrice;

        for (
            uint256 passID = 0;
            passID < passTypeInfo[passType].count;
            passID++
        ) {
            if (
                accessPassInfo[passTypeInfo[passType].passID[passID]]
                    .passSaleStatus
            ) {
                passSaleStatus = accessPassInfo[
                    passTypeInfo[passType].passID[passID]
                ].passSaleStatus;
                activePassID = passTypeInfo[passType].passID[passID];

                passPrice = accessPassInfo[
                    passTypeInfo[passType].passID[passID]
                ].passPrice;
            }
            passSoldSupply += accessPassInfo[
                passTypeInfo[passType].passID[passID]
            ].passSoldSupply;

            passTotalSupply += accessPassInfo[
                passTypeInfo[passType].passID[passID]
            ].passTotalSupply;
        }
        return (
            passSaleStatus,
            passPrice,
            activePassID,
            passSoldSupply,
            passTotalSupply
        );
    }

    function getAccessPassDetails(
        address account,
        uint256 passID,
        uint256 passNumber
    )
        public
        view
        returns (
            PassStatus,
            PassTypes,
            string memory,
            string memory,
            uint256,
            address
        )
    {
        return (
            accessPassInfo[passID]
            .accessPassAllocation[account][passNumber].status,
            accessPassInfo[passID].passType,
            accessPassInfo[passID].passName,
            accessPassInfo[passID].passMetadata,
            accessPassInfo[passID].passSoldSupply,
            accessPassInfo[passID].allowedContractAddress
        );
    }

    function getAccessPassesSupplyDetails()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 passSoldSupply;
        uint256 passTotalSupply;

        for (uint256 passID = 1; passID <= passIDCount; passID++) {
            passSoldSupply += accessPassInfo[passID].passSoldSupply;
            passTotalSupply += accessPassInfo[passID].passTotalSupply;
        }

        return (passIDCount, passTotalSupply, passSoldSupply);
    }

    function getAllAccessPasses()
        public
        view
        returns (FetchAccessPasses[] memory)
    {
        FetchAccessPasses[] memory fetchPasses = new FetchAccessPasses[](
            passIDCount
        );

        for (uint256 passID = 1; passID <= passIDCount; passID++) {
            fetchPasses[passID - 1].passID = passID;
            fetchPasses[passID - 1].passSoldSupply = accessPassInfo[passID]
                .passSoldSupply;
            fetchPasses[passID - 1].passType = accessPassInfo[passID].passType;
            fetchPasses[passID - 1].passTotalSupply = accessPassInfo[passID]
                .passTotalSupply;
            fetchPasses[passID - 1].passName = accessPassInfo[passID].passName;
            fetchPasses[passID - 1].passMetadata = accessPassInfo[passID]
                .passMetadata;
            fetchPasses[passID - 1].whitelistRootHash = accessPassInfo[passID]
                .whitelistRootHash;
            fetchPasses[passID - 1].passPrice = accessPassInfo[passID]
                .passPrice;
            fetchPasses[passID - 1].allowedContractAddress = accessPassInfo[
                passID
            ].allowedContractAddress;
        }

        return (fetchPasses);
    }

    function getAccessPassByAddress(address account)
        public
        view
        returns (
            uint256,
            uint256,
            PassTypes,
            string memory,
            uint256,
            address
        )
    {
        return (
            userPassHoldingStatus[account].passID,
            userPassHoldingStatus[account].passNumber,
            accessPassInfo[userPassHoldingStatus[account].passID].passType,
            accessPassInfo[userPassHoldingStatus[account].passID].passMetadata,
            accessPassInfo[userPassHoldingStatus[account].passID]
                .passSoldSupply,
            accessPassInfo[userPassHoldingStatus[account].passID]
                .allowedContractAddress
        );
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Upgradeable, ERC1155SupplyUpgradeable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        if (!isTransferEnabled) {
            revert TransferDisabled();
        }

        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        if (!isTransferEnabled) {
            revert TransferDisabled();
        }

        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Upgradeable, ERC1155ReceiverUpgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
