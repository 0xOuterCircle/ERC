// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import {Transaction} from "../contracts/ProposalRegistry.sol";

interface IRouter {
    function vote(
        bool decision,  // Vote decision
        uint256 routerTransactionId,  // id of Transaction related to current IRouter in pipeline
        bytes calldata data,  // Call parameters before the vote
        bytes calldata voteData  // Voted parameters
    ) external returns(bytes memory updatedData);  // returns the updated Transaction related to IRouter

    function execute(
        uint256 routerTransactionId,
        bytes calldata data
    ) external;

    function totalTransactions() external view returns (uint256 transactionsAmount);
    function getTransaction() external view returns (
        string memory name,
        string memory description,
        string memory dynamicParamsTypes, // ["uint256", "string", ...]
        string memory dynamicParamsLabels, // ["Label 1", "Label 2", ...] is used for interfaces
        Transaction memory initialTransaction
    );
}