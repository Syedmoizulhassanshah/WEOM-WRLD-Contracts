// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./PortBase.sol";
import "./lib/GettersAndDerivers.sol";

//import "hardhat/console.sol";

contract PortValidation is  GettersAndDerivers{
    
    constructor(address conduitController) GettersAndDerivers(conduitController) {}

    // function __init_PortValidation(address conduitController) internal  {
    //     __init_GetterAndDerivers(conduitController);
    // }

    function _assertNonZeroAmount(uint256 amount) internal pure {
        // Revert if the supplied amount is equal to zero.
        if (amount == 0) {
            revert MissingItemAmount();
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

    function _assertValidBasicOrderParameters() internal view {
        // Declare a boolean designating basic order parameter offset validity.
        bool validOffsets;

        uint p1;
        uint p2;
        uint p3;
        uint p4;

        console.log("inside _assertValidBasicOrderParameters");

        assembly {
            validOffsets := and(
                // Order parameters at calldata 0x04 must have offset of 0x20.
                eq(
                    calldataload(BasicOrder_parameters_cdPtr),
                    BasicOrder_parameters_ptr
                ),
                // Additional recipients at cd 0x224 must have offset of 0x240.
                eq(
                    calldataload(BasicOrder_additionalRecipients_head_cdPtr),
                    BasicOrder_additionalRecipients_head_ptr
                )
            )


            p1 := calldataload(BasicOrder_signature_cdPtr)
            p2 := BasicOrder_signature_ptr

            p3 := calldataload(BasicOrder_additionalRecipients_length_cdPtr)
            p4 := AdditionalRecipients_size


            validOffsets := and(
                validOffsets,
                eq(
                    // Load signature offset from calldata 0x244.
                    calldataload(BasicOrder_signature_cdPtr),
                    // Derive expected offset as start of recipients + len * 64.
                    add(
                        BasicOrder_signature_ptr,
                        mul(
                            // Additional recipients length at calldata 0x264.
                            calldataload(
                                BasicOrder_additionalRecipients_length_cdPtr
                            ),
                            // Each additional recipient has a length of 0x40.
                            AdditionalRecipients_size
                        )
                    )
                )
            )

            validOffsets := and(
                validOffsets,
                lt(
                    // BasicOrderType parameter at calldata offset 0x124.
                    calldataload(BasicOrder_basicOrderType_cdPtr),
                    // Value should be less than 24.
                    BasicOrder_basicOrderType_range
                )
            )
        }


        console.log("p1",p1);
        console.log("p2",p2);
        console.log("p3 is :",p3);
        console.log("p4 is :",p4);

        console.log("validOffsets",validOffsets);

        // Revert with an error if basic order parameter offsets are invalid.
        if (!validOffsets) {
            revert InvalidBasicOrderParameterEncoding();
        }
    }

    

}

