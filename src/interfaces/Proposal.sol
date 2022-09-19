// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;
import "./IDdApp.sol";

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
