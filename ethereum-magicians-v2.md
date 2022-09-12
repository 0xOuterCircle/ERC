```solidity
struct Action {
    IDdApp app;
    string actionSignature;
    string[] paramsInternal;
    string[] paramsPublic;
    string[] labels;
}

struct Proposal {
    uint256     createdAt;
    bool        ProposalCompleted;
    uint256[2]  quorum;
    uint256     expiration;
    uint256     delay;
    Action[]    actions;
}
```

```solidity
interface IDdApp {
    function actionsTotal() external view returns (uint256);
    
    function actionData(
        uint256 actionId
    ) external view returns (
        string memory actionSignature,  // "sell(uint256)"
        string[] memory paramsInternal, // []
        string[] memory paramsPublic,   // ["uint256"]
        string[] memory labels          // ["Resale Price"]
    );
    
    function voteFor(
        uint256 actionId,
        uint256 votedVp,
        uint256 totalVp,
        bytes[] memory paramsInternal,
        bytes[] memory paramsPublic,
        bytes[] memory paramsVoted
    ) external returns (string[] memory updParamsInternal, string[] memory updParamsPublic);
}
```

```solidity
interface IProposalRegistry {
    
    //// Getters ////
    
    function totalProposalsFor(IGovernance governance) external returns (uint256);
    function getProposal(IGovernance governance, uint256 proposalId) external view returns (Proposal memory proposal);

    //// Setters ////
    // msg.sender should be IGovernance
    
    function registerProposal(Proposal memory proposal) external returns (uint256 id);
    function executeProposal(uint256 proposalId) external returns (bool success);
    function vote(uint256 proposalId, uint256 vp) external;
}
```

```solidity

struct GovernanceSettings {
    uint256 proposalCreationThreshold;
    uint256 minQuorum;
    uint256 proposalExpiration;
    uint256 proposalDelay;
    IProposalRegistry[] trustedRegistries; // TODO Move to global scope
}

interface IGovernance {
    
    //// Getters ////
    
    function parent(uint256 id_) external view returns (address vpProvider, uint256 id);
    function votingPower(address member, uint256 id) external view returns (uint256);
    function totalVotingPower(uint256 id) external view returns (uint256);
    function governanceSettings(uint256 id) external view returns (GovernanceSettings memory);
    function totalTrustedRegistries() external view returns (uint256);
    function trustedRegistry(uint256 registryId) external view returns (IProposalRegistry);

    //// Managing Settings ////
    
    // TODO This is ddApp action
    function updateSettings(GovernanceSettings memory) external;

    //// Managing Voting Power ////
    function stakeFor(address staker, address delegatee, uint256 amount) external;
    function unstakeFor(address staker, address receiver, uint256 amount) external;
    
    //// Proposals management ////

    function registerProposal(uint256 registryId, Proposal memory proposal) external returns (uint256 id);
    function executeProposal(uint256 registryId, uint256 proposalId) external returns (bool success);
    function vote(uint256 registryId, uint256 proposalId, uint256 vp) external;
    
    //// Hooks ////
    // Must be run by IProposalRegistry
    
    function proposalCompleted(uint256 proposalId) external;
}
```