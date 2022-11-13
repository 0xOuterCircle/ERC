// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./IGovernance.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

struct Transaction {
    address to; // address of the contract or EoA to call to
    uint256 value; // amount of ETH attaching to the transaction
    bytes data; // encoded transaction body
    bytes response; // transaction result, empty from start
    TransType transType; // transaction type
}

enum TransType {
    REGULAR,
    ROUTER
}

enum Status {
    NONE, // for uncreated proposals
    EXISTS,
    ACCEPTED,
    EXECUTED,
    REJECTED
}

struct Proposal {
    Status status; // proposal status
    Transaction[] pipeline; // list of transactions to execute
    uint256 creationBlock; // blocknumber when proposal was created
    uint256 creationTime; // block timestamp when proposal was created
    uint256 yesCount; // number of positive votes
    uint256 noCount; // number of negative votes
    uint256 neutralCount; // number of abstains
}

enum VoteType {
    NONE, // didn't vote
    YES,
    NO,
    NEUTRAL
}

interface IProposalRegistry is IERC165 {
    /**
     *
     */
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
