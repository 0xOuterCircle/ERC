// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import {Transaction, Proposal, VoteType} from "../contracts/ProposalRegistry.sol";
import "./IGovernance.sol";
import "openzeppelin/utils/introspection/IERC165.sol";

interface IProposalRegistry is IERC165 {
    function vote(uint256 propId, bool decision, bytes calldata data) external;
    function createProposal(Proposal memory proposal) external returns (uint256 propId);
    function execute(uint256 propId) external;
    function voteResult(uint256 propId) external view returns(VoteType);
    function proposalExpired(uint256 propId) external view returns(bool);
    
    function getProposal(uint256 propId) external view returns (Proposal memory proposal);
    function governance() external view returns(IGovernance);
}
