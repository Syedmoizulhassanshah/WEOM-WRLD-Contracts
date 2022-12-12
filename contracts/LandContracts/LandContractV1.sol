// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./LandContractCore.sol";

contract LandContractV1 is LandContractCore {
    /**
     * @dev updateMintingStatus is used to update mintng status.
     * Requirement:
     *  - This function can only called by manager role
     * @param _status - bool true/false
     *
     * Emits a {UpdatedLandMintStatus} event.
     */

    function updateMintingStatus(bool _status) external {
        if (isMintingEnabled == _status) {
            revert AlreadySameStatus();
        }

        _isGreenlistedAdmin(AdminRoles.MANAGER);
        isMintingEnabled = _status;

        emit UpdatedLandMintStatus(_status, msg.sender);
    }

    /**
     * @dev updatePremiumStatus is used to enable premium mintng.
     * Requirement:
     *  - This function can only called by manager role
     * @param _status - bool true/false
     *
     * Emits a {UpdatedPremiumStatus} event.
     */

    function updatePremiumStatus(bool _status) external {
        if (isPremiumEnabled == _status) {
            revert AlreadySameStatus();
        }

        _isGreenlistedAdmin(AdminRoles.MANAGER);
        isPremiumEnabled = _status;

        emit UpdatedPremiumStatus(_status, msg.sender);
    }

    /**
     * @dev updateglobalUserMintingLimit is used to update the global minting.
     * Requirement:
     *  - This function can only called by manager role
     * @param newLimit - newLimit
     *
     * Emits a {UpdatedGlobalUserMintingLimit} event.
     */

    function updateglobalUserMintingLimit(uint256 newLimit) external {
        _isGreenlistedAdmin(AdminRoles.MANAGER);

        globalUserMintingLimit = newLimit;

        emit UpdatedGlobalUserMintingLimit(newLimit, msg.sender);
    }

    /**
     * @dev updateGreenlistUserMintingStatus is used to allow greenlist users to mint.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param status - bool true/false
     *
     * Emits a {UpdatedGreenlistUserMintingStatus} event.
     */

    function updateGreenlistUserMintingStatus(bool status) external {
        if (isGreenlistUserMintingAllowed == status) {
            revert AlreadySameStatus();
        }
        _isGreenlistedAdmin(AdminRoles.MANAGER);

        isGreenlistUserMintingAllowed = status;

        emit UpdatedGreenlistUserMintingStatus(status, msg.sender);
    }

    /**
     * @dev updateBaseURI is used to update BaseURI.
     * Requirement:
     *  - This function can only called by manager role
     *
     * @param _baseURI - New baseURI
     *
     * Emits a {UpdatedBaseURI} event.
     */

    function updateBaseURI(string memory _baseURI) external {
        _isGreenlistedAdmin(AdminRoles.MANAGER);

        if (bytes(_baseURI).length == 0) {
            revert InvalidParameters("BaseURI empty");
        }

        baseURI = _baseURI;

        emit UpdatedBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev addAccessPassContractAddress  is used to add Access Pass Contract Address for calling its functions via a interface.
     * Requirement:
     * - This function can only called by owner of the land
     * @param accessPassContractAddress - Access Pass Contract Address
     *
     * Emits a {AddedAccessPassContractAddress} event.
     */

    function addAccessPassContractAddress(address accessPassContractAddress)
        external
        onlyOwner
    {
        passInterface = IAccessPass(accessPassContractAddress);

        emit AddedAccessPassContractAddress(accessPassContractAddress, owner());
    }

    /**
     * @dev addGreenlistAdmin is used to add greenlist admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param greenlistAddress - Admin to be greenlisted
     *
     * Emits a {AddedGreenlistAdmin} event.
     */

    function addGreenlistAdmin(
        address greenlistAddress,
        AdminRoles allowPermission
    ) external onlyOwner {
        if (adminGreenlistedAddresses[greenlistAddress] != AdminRoles.NONE) {
            revert AddressAlreadyExists();
        }
        adminGreenlistedAddresses[greenlistAddress] = allowPermission;

        emit AddedGreenlistAdmin(greenlistAddress, msg.sender);
    }

    /**
     * @dev removeGreenlistAdmin is used to remove greenlist admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param greenlistAddress - Accounts to be removed
     *
     * Emits a {RemovedGreenlistAdmin} event.
     */

    function removeGreenlistAdmin(address greenlistAddress) external onlyOwner {
        if (adminGreenlistedAddresses[greenlistAddress] == AdminRoles.NONE) {
            revert AddressNotExists();
        }

        adminGreenlistedAddresses[greenlistAddress] = AdminRoles.NONE;

        emit RemovedGreenlistAdmin(greenlistAddress, msg.sender);
    }

    /**
     * @dev updateGreenlistPartner is used to add/update greenlist partner account.
     * Requirement:
     * - This function can only called by manager role
     *
     * @param greenlistAddress - Partner to be greenlisted
     *
     * Emits a {UpdatedGreenlistPartner} event.
     */

    function updateGreenlistPartner(address greenlistAddress, bool status)
        external
    {
        _isGreenlistedAdmin(AdminRoles.MANAGER);

        if (greenlistedPartners[greenlistAddress] == status) {
            revert AddressAlreadyExists();
        }

        greenlistedPartners[greenlistAddress] = status;

        emit UpdatedGreenlistPartner(greenlistAddress, msg.sender);
    }

    /**
     * @dev addNewPhase is used to add a new phase.
     * Requirement:
     * @param   phaseID - phaseID of new phase
     * @param   name - name of new phase.
     * @param   phaseMintReserveLimit - reserve limit for greenlist addresses
     * @param   normalGreenlistRootHash - new normalGreenlistRootHash
     * @param   normalMintLimitPerAddress - minting limit per address
     * @param   premiumGreenlistRootHash - new premiumGreenlistRootHash
     * @param   premiumMintLimitPerAddress - minting limit per address
     * @param   isPremiumEnable - bool true/false
     *
     * Emits a {AddedNewPhase} event.
     */

    function addNewPhase(
        uint256 phaseID,
        string memory name,
        uint256 phaseMintReserveLimit,
        bytes32 normalGreenlistRootHash,
        uint256 normalMintLimitPerAddress,
        bytes32 premiumGreenlistRootHash,
        uint256 premiumMintLimitPerAddress,
        bool isPremiumEnable
    ) external {
        _isGreenlistedAdmin(AdminRoles.MANAGER);

        if (isPremiumEnable) {
            _validateNewPremiumPhaseInformation(
                premiumGreenlistRootHash,
                premiumMintLimitPerAddress
            );

            phase[phaseID].premiumGreenlistRootHash = premiumGreenlistRootHash;
            phase[phaseID]
                .premiumMintLimitPerAddress = premiumMintLimitPerAddress;
        }

        _validateNewPhaseInformation(
            phaseID,
            name,
            normalMintLimitPerAddress,
            phaseMintReserveLimit
        );

        phase[phaseID].normalGreenlistRootHash = normalGreenlistRootHash;
        phase[phaseID].name = name;
        phase[phaseID].normalMintLimitPerAddress = normalMintLimitPerAddress;
        phase[phaseID].phaseMintReserveLimit = phaseMintReserveLimit;

        phaseCount++;

        emit AddedNewPhase(
            phaseID,
            name,
            phaseMintReserveLimit,
            normalMintLimitPerAddress,
            normalGreenlistRootHash,
            premiumGreenlistRootHash,
            premiumMintLimitPerAddress
        );
    }

    /**
     * @dev activatePhase is used to activate the phase.
     * Requirement:
     * - This function can only called by manager role
     *
     * @param phaseID - phaseID
     * Emits a {UpdatedPhaseStatus} event.
     */

    function activatePhase(uint256 phaseID) external {
        _isGreenlistedAdmin(AdminRoles.MANAGER);
        _validateNewPhaseParameters(phaseID);

        phase[phaseID].isActivated = true;
        phase[phaseID].phaseStatus = true;
        currentPhaseID = phaseID;

        emit UpdatedPhaseStatus(phaseID, phase[phaseID].phaseStatus);
    }

    /**
     * @dev deactivatePhase is used to deactivate an active/running phase.
     * Requirement:
     * - This function can only called by manager role.
     *
     * @param phaseID - PhaseID of an active phase.
     * Emits a {UpdatedPhaseStatus} event.
     */

    function deactivatePhase(uint256 phaseID) external {
        _isGreenlistedAdmin(AdminRoles.MANAGER);

        if (phaseID == 0) {
            revert PhaseIDCannotZero();
        }
        if (bytes(phase[phaseID].name).length == 0) {
            revert PhaseIDNotExists();
        }
        if (!phase[phaseID].phaseStatus) {
            revert AlreadyDeactivated();
        }

        userMintingCount += phase[phaseID].phaseMintedCount;
        phase[phaseID].phaseStatus = false;
        currentPhaseID = 0;

        emit UpdatedPhaseStatus(phaseID, phase[phaseID].phaseStatus);
    }

    /**
     * @dev mintLandByAccessPass is used to mint new land.
      * Requirement:
     * - This function can only called by the address who have access pass.
    
     * @param metadataHash - drone metadata
     * @param passID- pass reward id
     * @param  passCopyNumber - copy number of specific Access pass minted at _passID
     *
     * Emits a {DroneMinted} event.
     */

    function mintLandByAccessPass(
        string memory metadataHash,
        uint256 passID,
        uint256 passCopyNumber
    ) external {
        (IAccessPass.PassStatus passStatus, , , , , ) = passInterface
            .getAccessPassDetails(msg.sender, passID, passCopyNumber);

        userMintingCount++;

        if (
            userMintingCount >
            userMintingLimit - phase[currentPhaseID].phaseMintReserveLimit
        ) {
            revert UserMintingLimitExceeds();
        }

        validateAccessPassInfo(metadataHash, passID, passStatus);

        passInterface.claimPass(msg.sender, passID, passCopyNumber);
    }

    /**
     * @dev mintLandByPhase is used to create a new land by phases.
     * Requirement:
     * - This function can only called by greenlisted admin with minter role and greenlisted users if allowed.
     *
     * @param landID - landID
     * @param to - address to mint the land
     * @param longitude - longitude
     * @param latitude - latitude
     * @param metadataHash - metadataHash
     * @param polygonCoordinates - polygonCoordinates
     * @param proof - proof of greenlist users
     *
     * Emits a {LandMintedByPhase} event.
     */

    function mintLandByPhase(
        address to,
        uint256 landID,
        string memory longitude,
        string memory latitude,
        string memory metadataHash,
        string memory polygonCoordinates,
        bytes32[] memory proof,
        UserType userType
    ) external {
        _validatePhaseInformation(to, 1, userType);
        _validateGreenlistUser(to, proof, userType);
        _validateLandInputParameters(
            landID,
            longitude,
            latitude,
            metadataHash,
            polygonCoordinates
        );

        _validationPhaseLandParameters(landID, to, userType);

        phase[currentPhaseID].userLandMintedCount[to]++;
        phase[currentPhaseID].phaseMintedCount++;
        globalMintCount[to]++;

        _storeLandInformation(
            landID,
            longitude,
            latitude,
            metadataHash,
            polygonCoordinates
        );
        _safeMint(to, landID);

        emit LandMintedByPhase(landID, to);
    }

    /**
     * @dev mintLandByAdmin is used to create a new land only by greenlist admin.
     * Requirement:
     * - This function can only called by greenlisted admin with minter role
     *
     * @param landID - landID
     * @param to - address to mint the land
     * @param longitude - longitude
     * @param latitude - latitude
     * @param metadataHash - metadataHash
     * @param polygonCoordinates - polygonCoordinates
     *
     * Emits a {LandMintedByAdmin} event.
     */

    function mintLandByAdmin(
        address to,
        uint256 landID,
        string memory longitude,
        string memory latitude,
        string memory metadataHash,
        string memory polygonCoordinates
    ) external {
        _isGreenlistedAdmin(AdminRoles.MINTER);

        _validateAdminLandInformation();
        _validateLandInputParameters(
            landID,
            longitude,
            latitude,
            metadataHash,
            polygonCoordinates
        );

        platformMintingCount++;

        _storeLandInformation(
            landID,
            longitude,
            latitude,
            metadataHash,
            polygonCoordinates
        );
        _safeMint(to, landID);

        emit LandMintedByAdmin(landID, to);
    }

    /**
     * @dev bulkMintLandsByAdmin is used to create bulk lands only by greenlist admin.
     * Requirement:
     * - This function can only called by greenlisted admin with minter role
     *
     * @param landInfo - mint land parameters in the form of a tuple.
     *
     * Emits a {BulkLandMintedByAdmin} event.
     */

    function bulkMintLandsByAdmin(BulkMintLandInfo calldata landInfo) external {
        _isGreenlistedAdmin(AdminRoles.MINTER);
        _validationBulkLandParametersLength(landInfo);
        _validateAdminLandInformation();

        platformMintingCount += landInfo.landID.length;

        _batchMint(landInfo, false);

        emit BulkLandMintedByAdmin(landInfo.to, landInfo.landID, msg.sender);
    }

    /**
     * @dev bulkMintLandsByPhase is used to create bulk land only w.r.t phase.
     * Requirement:
     * - This function can only called by greenlisted admin with minter role and greenlisted users if allowed.
     *
     * @param landInfo - bulk mint land in the form of a tuple.
     * @param proof - proof of greenlist users
     *
     * Emits a {BulkLandMintedByPhase} event.
     */

    function bulkMintLandsByPhase(
        BulkMintLandInfo calldata landInfo,
        bytes32[] memory proof,
        UserType userType
    ) external {
        _validateGreenlistUser(landInfo.to, proof, userType);
        _validationBulkLandParametersLength(landInfo);
        _validatePhaseInformation(msg.sender, landInfo.landID.length, userType);

        phase[currentPhaseID].phaseMintedCount += landInfo.landID.length;

        _batchMint(landInfo, true);

        emit BulkLandMintedByPhase(landInfo.to, landInfo.landID, msg.sender);
    }

    /**
     * @dev bulkMintLandForPartners is used to create a new land only for greenlist partners.
     * Requirement:
     * - This function can only called by greenlisted admin with minter role
     *
     * @param landInfo - bulk mint land in the form of a tuple.
     *
     * Emits a {BatchLandMintedForPartners} event.
     */

    function bulkMintLandForPartners(BulkMintLandInfo calldata landInfo)
        external
    {
        _isGreenlistedAdmin(AdminRoles.MINTER);
        _validationBulkLandParametersLength(landInfo);

        userMintingCount += landInfo.landID.length;

        if (
            userMintingCount >
            userMintingLimit - phase[currentPhaseID].phaseMintReserveLimit
        ) {
            revert UserMintingLimitExceeds();
        }

        if (!greenlistedPartners[landInfo.to]) {
            revert AddressNotExists();
        }

        _batchMint(landInfo, false);

        emit BatchLandMintedForPartners(
            landInfo.to,
            landInfo.landID,
            msg.sender
        );
    }

    /**
     * @dev getUserLandMintedCount is used to get user minted count per address by phases.
     * Requirement:
     * - This function can called by anyone.
     *
     * @param userAddress - address
     * @param phaseID - id
     */

    function getUserLandMintedCount(uint256 phaseID, address userAddress)
        external
        view
        returns (uint256, uint256)
    {
        return (
            phase[phaseID].userLandMintedCount[userAddress],
            userMintingLimit - globalMintCount[userAddress]
        );
    }

    /**
     * @dev getLandsByAddress is used to get land info by wallet address.
     * Requirement:
     * - This function can called by anyone.
     *
     * @param userAddress - address to get land info
     */

    function getLandsByAddress(address userAddress)
        external
        view
        returns (ReturnLandInfo[] memory)
    {
        ReturnLandInfo[] memory lands = new ReturnLandInfo[](
            balanceOf(userAddress)
        );

        for (uint256 i = 0; i < balanceOf(userAddress); i++) {
            uint256 landID = tokenOfOwnerByIndex(userAddress, i);
            lands[i].landID = landID;
            lands[i].longitude = land[landID].longitude;
            lands[i].latitude = land[landID].latitude;
            lands[i].metadataHash = land[landID].metadataHash;
            lands[i].polygonCoordinates = land[landID].polygonCoordinates;
        }

        return lands;
    }

    /**
     * @dev getLandById is used to get land info by landID.
     * Requirement:
     * - This function can called by anyone
     *
     * @param landID - landID to get land info
     */

    function getLandById(uint256 landID)
        external
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        return (
            land[landID].longitude,
            land[landID].latitude,
            land[landID].metadataHash,
            land[landID].polygonCoordinates
        );
    }

    /**
     * @dev tokenURI is used to get tokenURI link
     *
     * @param landID - ID of land
     *
     */

    function tokenURI(uint256 landID)
        public
        view
        override(ERC721Upgradeable)
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, land[landID].metadataHash));
    }

    /**
     * @dev getPhaseStatus is used to phase status info by phaseID.
     * Requirement:
     * - This function can be called by anyone
     *
     * @param phaseID - phaseID to get phase status info
     */

    function getPhaseStatus(uint256 phaseID) public view returns (bool) {
        return phase[phaseID].phaseStatus;
    }

    /**
     * @dev getPhaseInfo is used to get phase info by phaseID.
     * Requirement:
     * - This function can be called by anyone
     *
     * @param phaseID - phaseID to get phase info
     */

    function getPhaseInfo(uint256 phaseID)
        external
        view
        returns (ReturnPhaseInfo memory)
    {
        ReturnPhaseInfo memory phaseDetails;

        phaseDetails.name = phase[phaseID].name;
        phaseDetails.phaseStatus = phase[phaseID].phaseStatus;
        phaseDetails.isActivated = phase[phaseID].isActivated;
        phaseDetails.normalGreenlistRootHash = phase[phaseID]
            .normalGreenlistRootHash;
        phaseDetails.normalMintLimitPerAddress = phase[phaseID]
            .normalMintLimitPerAddress;
        phaseDetails.premiumGreenlistRootHash = phase[phaseID]
            .premiumGreenlistRootHash;
        phaseDetails.premiumMintLimitPerAddress = phase[phaseID]
            .premiumMintLimitPerAddress;
        phaseDetails.phaseMintReserveLimit = phase[phaseID]
            .phaseMintReserveLimit;
        phaseDetails.phaseMintedCount = phase[phaseID].phaseMintedCount;

        return phaseDetails;
    }

    /**
     * @dev updateTransferStatus is used to update the isTransferAllowed value for enabling and disabling Transfer feature.
     *
     * Requirement:
     *
     * - This function can only called by manager role.
     *
     * @param _status - true or false value
     *
     * Emits a {UpdatedTransferStatus} event.
     */

    function updateTransferStatus(bool _status) external {
        _isGreenlistedAdmin(AdminRoles.MANAGER);

        if (isTransferAllowed == _status) {
            revert AlreadySameStatus();
        }

        isTransferAllowed = _status;

        emit UpdatedTransferStatus(_status, msg.sender);
    }

    /**
     * @dev updatePartnerTransferStatus is used to update the isPartnerTransferAllowed value for enabling and disabling Transfer feature.
     *
     * Requirement:
     *
     * - This function can only called by manager role.
     *
     * @param _status - true or false value
     *
     * Emits a {UpdatedTransferStatus} event.
     */

    function updatePartnerTransferStatus(bool _status) external {
        _isGreenlistedAdmin(AdminRoles.MANAGER);

        if (isPartnerTransferAllowed == _status) {
            revert AlreadySameStatus();
        }

        isPartnerTransferAllowed = _status;

        emit UpdatedTransferStatus(_status, msg.sender);
    }
}
