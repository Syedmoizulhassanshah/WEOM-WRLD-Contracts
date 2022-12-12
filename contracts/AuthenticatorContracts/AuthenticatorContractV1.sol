// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract AuthenticatorContractV1 is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    enum AdminRoles {
        AUTHENTICATOR,
        DEPLOYER,
        MINTER,
        MANAGER
    }

    mapping(address => mapping(AdminRoles => bool))
        public adminWhitelistedAddresses;

    error AddressIsAlreadyWhitelisted();
    error NotWhitelistedAddress();

    event AddedWhitelistAdmin(
        address whitelistedAddress,
        AdminRoles permission,
        address updatedBy
    );
    event RemovedWhitelistAdmin(
        address whitelistedAddress,
        AdminRoles permission,
        address updatedBy
    );

    function initialize() external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender][requiredRole] != true) {
            revert NotWhitelistedAddress();
        }
    }

    /**
     * @dev addWhitelistAdmin is used to add whitelist admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param whitelistAddress - Admin to be whitelisted
     * @param allowPermission - Assign role to admin address
     *
     * Emits a {AddedWhitelistAdmin} event.
     */

    function addWhitelistAdmin(
        address whitelistAddress,
        AdminRoles allowPermission
    ) external onlyOwner {
        if (
            adminWhitelistedAddresses[whitelistAddress][allowPermission] !=
            false
        ) {
            revert AddressIsAlreadyWhitelisted();
        }
        adminWhitelistedAddresses[whitelistAddress][allowPermission] = true;

        emit AddedWhitelistAdmin(whitelistAddress, allowPermission, msg.sender);
    }

    /**
     * @dev removeWhitelistAdmin is used to remove whitelist admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param whitelistAddress - Account to be removed
     * @param removePermission - revoke role from admin address
     *
     * Emits a {RemovedWhitelistAdmin} event.
     */

    function removeWhitelistAdmin(
        address whitelistAddress,
        AdminRoles removePermission
    ) external onlyOwner {
        if (
            adminWhitelistedAddresses[whitelistAddress][removePermission] ==
            false
        ) {
            revert NotWhitelistedAddress();
        }

        adminWhitelistedAddresses[whitelistAddress][removePermission] = false;

        emit RemovedWhitelistAdmin(
            whitelistAddress,
            removePermission,
            msg.sender
        );
    }

    /**
     * @dev validateAdmin is used to validate the admin account.
     *
     * @param whitelistAddress - Account to validate
     * @param accessType - Admin roles to validate
     *
     */

    function validateAdmin(address whitelistAddress, AdminRoles accessType)
        external
        view
        returns (bool status)
    {
        if (adminWhitelistedAddresses[whitelistAddress][accessType])
            return true;
        else return false;
    }

    function adminRolesLength() internal view returns (uint8) {
        uint8 adminEnumLength = uint8(type(AdminRoles).max) + 1;
        return adminEnumLength;
    }

    /**
     * @dev getAdminPermissions is used to get all permissions on address
     *
     * @param whitelistAddress - Admin address to get permissions
     */

    function getAdminPermissions(address whitelistAddress)
        external
        view
        returns (bool[] memory)
    {
        bool[] memory roles = new bool[](adminRolesLength());

        for (uint8 i = 0; i < adminRolesLength(); ) {
            if (adminWhitelistedAddresses[whitelistAddress][AdminRoles(i)])
                roles[i] = true;
            unchecked {
                i++;
            }
        }

        return roles;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
