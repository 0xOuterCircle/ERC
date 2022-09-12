# ERC standard for DAO toolings

_This document follows the forum topic at www.ethereum-magicians.org_

Proposed by Ian <br/>
www.twitter.com/k0rean_rand0m <br/>
www.linkedin.com/in/ian-sosunov <br/>
www.twitter.com/0xOuterCircle

## About me in one sentence
I'm a founder of OuterCircle - a protocol and an ecosystem which aims to unify different DAO toolings and allow any
developer to create DAO-centric apps.

## Problem

Currently, existing DAO toolings don't implement any standards which force DAOs to exist in isolated spaces of
"DAO constructors". That's also the reason why many of DAOs can't exist at all and developers creating custom
solutions for every new DAO type. The industry needs standardisation to chase mass-adoption and co-existing of
different tools made for communities as "usual" dApps do. We should aim to see "My DAOs" tab in wallets which will
allow users to see and take a part in DAOs live right from their wallets and not wander the web to not miss anything
which requires their attention.

The idea of ERC4824 brings some thoughts on it, but it describes DAOs and not the ways of DAO toolings interactions.
It needed for indexing DAOs activity and the standard proposed here doesn't conflict with ERC4824.

## Solution

First we need to formalize what DAO is. Or should we? <br/>
Any group of people who are eligible to make a decision on should some action to be performed becomes a DAO. So
the standardisation should be done in the field of these decisions and not DAOs themselves. This proposal is aimed
to describe how onchain DAO **tools** should communicate to bring complex proposals mechanisms to the field and form a
single unified space of them.

So I present the next idea of a standard which describes how tools which are working with `Proposals` should look like.

### Concepts

`DAO token` is a representation of voting power so the only question it should answer is "What's the voting power of
the passed member?" Also, it should implement mechanisms to manage user's voting power.

`Proposal` is like a transaction, but made for community-oriented apps. `Proposal` might wrap another `Proposal`
targeted to the same audience (same voting power holders) to allow a single voting for complex actions.

Any app might implement or relay on an external `Proposal Registry` which verifies that voting for `Proposal` follows
the set of rules and should be the contract which runs the actions determined by `Proposal`.

Any DAO-centric `app` should verify that a TX for any action triggered by a passed `Proposal` was sent by
app's trusted `Proposal Registry`

## Proposed standards

There are two standards which I propose - one is for Governance tokens and another is for cross-toolings communications.

### Proposal

`Proposal` are created by apps and registered in Governance registry.
All of them should store the next information:
1. What are the conditions for the `Proposal` to pass?
2. Which actions should be performed?

```solidity
// VotingRules - Describes Proposal's options and settings
struct VotingRules {
    // options - stores data about the types of options to vote
    //           might be [bool, bool] for "For/Against"
    //           or [bool, bool, uint256] for "Should we resale the NFT and for what price if yes?"
    string[] options;
    // labels - name of the options to display them on a client
    //          might be ["For", "Against"]
    //          or ["For", "Against", "NFT Resale Price"] for the mentioned above cases
    string[] labels;
    // quorum - stores the required quorum for every option in VotingPower.
    //          When the amount is reached, Proposal should pass or fail  
    //          If quorum hasn't been reached, the Proposal fails
    uint256[] quorum;
    // passOptions - stores ids of options[] items which will make the Proposal pass
    uint256[] passOptions;
    // expirationTime - the time period which should describe when the voting for the Proposal should be stopped
    // Related to Proposal creation block.timestamp
    uint256 expiration;
    // delay - the time period which should pass after the Proposal has passed to perform the action 
    uint256 delay;
}

// ProposalStatus describes basic Proposal statuses to operate
// All subtypes which might be implemented should be casted to these types for the compatibility
enum ProposalStatus{ REGISTERED, DELAYED, PASSED, FAILED }

struct Proposal {
    // createdAt - block.timestamp when the proposal has been created
    uint256 createdAt;
    // passed - the flag demonstrating that the proposal passed.
    ProposalStatus status;
    // rules - stores VotingRules described above
    VotingRules rules;
    // app - the address of an community-centric app created the Proposal.
    //       This app's action should be triggered if the Proposal will pass.
    address app;
    // action - the action of app which should be performed with Proposal pass
    //          Here function signature is used so it might look like `doSomething(bool,uint256,uint256)`
    //          That will allow client-side apps render actions in more readable way
    //          and ProposalRegistry won't depend on app implementation.
    string action;
    // data - encoded parameters to be passed to the function at app.action
    bytes data;
    // wrapperFor - an id of Proposal wrapped by this one 
    uint256 wrapperFor;
    // wrapped - if true the Proposal is wrapped by another one
    bool   wrapped;
}
```

### Governance (DAO token)

