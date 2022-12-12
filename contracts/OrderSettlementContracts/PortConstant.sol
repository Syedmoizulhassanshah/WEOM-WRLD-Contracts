// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract PortConstant {
    uint256 constant FreeMemoryPointerSlot = 0x40;
    uint256 constant MaskOverByteTwelve = (
        0x0000000000000000000000ff0000000000000000000000000000000000000000
    );
    uint256 constant OneWord = 0x20;
    uint256 constant TwoWords = 0x40;
    uint256 constant AlmostOneWord = 0x1f;
    uint256 constant CostPerWord = 3;
    uint256 constant MemoryExpansionCoefficient = 0x200; // 512
    uint256 constant ExtraGasBuffer = 0x20;
    uint256 constant Create2AddressDerivation_ptr = 0x0b;
    uint256 constant Create2AddressDerivation_length = 0x55;
    uint256 constant MaskOverLastTwentyBytes = (
        0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff
    );


    uint256 constant BasicOrder_basicOrderType_cdPtr = 0x124;

    uint256 constant Common_token_offset = 0x20;
    uint256 constant ReceivedItem_amount_offset = 0x60;
    uint256 constant ReceivedItem_recipient_offset = 0x80;
    uint256 constant OrderFulfilled_fulfiller_offset = 0x20;
    uint256 constant OrderFulfilled_offer_head_offset = 0x40;
    uint256 constant OrderFulfilled_offer_body_offset = 0x80;
    uint256 constant OrderFulfilled_consideration_head_offset = 0x60;
    uint256 constant OrderFulfilled_consideration_body_offset = 0x120;
    uint256 constant BasicOrder_considerationToken_cdPtr = 0x24;
    uint256 constant BasicOrder_common_params_size = 0xa0;
    uint256 constant BasicOrder_considerationItem_typeHash_ptr = 0x80; // memoryPtr
    uint256 constant BasicOrder_considerationItem_itemType_ptr = 0xa0;
    uint256 constant BasicOrder_considerationItem_token_ptr = 0xc0;
    uint256 constant BasicOrder_considerationItem_identifier_ptr = 0xe0;
    uint256 constant BasicOrder_considerationItem_startAmount_ptr = 0x100;
    uint256 constant BasicOrder_considerationItem_endAmount_ptr = 0x120;
    uint256 constant ThreeWords = 0x60;
    uint256 constant BasicOrder_considerationAmount_cdPtr = 0x64;
    uint256 constant BasicOrder_considerationHashesArray_ptr = 0x160;
    uint256 constant EIP712_ConsiderationItem_size = 0xe0;
    uint256 constant BasicOrder_additionalRecipients_length_cdPtr = 0x264;
    uint256 constant OrderFulfilled_consideration_length_baseOffset = 0x2a0;
    uint256 constant FourWords = 0x80;
    uint256 constant BasicOrder_totalOriginalAdditionalRecipients_cdPtr = 0x204;
    uint256 constant BasicOrder_additionalRecipients_data_cdPtr = 0x284;
    uint256 constant AdditionalRecipients_size = 0x40;
    uint256 constant ReceivedItem_size = 0xa0;
    uint256 constant receivedItemsHash_ptr = 0x60;
    uint256 constant DefaultFreeMemoryPointer = 0x80;
    uint256 constant BasicOrder_offerItem_typeHash_ptr = DefaultFreeMemoryPointer;
    uint256 constant BasicOrder_offerItem_itemType_ptr = 0xa0;
    uint256 constant BasicOrder_offerItem_token_ptr = 0xc0;
    uint256 constant BasicOrder_offerToken_cdPtr = 0xc4;
    uint256 constant BasicOrder_offerItem_endAmount_ptr = 0x120;
    uint256 constant BasicOrder_offerAmount_cdPtr = 0x104;
    uint256 constant EIP712_OfferItem_size = 0xc0;
    uint256 constant BasicOrder_order_offerHashes_ptr = 0xe0;
    uint256 constant OrderFulfilled_offer_length_baseOffset = 0x200;
    uint256 constant BasicOrder_offerer_cdPtr = 0x84;
    uint256 constant BasicOrder_order_typeHash_ptr = 0x80;
    uint256 constant BasicOrder_order_offerer_ptr = 0xa0;
    uint256 constant BasicOrder_order_considerationHashes_ptr = 0x100;
    uint256 constant BasicOrder_order_orderType_ptr = 0x120;
    uint256 constant BasicOrder_order_startTime_ptr = 0x140;
    uint256 constant BasicOrder_startTime_cdPtr = 0x144;
    uint256 constant FiveWords = 0xa0;
    uint256 constant BasicOrder_order_counter_ptr = 0x1e0;
    uint256 constant EIP712_Order_size = 0x180;
    uint256 constant OrderFulfilled_baseOffset = 0x180;
    uint256 constant OrderFulfilled_baseSize = 0x1e0;
    uint256 constant OrderFulfilled_selector = (0x9d9af8e38d66c62e2c12f0225249fd9d721c54b83f48d9352c97c6cacdcb6f31);
    uint256 constant BasicOrder_zone_cdPtr = 0xa4;
    uint256 constant ZeroSlot = 0x60;

    uint256 constant OrderParameters_offer_head_offset = 0x40;
    uint256 constant OrderParameters_consideration_head_offset = 0x60;
    uint256 constant OrderParameters_counter_offset = 0x140;

    uint256 constant EIP712_DomainSeparator_offset = 0x02;
    uint256 constant EIP712_OrderHash_offset = 0x22;
    uint256 constant EIP_712_PREFIX = (0x1901000000000000000000000000000000000000000000000000000000000000);
    uint256 constant EIP712_DigestPayload_size = 0x42;

    uint256 constant ECDSA_signature_s_offset = 0x40;
    uint256 constant ECDSA_signature_v_offset = 0x60;
    uint256 constant EIP1271_isValidSignature_signature_head_offset = 0x40;
    uint256 constant BadSignatureV_error_offset = 0x04;
    uint256 constant BadContractSignature_error_signature = (0x4f7fb80d00000000000000000000000000000000000000000000000000000000);
    uint256 constant BadContractSignature_error_length = 0x04;

    uint256 constant ECDSA_MaxLength = 65;
    uint256 constant MaxUint8 = 0xff;
    uint256 constant Signature_lower_v = 27;
    bytes32 constant EIP2098_allButHighestBitMask = (0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    uint256 constant Ecrecover_precompile = 1;
    uint256 constant Ecrecover_args_size = 0x80;
    uint256 constant EIP1271_isValidSignature_digest_negativeOffset = 0x40;
    uint256 constant EIP1271_isValidSignature_selector_negativeOffset = 0x44;
    bytes32 constant EIP1271_isValidSignature_selector = (0x1626ba7e00000000000000000000000000000000000000000000000000000000);
    uint256 constant EIP1271_isValidSignature_calldata_baseLength = 0x64;
    uint256 constant InvalidSignature_error_signature = (0x8baa579f00000000000000000000000000000000000000000000000000000000);
    uint256 constant InvalidSignature_error_length = 0x04;
    bytes32 constant ECDSA_twentySeventhAndTwentyEighthBytesSet = (0x0000000000000000000000000000000000000000000000000000000101000000);
    uint256 constant BadSignatureV_error_signature = (0x1f003d0a00000000000000000000000000000000000000000000000000000000);
    uint256 constant BadSignatureV_error_length = 0x24;
    uint256 constant InvalidSigner_error_signature = (0x815e1d6400000000000000000000000000000000000000000000000000000000);
    uint256 constant InvalidSigner_error_length = 0x04;



    error InsufficientEtherSupplied();
    error MissingItemAmount();
    error EtherTransferGenericFailure(address to, uint256 amount);
    error InvalidConsiderationToken(address token);
    error InvalidConsiderationIdentifier(uint considerationIdentifier);
    error InvalidOffererAddress(address offerer);
    error InvalidZoneOrEmpty(address zone);
    error InvalidToken(address token);
    error InvalidOrderType(uint OrderType);
    error InvalidTime();
    error InvalidZonehash();
    error InvalidSalt();
    error InvalidConduitKey();
    error MissingOriginalConsiderationItems();


    error InvalidMsgValue(uint value);
    error InvalidCanceller();
    error OrderIsCancelled(bytes32 orderHash);
    error OrderPartiallyFilled(bytes32 orderHash);
    error OrderAlreadyFilled(bytes32 orderHash);






       error InvalidBasicOrderParameterEncoding();

    uint256 constant BasicOrder_parameters_cdPtr = 0x04;
    uint256 constant BasicOrder_parameters_ptr = 0x20;
    uint256 constant BasicOrder_additionalRecipients_head_cdPtr = 0x224;
    uint256 constant BasicOrder_additionalRecipients_head_ptr = 0x240;
    uint256 constant BasicOrder_signature_cdPtr = 0x244;
    uint256 constant BasicOrder_signature_ptr = 0x260;
    uint256 constant BasicOrder_basicOrderType_range = 0x18; // 24 values
}

