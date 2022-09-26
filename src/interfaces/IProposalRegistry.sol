// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "./Proposal.sol";

interface IProposalRegistry {
    function vote(uint256 propId, bool decision, bytes calldata data) external;
    function createProposal(Proposal proposal) external returns (uint256 propId);
    function execute(uint256 propId) external;
    function voteResult(uint256 propId) external;
    function proposalExpired(uint256 propId) external;
    
    function getProposal(uint256 propId) external view returns (Proposal memory proposal);
    function votingToken() external view returns(IGovernance);
}
