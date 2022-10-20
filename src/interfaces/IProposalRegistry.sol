// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Transaction, Proposal, VoteType} from "contracts/ProposalRegistry.sol";
import "./IGovernance.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IProposalRegistry is IERC165 {
    function vote(uint256 propId, VoteType decision, bytes[] calldata data) external;
    function createProposal(uint256 _propId, Transaction[] calldata _pipeline) external;
    function voteResult(uint256 propId) external view returns (bool);
    function execute(uint256 propId) external;
    function proposalExpired(uint256 propId) external view returns (bool);

    function getProposal(uint256 propId) external view returns (Proposal memory);
    function governance() external view returns (IGovernance);
    function proposalExpirationTime() external view returns (uint256);
}
