// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "./Transaction.sol";

interface IRouter {
    function vote(
        bool decision,  // Vote decision
        uint256 routerTransactionId,  // id of Transaction related to current IRouter in pipeline
        bytes calldata data,
        bytes calldata voteData  // Voted parameters
    ) external returns(bytes memory updatedData);  // returns the updated Transaction related to IRouter
}