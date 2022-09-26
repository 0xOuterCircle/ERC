// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "./Transaction.sol";

interface IProposalRegistry {
    function vote(uint256 propId, bool decision, bytes calldata data) external;
    function createProposal(Transaction[] calldata pipeline) external returns (uint256 propId);
    function execute(uint256 propId) external;
    function voteResult(uint256 propId) external;
    function proposalExpired(uint256 propId) external;
    
    function getProposal(uint256 propId) external view returns (Transaction[] memory pipeline);
    function votingToken() external view;
    function proposalExpirationTime() external view;
}
