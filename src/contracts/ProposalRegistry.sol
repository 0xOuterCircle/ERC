// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../interfaces/IVotingToken.sol";

struct Transaction {
    address to;
    uint value;
    bytes data;
}

enum Status {
    NONE,
    EXISTS,
    ACCEPTED,
    EXECUTED,
    DENIED
}

struct Proposal {
    Status status;
    Transaction[] pipeline;
    uint256 creationBlock;
    uint256 yesCount;
    uint256 noCount;
}

enum VoteType {
    NONE,
    YES,
    NO
}

contract ProposalRegistry {

    event ProposalCreated(uint256 indexed _propId);

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => VoteType)) public voted;
    IVotingToken votingToken;


    constructor(IVotingToken _token) {
        votingToken = _token;
    }
    function createProposal(uint256 _propId, Transaction[] calldata _pipeline) external {
        require(proposals[_propId].status == Status.NONE, 'Proposal with this ID already exists');
        
        _beforeCreateProposal(_propId, _pipeline);

        proposals[_propId] = Proposal(Status.EXISTS, _pipeline, block.number, 0, 0);

        _afterCreateProposal(_propId, _pipeline);
    }

    function _beforeCreateProposal(uint256 _propId, Transaction[] calldata _pipeline) internal virtual {}
    function _afterCreateProposal(uint256 _propId, Transaction[] calldata _pipeline) internal virtual {}


    function vote(uint256 _propId, bool _decision, bytes calldata _data) external {
        require(proposals[_propId].status == Status.EXISTS, 'Proposal must exist');

        Proposal storage proposal = proposals[_propId];

        uint256 votingPower_ = votingToken.balanceOfAt(msg.sender, proposal.creationBlock - 1);

        require(votingPower_ > 0, "You have no voting power for this proposal");

        if (voted[msg.sender][_propId] == VoteType.YES) {
            proposal.yesCount -= votingPower_;
        }

        if (voted[msg.sender][_propId] == VoteType.NO) {
            proposal.noCount -= votingPower_;
        }

        if (_decision) {
            proposal.yesCount += votingPower_;
        } else {
            proposal.noCount += votingPower_;
        }

        _processVoteData(_propId, _decision, _data);

        voted[msg.sender][_propId] = _decision ? VoteType.YES : VoteType.NO;
    }

    function _processVoteData(uint256 _propId, bool _decision, bytes calldata _data) internal virtual {}


}