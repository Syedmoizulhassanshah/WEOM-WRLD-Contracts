// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";
import "../utils/CustomErrors.sol";
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

    event AddedWhitelistAdmins(
        address[] whitelistedAddress,
        AdminRoles[] permission,
        address updatedBy
    );
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
            revert AddressAlreadyExists();
        }
    }

    /**
     * @dev addWhitelistAdmin is used to add whitelsit admin account.
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
            revert AlreadyExists("Whitelisted address");
        }
        adminWhitelistedAddresses[whitelistAddress][allowPermission] = true;

        emit AddedWhitelistAdmin(whitelistAddress, allowPermission, msg.sender);
    }

    /**
     * @dev addWhitelistAdmins is used to add whitelsit admin accounts and permissions.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param whitelistAddresses - Admins to be whitelisted
     * @param allowPermissions - Assign roles to admin addresses
     *
     * Emits a {AddedWhitelistAdmins} event.
     */

    function addWhitelistAdmins(
        address[] memory whitelistAddresses,
        AdminRoles[] memory allowPermissions
    ) external onlyOwner {
        for (uint256 i = 0; i < whitelistAddresses.length; i++) {
            for (uint256 j = 0; j < allowPermissions.length; j++) {
                if (
                    !adminWhitelistedAddresses[whitelistAddresses[i]][
                        allowPermissions[j]
                    ]
                ) {
                    adminWhitelistedAddresses[whitelistAddresses[i]][
                        allowPermissions[j]
                    ] = true;
                }
            }
        }
        emit AddedWhitelistAdmins(
            whitelistAddresses,
            allowPermissions,
            msg.sender
        );
    }

    /**
     * @dev removeWhitelistAdmin is used to remove whitelsit admin account.
     * Requirement:
     * - This function can only called by owner of the contract
     *
     * @param whitelistAddress - Accounts to be removed
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
            revert AddressNotExists();
        }

        adminWhitelistedAddresses[whitelistAddress][removePermission] = false;

        emit RemovedWhitelistAdmin(
            whitelistAddress,
            removePermission,
            msg.sender
        );
    }

    function validateAdmin(address whitelistAddress, AdminRoles accessType)
        external
        view
        returns (bool status)
    {
        if (adminWhitelistedAddresses[whitelistAddress][accessType])
            return true;
        else return false;
    }

    function adminRolesLength() internal pure returns (uint8) {
        return uint8(type(AdminRoles).max) + 1;
    }

    /**
     * @dev getAdminPermissions is used to get all permissions on address
     *
     * @param whitelistAddress - Admin address to get permissions.
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