We shouldn't care about underlying standard of these tokens - for some DAOs it might be ERC-20, for others ERC-721
or ERC-1155. As it was mentioned earlier, the only question we should ask "How much voting power the user has?" Also
we need a simple interface for managing the voting power.

```solidity
struct GovernanceSettings {
    // minQuorum - the minimum quorum that should be set for every Proposal.rules.quorum options
    uint256 minQuorum;
    // overrideProposalTimeRules - a flag that overrides Proposals expiration and delay settings
    bool overrideProposalTimeRules;
    // proposalExpiration - expiration time which will be set to Proposal if overrideProposalTimeRules == true
    uint256 proposalExpiration;
    // proposalDelay - delay time which will be set to Proposal if overrideProposalTimeRules == true
    uint256 proposalDelay;
}

interface IGovernance is ERC165 {
    
    //// Getters ////

    // parent() -> IGovernance
    // This concept allows making nested communities which might be useful to separate roles in DAOs
    function parent() view returns (IGovernance);
    
    // relatedDAO() -> ERC4824
    // Should return a related DAO follows ERC4824
    // TODO review
    function relatedDAO() view returns (ERC4824 dao);

    // mirror() -> address
    // Returns an existing DAO-token which doesn't follow the standard if it was set
    // id stands for votingPowerProvider which implements ERC-1155
    // tokenType should return an ERC-165 signature to clarify mirrored token type
    function mirror() external view returns (address votingPowerProvider, uint256 id, bytes4 tokenType);

    // votingPower(address) -> uint256
    // Answers the question "How much voting power the user has?"
    function votingPower(address member) external view returns (uint256);

    // totalVotingPower() -> uint256
    // Should return the total voting power for all Governance tokens
    // Here ERC-20's _totalSupply() might be used by default, but for more complex logic that function might be needed
    // For example, total Voting Power might persist even if a user has burned the Governance token.
    function totalVotingPower() view returns (uint256);
    
    // governanceSettings() -> GovernanceSettings memory
    // Should return governance settings for the token
    function governanceSettings() view returns (GovernanceSettings memory);
    
    // totalProposals() -> uint256
    // Should return the total amount of Proposals
    function totalProposals() view returns (uint256);

    // totalProposals() -> uint256
    // Should return a user Vote as chosen option and Voting Power
    function userVote(address member, uint256 proposalId) view returns (uint256 option, uint256 votingPower);
    
    
    //// Managing Settings ////
    
    // updateSettings(GovernanceSettings memory)
    // Should update Governance settings
    // This is an action, so it should be run by a registered and passed Proposal
    function updateSettings(GovernanceSettings memory) external;
    
    
    //// Managing Voting Power ////
    

    // stake(address, uint256)
    // Allow to obtain the voting power for token holders
    // staker here is the owner of non-staked tokens and delegatee is who will get the voting power from these tokens
    function stakeFor(address staker, address delegatee, uint256 amount) external;

    // unstake(address, uint256)
    // Allows to release voting power.
    // staker here is "who owns voting power" and receiver - the address who will get the released tokens  
    function unstakeFor(address staker, address receiver, uint256 amount) external;
    
    
    //// Working with Proposals ////
    

    // registerProposal(Proposal memory) -> uint256
    // Should register a proposal
    // Returns internal Proposal id which will allow to wrap the Proposal 
    function registerProposal(Proposal memory proposal) external returns (uint256 id);

    // getProposal(uint256) -> Proposal memory
    // Should return a registered Proposal with the provided proposalId.
    function getProposal(uint256 proposalId) external view returns (Proposal memory proposal);

    // executeProposal(uint256) -> bool
    // Should execute Proposal's app.action if check of all the conditions described in Proposal.rules passed
    // If the Proposal has delay, the action shouldn't be performed, but the status should be set accordingly
    function executeProposal(uint256 proposalId) external returns (bool success);
    
    // vote(uint256, uint256, uint256)
    // Allow to vote for a registered Proposal
    function vote(
        uint256 proposalId,
        uint256 optionId,
        uint256 amount) external;
    
    // revokeVote(uint256,uint256,uint256)
    // Revokes a vote made by user for the registered Proposal
    function revokeVote(
        uint256 proposalId,
        uint256 optionId,
        uint256 amount) external;
}
```
In the described interface all possible actions with Governance tokens might be implemented. Delegating the voting
power for example might be implemented in `stake` function with different `staker` and `delegatee`. Also, it's
possible to implement contracts which will stake Governance for users. In that case usual `allowance` might be used
by the contract.

## Conclusion
The described standards above might look overwhelming but actually a DAO-centric app should operate with Proposal
structures only.

OuterCircle Protocol implements Proposal Registry following the proposed standard and provide developers with an
easy-to-use toolkit and contracts to develop their app. The apps accessible by any DAO!