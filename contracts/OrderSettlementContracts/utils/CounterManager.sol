// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import "hardhat/console.sol";


contract CounterManager is  ReentrancyGuard {

    // Emit an event whenever a counter for a given offerer is incremented.

    event CounterIncremented(uint256 newCounter, address indexed offerer);

    // Only orders signed using an offerer's current counter are fulfillable.
    
    mapping(address => uint256) private _counters;

    /**
     * @dev Internal function to cancel all orders from a given offerer with a
     *      given zone in bulk by incrementing a counter. Note that only the
     *      offerer may increment the counter.
     *
     * @return newCounter The new counter.
     */
    function _incrementCounter() internal returns (uint256 newCounter) {

        console.log("In CounterManager.sol , _incrementCounter()");

        // Ensure that the reentrancy guard is not currently set.
        _assertNonReentrant();

        // Skip overflow check as counter cannot be incremented that far.
        unchecked {
            // Increment current counter for the supplied offerer.
            newCounter = ++_counters[msg.sender];
        }

        // Emit an event containing the new counter.
        emit CounterIncremented(newCounter, msg.sender);
    }

    /**
     * @dev Internal view function to retrieve the current counter for a given
     *      offerer.
     *
     * @param offerer The offerer in question.
     *
     * @return currentCounter The current counter.
     */
    function _getCounter(address offerer)
        internal
        view
        returns (uint256 currentCounter)
    {
        console.log("In CounterManager.sol , _getCounter()");

        // Return the counter for the supplied offerer.
        currentCounter = _counters[offerer];
    }
}
