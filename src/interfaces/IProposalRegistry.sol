// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

struct Transaction {
    address to;
    uint value;
    bytes data;
}

interface IProposalRegistry {
    function vote(uint256 propId, bool decision, bytes calldata data) external;
    function createProposal(uint256 propId, Transaction[] calldata pipeline) external;
    function execute(uint256 propId) external;
}
