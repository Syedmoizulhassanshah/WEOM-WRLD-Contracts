// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./PortBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "./lib/GettersAndDerivers.sol";

contract PortValidation is  GettersAndDerivers{
    constructor(address conduitController) GettersAndDerivers(conduitController) {}

    function _assertNonZeroAmount(uint256 amount) internal pure {
        // Revert if the supplied amount is equal to zero.
        if (amount == 0) {
            revert MissingItemAmount();
        }
    }

    function _assertConsiderationToken(address tokenAddress) internal pure {
        if (tokenAddress != address(0)) {
            revert InvalidConsiderationToken(tokenAddress);
        }
    }

    function _assertconsiderationIdentifier(uint256 amount) internal pure {
        if (amount != 0) {
            revert InvalidConsiderationIdentifier(amount);
        }
    }

    function _assertCheckOfferer(address offerer) internal pure {
        if (offerer == address(0)) {
            revert InvalidOffererAddress(offerer);
        }
    }

    function _assertCheckZone(address zone) internal pure {
        if (zone == address(0)) {
            revert InvalidZoneOrEmpty(zone);
        }
    }

    function _assertChecktoken(address token) internal pure {
        if (token == address(0)) {
            revert InvalidToken(token);
        }
    }

    function _assertCheckBasicOrderType(uint256 orderType) internal pure {
        if (orderType != 2) {
            revert InvalidOrderType(orderType);
        }
    }

    function _assertcheckZoneHash(bytes32 zoneHash) internal pure {
        if (zoneHash != bytes32(0)) {
            revert InvalidZonehash();
        }
    }

    function _assertCheckSalt(uint256 salt) internal pure {
        if (salt == 0) {
            revert InvalidSalt();
        }
    }

    function _assertCheckConduitKey(bytes32 offererConduitKey , bytes32 fulfillerConduitKey) internal pure {
        if (offererConduitKey & fulfillerConduitKey == bytes32(0)) {
            revert InvalidConduitKey();
        }
    }

    function _assertConsiderationLengthIsNotLessThanOriginalConsiderationLength(
        uint256 suppliedConsiderationItemTotal,
        uint256 originalConsiderationItemTotal
    ) internal pure {
        // Ensure supplied consideration array length is not less than original.
        if (suppliedConsiderationItemTotal < originalConsiderationItemTotal) {
            revert MissingOriginalConsiderationItems();
        }
    }

    function _verifyTime(
        uint256 startTime,
        uint256 endTime,
        bool revertOnInvalid
    ) internal view returns (bool valid) {
        // Revert if order's timespan hasn't started yet or has already ended.
        if (startTime > block.timestamp || endTime <= block.timestamp) {
            // Only revert if revertOnInvalid has been supplied as true.
            if (revertOnInvalid) {
                revert InvalidTime();
            }

            // Return false as the order is invalid.
            return false;
        }

        // Return true as the order time is valid.
        valid = true;
    }


    
    
}

