pragma solidity ^0.8.16;
import "./IProposalRegistry.sol";
import "./Proposal.sol";

struct GovernanceSettings {
    uint256 proposalCreationThreshold;
    uint256 minQuorum;
    uint256 proposalExpiration;
    uint256 proposalDelay;
    IProposalRegistry[] trustedRegistries;
}

interface IGovernance {

    //// Getters ////

    function parent(uint256 id) external view returns (address vpProvider, uint256 id_);
    function votingPower(address member, uint256 id) external view returns (uint256);
    function totalVotingPower(uint256 id) external view returns (uint256);
    function governanceSettings() external view returns (GovernanceSettings memory);
    function totalTrustedRegistries() external view returns (uint256);
    function trustedRegistry(uint256 registryId) external view returns (IProposalRegistry);

    //// Managing Settings ////

    function updateSettings(GovernanceSettings memory) external;

    //// Managing Voting Power ////
    function stakeFor(address staker, address delegatee, uint256 amount, uint256 id, bytes calldata data) external;
    function unstakeFor(address staker, address delegatee, uint256 amount, uint256 id, bytes calldata data) external;

    //// Proposals management ////

    function registerProposal(uint256 registryId, Proposal memory proposal, uint256 id) external returns (uint256 id_);
    function executeProposal(uint256 registryId, uint256 proposalId) external returns (bool success);
    function vote(uint256 registryId, uint256 proposalId, uint256 vp) external;

    //// Hooks ////
    // Must be run by IProposalRegistry

    function proposalCompleted(uint256 proposalId) external;
}
