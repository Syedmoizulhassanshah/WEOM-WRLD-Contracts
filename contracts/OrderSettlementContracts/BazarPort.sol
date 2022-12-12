// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./PortSettlement.sol";

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BazarPort is PortSettlement  {

    // constructor() {
    //     _disableInitializers();
    // }

    constructor(address conduitController) PortSettlement(conduitController) 
    {}
 
    // function initialize(address conduitController) initializer public {
    //     __Ownable_init();
    //     __UUPSUpgradeable_init();
    //     __init_PortSettlement(conduitController);
    // }

    // function _authorizeUpgrade(address newImplementation)
    //     internal
    //     onlyOwner
    //     override
    // {}

    // function newFunction () public pure returns (bool)
    // {
    //     return true;
    // }

    function fulfillBasicOrder(BasicOrderParameters calldata parameters)
        external
        payable
        returns (bool fulfilled)
    {
        if (_checkTokenBlackList(parameters.offerToken)) 
        {
            revert TokenBlackListed();
        }

        // manager can also mint if allowUser is true


        if (!allowUsersToFullfilOrder && _checkWhitelistedAdmin(AdminRoles.MANAGER)){

            console.log("1st");
            if (parameters.basicOrderType == BasicOrderType.ETH_TO_ERC721_FULL_RESTRICTED || parameters.basicOrderType == BasicOrderType.ETH_TO_ERC1155_PARTIAL_OPEN)
            {
                revert CallerCanNotCall();
            }

            fulfilled = _validateAndFulfillBasicOrder(parameters);

        } else if(allowUsersToFullfilOrder && msg.sender == parameters.fulfiller || _checkWhitelistedAdmin(AdminRoles.MANAGER)){

            console.log("2nd");

            if (parameters.basicOrderType == BasicOrderType.ETH_TO_ERC721_FULL_RESTRICTED 
                && msg.sender != parameters.fulfiller)
            {
                revert CallerCanNotCall();
            }

            if (parameters.basicOrderType == BasicOrderType.ETH_TO_ERC1155_PARTIAL_OPEN
                && msg.sender != parameters.fulfiller)
            {
                revert CallerCanNotCall();
            }

            fulfilled = _validateAndFulfillBasicOrder(parameters);

        } else {
            revert AddressMismatched();
        }
    }

    function fulfillOrder(Order calldata order, bytes32 fulfillerConduitKey,address recipient,ExecutionType executionType)
        external
        payable
        returns (bool fulfilled)
    {
        if (_checkTokenBlackList(order.parameters.offer[0].token)) 
        {
            revert TokenBlackListed();
        }

        if (!allowUsersToFullfilOrder && _checkWhitelistedAdmin(AdminRoles.MANAGER)){

            console.log("1st");

            if (executionType == ExecutionType.ETH || executionType == ExecutionType.ETH)
                {
                    revert CallerCanNotCall();
                }

            // Convert order to "advanced" order, then validate and fulfill it.
            fulfilled = _validateAndFulfillAdvancedOrder(
                _convertOrderToAdvanced(order),
                new CriteriaResolver[](0), // No criteria resolvers supplied.
                fulfillerConduitKey,
                recipient
            );
            
        } else if(allowUsersToFullfilOrder && msg.sender == recipient || _checkWhitelistedAdmin(AdminRoles.MANAGER)){

            console.log("2nd");

            if (executionType == ExecutionType.ETH && msg.sender != recipient)
                {
                    revert CallerCanNotCall();
                }

            // Convert order to "advanced" order, then validate and fulfill it.
            fulfilled = _validateAndFulfillAdvancedOrder(
                _convertOrderToAdvanced(order),
                new CriteriaResolver[](0), // No criteria resolvers supplied.
                fulfillerConduitKey,
                recipient
            );

        } else {
            revert AddressMismatched();
        }
    
    }

    function fulfillAdvancedOrder(
        AdvancedOrder calldata advancedOrder,
        CriteriaResolver[] calldata criteriaResolvers,
        bytes32 fulfillerConduitKey,
        address recipient,
        ExecutionType executionType
    ) external payable  returns (bool fulfilled) {

        if (_checkTokenBlackList(advancedOrder.parameters.offer[0].token)) 
        {
            revert TokenBlackListed();
        }

        if (!allowUsersToFullfilOrder && _checkWhitelistedAdmin(AdminRoles.MANAGER)){

            if (executionType == ExecutionType.ETH)
                {
                    revert CallerCanNotCall();
                }

            console.log("1st");

            // Validate and fulfill the order.
            fulfilled = _validateAndFulfillAdvancedOrder(
                advancedOrder,
                criteriaResolvers,
                fulfillerConduitKey,
                recipient == address(0) ? msg.sender : recipient
            );
            
        } else if(allowUsersToFullfilOrder && msg.sender == recipient || _checkWhitelistedAdmin(AdminRoles.MANAGER)){

            console.log("2nd");

            if (executionType == ExecutionType.ETH && msg.sender != recipient)
                {
                    revert CallerCanNotCall();
                }

            // Validate and fulfill the order.
            fulfilled = _validateAndFulfillAdvancedOrder(
                advancedOrder,
                criteriaResolvers,
                fulfillerConduitKey,
                recipient == address(0) ? msg.sender : recipient
            );

        } else {
            revert AddressMismatched();
        }
    }

    function cancel(OrderComponents[] calldata orders,CancelType canceltype,ExecutionType executionType)
        public 
        returns 
        (bool cancelled)
    {
        uint indexCancel = 0;

            if (_checkTokenBlackList(orders[indexCancel].offer[indexCancel].token)) 
            {
                revert TokenBlackListed();
            }
        
            if (!allowUsersToFullfilOrder && _checkWhitelistedAdmin(AdminRoles.MANAGER)){

                console.log("1st");

                if (executionType == ExecutionType.ETH || executionType == ExecutionType.ETH)
                {
                    revert CallerCanNotCall();
                }

                cancelled = _cancelOrder(orders,canceltype);

            } else if(allowUsersToFullfilOrder && msg.sender == orders[0].offerer || _checkWhitelistedAdmin(AdminRoles.MANAGER)){

                console.log("2nd");

                if (executionType == ExecutionType.ETH && msg.sender != orders[0].offerer)
                {
                    revert CallerCanNotCall();
                }

                cancelled = _cancelOrder(orders,canceltype);

            } else {
                revert AddressMismatched();
            }

            indexCancel ++ ;
    }
}
           
