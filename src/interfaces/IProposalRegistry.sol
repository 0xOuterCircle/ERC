// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Transaction, Proposal, VoteType} from "contracts/ProposalRegistry.sol";
import "./IGovernance.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IProposalRegistry is IERC165 {
    function vote(uint256 propId, VoteType decision, bytes[] calldata data) external;
    function createProposal(Transaction[] calldata _pipeline) external;
    function execute(uint256 propId) external;
    function castVeto(uint256 propId) external;
    function approveChildRegistry(IProposalRegistry registry) external;
    function removeChildRegistry(IProposalRegistry registry) external;
    function changeProposalExpirationTime(uint256 newTime) external;
    function changeGovernance(IGovernance newGovernance) external;
    function changeParentRegistry(IProposalRegistry _newRegistry) external;

    function voteResult(uint256 propId) external view returns (bool);
    function proposalExpired(uint256 propId) external view returns (bool);
    function getProposal(uint256 propId) external view returns (Proposal memory);
    function governance() external view returns (IGovernance);
    function proposalExpirationTime() external view returns (uint256);
    function parentRegistry() external view returns (IProposalRegistry);
}
