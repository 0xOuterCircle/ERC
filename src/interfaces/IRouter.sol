// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

interface IRouter {
    function onVote(
        uint256 transactionId,  // id of Transaction related to current IRouter in pipeline
        bool vote,  // Vote decision: 0 -- neutral, 1 -- yes, 2 -- no
        bytes calldata voteData  // arbitrary vote data 
    ) external returns(bytes memory transData);  // returns the updated Transaction related to IRouter
}