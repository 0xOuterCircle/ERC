// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./IGovernance.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

struct Transaction {
    address to;
    uint256 value;
    bytes data;
    bytes response;
    TransType transType;
}

enum TransType {
    REGULAR,
    ROUTER
}

enum Status {
    NONE,
    EXISTS,
    ACCEPTED,
    EXECUTED,
    REJECTED
}

struct Proposal {
    Status status;
    Transaction[] pipeline;
    uint256 creationBlock;
    uint256 creationTime;
    uint256 yesCount;
    uint256 noCount;
    uint256 neutralCount;
}

enum VoteType {
    NONE,
    YES,
    NO,
    NEUTRAL
}

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
