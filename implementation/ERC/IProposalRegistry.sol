pragma solidity ^0.8.16;
import "./Proposal.sol";
import "./IGovernance.sol";

interface IProposalRegistry {

    //// Getters ////

    function totalProposalsFor(IGovernance governance) external returns (uint256);
    function getProposal(IGovernance governance, uint256 proposalId) external view returns (Proposal memory proposal);

    //// Setters ////
    // Must be run by IGovernance

    function registerProposal(Proposal memory proposal) external returns (uint256 id);
    function executeProposal(uint256 proposalId) external returns (bool success);
    function vote(uint256 proposalId, uint256 vp) external;
    function revokeVote(uint256 proposalId, uint256 optionId) external;
}
