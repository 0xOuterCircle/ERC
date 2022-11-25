// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

struct Action {
    ActionType actionType;
    address to;
    bytes data;
    uint256 value;
}

enum ActionType {
    REGULAR,
    APP
}

enum ProposalStatus {
    NONE, // for uncreated proposals
    EXISTS,
    ACCEPTED,
    EXECUTED,
    REJECTED
}

struct Proposal {
    ProposalStatus status;
    Action[] pipeline;
    uint256 creationBlock;
    uint256 creationTime;
    uint256 forVp;
    uint256 againstVp;
    uint256 abstainVp;
}

enum VoteType {
    NONE,
    FOR,
    AGAINST,
    ABSTAIN
}

interface IDaoController is IERC165 {
    // Proposals functions
    function voteProposal(uint256 propId, VoteType decision, bytes[] calldata data) external;
    function createProposal(Action[] calldata _pipeline) external;
    function executeProposal(uint256 propId) external;
    function castVeto(uint256 propId) external;
    // Special functions
    function approveChildDaoController(IDaoController controller) external;
    function removeChildDaoController(IDaoController controller) external;
    function changeProposalExpirationTime(uint256 newTime) external;
    // View functions
    function proposalAccepted(uint256 propId) external view returns (bool);
    function proposalExpired(uint256 propId) external view returns (bool);
    function getProposal(uint256 propId) external view returns (Proposal memory);
    function votingPowerOf(address user) external view returns (uint256);
    // State view functions
    function proposalExpirationTime() external view returns (uint256);
    function parentDaoController() external view returns (IDaoController);
    function isChildDaoController(IDaoController controller) external view returns (bool);
    function quorumRequired() external view returns (uint256);
}
