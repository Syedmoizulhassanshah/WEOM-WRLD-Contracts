// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract PortConstant {

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

    error TokenBlackListed();  
    error CallerCanNotCall();
    error AddressMismatched();

    // for erc 1155
    error OrderCriteriaResolverOutOfRange();
    error OfferCriteriaResolverOutOfRange();
    error ConsiderationCriteriaResolverOutOfRange();
    error CriteriaNotEnabledForItem();
    error InvalidProof();
    error BadFraction();
    error PartialFillsNotEnabledForOrder();
    error UnresolvedConsiderationCriteria();
    error UnresolvedOfferCriteria();
    error InvalidNativeOfferItem();

    error InvalidCallToConduit(address conduit);
    error InvalidConduit(bytes32 conduitKey, address conduit);

    error InvalidRestrictedOrder(bytes32 orderHash);

  //  error InvalidERC721TransferAmount();
    


    uint256 constant FreeMemoryPointerSlot = 0x40;
    uint256 constant MaskOverByteTwelve = (0x0000000000000000000000ff0000000000000000000000000000000000000000);
    uint256 constant OneWord = 0x20;
    uint256 constant TwoWords = 0x40;
    uint256 constant AlmostOneWord = 0x1f;
    uint256 constant CostPerWord = 3;
    uint256 constant MemoryExpansionCoefficient = 0x200; // 512
    uint256 constant ExtraGasBuffer = 0x20;
    uint256 constant Create2AddressDerivation_ptr = 0x0b;
    uint256 constant Create2AddressDerivation_length = 0x55;
    uint256 constant MaskOverLastTwentyBytes = (0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff);

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
    uint256 constant OrderFulfilled_consideration_length_baseOffset = 0x2a0;
    uint256 constant FourWords = 0x80;
    uint256 constant BasicOrder_additionalRecipients_length_cdPtr = 0x284; // 0x264
    uint256 constant BasicOrder_additionalRecipients_head_cdPtr = 0x224; 
    uint256 constant BasicOrder_additionalRecipients_head_ptr = 0x260; // 0x240
    uint256 constant BasicOrder_totalOriginalAdditionalRecipients_cdPtr = 0x204;
    uint256 constant BasicOrder_additionalRecipients_data_cdPtr = 0x304;    // 0x284
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
    uint256 constant Ecrecover_precompile = 1;
    uint256 constant Ecrecover_args_size = 0x80;
    uint256 constant EIP1271_isValidSignature_digest_negativeOffset = 0x40;
    uint256 constant EIP1271_isValidSignature_selector_negativeOffset = 0x44;
    uint256 constant EIP1271_isValidSignature_calldata_baseLength = 0x64;
    uint256 constant InvalidSignature_error_signature = (0x8baa579f00000000000000000000000000000000000000000000000000000000);
    uint256 constant InvalidSignature_error_length = 0x04;
    uint256 constant BadSignatureV_error_signature = (0x1f003d0a00000000000000000000000000000000000000000000000000000000);
    uint256 constant BadSignatureV_error_length = 0x24;
    uint256 constant InvalidSigner_error_signature = (0x815e1d6400000000000000000000000000000000000000000000000000000000);
    uint256 constant InvalidSigner_error_length = 0x04;

    uint256 constant BasicOrder_parameters_cdPtr = 0x04;
    uint256 constant BasicOrder_parameters_ptr = 0x20; 
    uint256 constant BasicOrder_signature_cdPtr = 0x244;
    uint256 constant BasicOrder_signature_ptr = 0x280;  //0x260
    uint256 constant BasicOrder_basicOrderType_range = 0x18; // 24 values

    bytes32 constant EIP2098_allButHighestBitMask = (0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    bytes32 constant EIP1271_isValidSignature_selector = (0x1626ba7e00000000000000000000000000000000000000000000000000000000);
    bytes32 constant ECDSA_twentySeventhAndTwentyEighthBytesSet = (0x0000000000000000000000000000000000000000000000000000000101000000);

    uint256 constant OneConduitExecute_size = 0x104;
    uint256 constant Conduit_execute_transferAmount_ptr = 0xe4;
    uint256 constant Conduit_execute_signature = (0x4ce34aa200000000000000000000000000000000000000000000000000000000);
    uint256 constant Conduit_execute_ConduitTransfer_offset_ptr = 0x04;
    uint256 constant Conduit_execute_ConduitTransfer_ptr = 0x20;
    uint256 constant Conduit_execute_ConduitTransfer_length_ptr = 0x24;
    uint256 constant Conduit_execute_ConduitTransfer_length = 0x01;
    uint256 constant Conduit_execute_transferItemType_ptr = 0x44;
    uint256 constant Conduit_execute_transferToken_ptr = 0x64;
    uint256 constant Conduit_execute_transferFrom_ptr = 0x84;
    uint256 constant Conduit_execute_transferTo_ptr = 0xa4;
    uint256 constant Conduit_execute_transferIdentifier_ptr = 0xc4;

    

// auction parameters

    uint256 constant BasicOrder_offererConduit_cdPtr = 0x1c4;
    uint256 constant BasicOrder_fulfillerConduit_cdPtr = 0x1e4;
    
    //error UnusedItemParameters();


    // for erc 1155

    uint256 constant Panic_error_offset = 0x04;
    uint256 constant AccumulatorDisarmed = 0x20;
    uint256 constant ConsiderationItem_recipient_offset = 0xa0;
    uint256 constant AccumulatorArmed = 0x40;
    uint256 constant MaxUint120 = 0xffffffffffffffffffffffffffffff;
    uint256 constant Panic_error_signature = (0x4e487b7100000000000000000000000000000000000000000000000000000000);
    uint256 constant Panic_arithmetic = 0x11;
    uint256 constant Panic_error_length = 0x24;
    uint256 constant InexactFraction_error_signature = (0xc63cf08900000000000000000000000000000000000000000000000000000000);
    uint256 constant InexactFraction_error_len = 0x04;
    uint256 constant Accumulator_conduitKey_ptr = 0x20;
    uint256 constant Accumulator_array_offset_ptr = 0x44;
    uint256 constant Accumulator_array_length_ptr = 0x64;
    uint256 constant Conduit_transferItem_size = 0xc0;





    uint256 constant Accumulator_array_offset = 0x20;
    uint256 constant ERC1155_safeTransferFrom_data_length_offset = 0xa0;
    uint256 constant Accumulator_selector_ptr = 0x40;
    uint256 constant Accumulator_itemSizeOffsetDifference = 0x3c;
    uint256 constant Conduit_transferItem_token_ptr = 0x20;
    uint256 constant Conduit_transferItem_from_ptr = 0x40;
    uint256 constant Conduit_transferItem_to_ptr = 0x60;
    uint256 constant Conduit_transferItem_identifier_ptr = 0x80;
    uint256 constant Conduit_transferItem_amount_ptr = 0xa0;
    uint256 constant NoContract_error_sig_ptr = 0x0;
    uint256 constant NoContract_error_signature = (0x5f15d67200000000000000000000000000000000000000000000000000000000);
    uint256 constant NoContract_error_token_ptr = 0x4;
    uint256 constant NoContract_error_length = 0x24; // 4 + 32 == 36
    uint256 constant Slot0x80 = 0x80;
    uint256 constant Slot0xA0 = 0xa0;
    uint256 constant Slot0xC0 = 0xc0;
    uint256 constant ERC1155_safeTransferFrom_sig_ptr = 0x0;
    uint256 constant ERC1155_safeTransferFrom_signature = (0xf242432a00000000000000000000000000000000000000000000000000000000);
    uint256 constant ERC1155_safeTransferFrom_from_ptr = 0x04;
    uint256 constant ERC1155_safeTransferFrom_to_ptr = 0x24;
    uint256 constant ERC1155_safeTransferFrom_id_ptr = 0x44;
    uint256 constant ERC1155_safeTransferFrom_amount_ptr = 0x64;
    uint256 constant ERC1155_safeTransferFrom_data_offset_ptr = 0x84;
    uint256 constant ERC1155_safeTransferFrom_data_length_ptr = 0xa4;
    uint256 constant ERC1155_safeTransferFrom_length = 0xc4; // 4 + 32 * 6 == 196
    uint256 constant TokenTransferGenericFailure_error_sig_ptr = 0x0;
    uint256 constant TokenTransferGenericFailure_error_signature = (0xf486bc8700000000000000000000000000000000000000000000000000000000);
    uint256 constant TokenTransferGenericFailure_error_token_ptr = 0x4;
    uint256 constant TokenTransferGenericFailure_error_from_ptr = 0x24;
    uint256 constant TokenTransferGenericFailure_error_to_ptr = 0x44;
    uint256 constant TokenTransferGenericFailure_error_id_ptr = 0x64;
    uint256 constant TokenTransferGenericFailure_error_amount_ptr = 0x84;
    uint256 constant TokenTransferGenericFailure_error_length = 0xa4;



}

