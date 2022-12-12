// SPDX-License-Identifier: MIT
pragma solidity 0.8.15; 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ManagerRoles is Ownable
{
    enum AdminRoles {
        NONE,
        MANAGER
    }

    error Invalid(string error);
    error AlreadyExists(string error);

    mapping(address => AdminRoles) public adminWhitelistedAddresses;

    event AddedWhitelistAdmin(address whitelistedAddress, address addedBy);
    event RemovedWhitelistAdmin(address whitelistedAddress, address removedBy);

    function _isWhitelistedAdmin(AdminRoles requiredRole) internal view {
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
            revert Invalid("Not whitelist address");
        }
    } 

    function _checkWhitelistedAdmin(AdminRoles requiredRole) public view returns (bool){
        if (adminWhitelistedAddresses[msg.sender] != requiredRole) {
           return false;
        }
        return true;
    }    

    function addWhitelistAdmin(
    address whitelistAddress,
    AdminRoles allowPermission
    ) external onlyOwner {
        if (adminWhitelistedAddresses[whitelistAddress] != AdminRoles.NONE) {
            revert AlreadyExists("Whitelisted address");
        }
        adminWhitelistedAddresses[whitelistAddress] = allowPermission;

        emit AddedWhitelistAdmin(whitelistAddress, msg.sender);
    }

    function removeWhitelistAdmin(address whitelistAddress) external onlyOwner {
        if (adminWhitelistedAddresses[whitelistAddress] == AdminRoles.NONE) {
            revert Invalid("Not whitelist address");
        }

        adminWhitelistedAddresses[whitelistAddress] = AdminRoles.NONE;

        emit RemovedWhitelistAdmin(whitelistAddress, msg.sender);
    }    

}