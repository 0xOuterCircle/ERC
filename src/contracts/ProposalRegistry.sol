// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../interfaces/IGovernance.sol";
import "../interfaces/IRouter.sol";
import {IProposalRegistry} from "../interfaces/IProposalRegistry.sol";
import "openzeppelin/utils/introspection/ERC165.sol";
import "openzeppelin/utils/introspection/IERC165.sol";


struct Transaction {
    address to;
    uint value;
    bytes data;
    bytes response;
    TransactionType transType;
}

enum TransactionType {
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
}

enum VoteType {
    NONE,
    YES,
    NO
}

abstract contract ProposalRegistry is ERC165, IProposalRegistry {

    event ProposalCreated(uint256 indexed _propId);
    event ProposalAccepted(uint256 indexed _propId);
    event ProposalRejected(uint256 indexed _propId);
    event ProposalExecuted(uint256 indexed _propId);   

    mapping(address => mapping(uint256 => VoteType)) private voted;

    mapping(uint256 => Proposal) public proposals;
    IGovernance public governance;
    uint256 public proposalExpirationTime;


    constructor(IGovernance _governance, uint256 _proposalExpirationTime) {
        governance = _governance;
        proposalExpirationTime = _proposalExpirationTime;
        
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IProposalRegistry).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function createProposal(uint256 _propId, Transaction[] calldata _pipeline) external {
        require(proposals[_propId].status == Status.NONE, 'Proposal with this ID already exists');

        // check for IRouter interface supporting
        for(uint256 i = 0; i < _pipeline.length; ++i) {
            Transaction calldata trans = _pipeline[i];
            if (trans.transType == TransactionType.ROUTER) {
                require(IERC165(trans.to).supportsInterface(type(IRouter).interfaceId), 
                "Router doesn't correspond IRouter interface");
            }
        }
        
        _beforeCreateProposal(_propId, _pipeline);

        proposals[_propId] = Proposal(Status.EXISTS, _pipeline, block.number, block.timestamp, 0, 0);

        _afterCreateProposal(_propId, _pipeline);
    }

    function _beforeCreateProposal(uint256 _propId, Transaction[] calldata _pipeline) internal virtual {}
    function _afterCreateProposal(uint256 _propId, Transaction[] calldata _pipeline) internal virtual {}


    function vote(uint256 _propId, bool _decision, bytes calldata _data) external {
        require(!proposalExpired(_propId), 'Proposal expired');
        require(proposals[_propId].status == Status.EXISTS, 'Proposal must exist');

        Proposal storage proposal = proposals[_propId];

        uint256 votingPower_ = governance.votingPowerAt(msg.sender, proposal.creationBlock);

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

        // updating router-transactions states
        for(uint256 i = 0; i < proposal.pipeline.length; ++i) {
            Transaction storage trans = proposal.pipeline[i];
            if (trans.transType == TransactionType.ROUTER) {
                trans.data = IRouter(trans.to).onVote(i, _decision, _data);
            }
        }

        voted[msg.sender][_propId] = _decision ? VoteType.YES : VoteType.NO;

        VoteType result = voteResult(_propId);
        if (result == VoteType.YES) {
            proposal.status = Status.ACCEPTED;
            emit ProposalAccepted(_propId);

        } else if (result == VoteType.NO) {
            proposal.status = Status.REJECTED;
            emit ProposalRejected(_propId);
        }

    }

    function voteResult(uint256 _propId) public virtual view returns(VoteType) {}

    function execute(uint256 _propId) external {
        require(!proposalExpired(_propId), 'Proposal expired');
        require(proposals[_propId].status == Status.ACCEPTED, 'Proposal must be accepted');

        Proposal storage proposal = proposals[_propId];

        proposal.status = Status.EXECUTED;

        for(uint256 i=0; i < proposal.pipeline.length; ++i) {
            Transaction storage trans = proposal.pipeline[i];
            (bool success_, bytes memory response_) = trans.to.call{value: trans.value}(trans.data);
            trans.response = response_;

            require(success_, 'Transaction failed');
        }

        emit ProposalExecuted(_propId);
    }

    function proposalExpired(uint256 _propId) public view returns(bool) {
        return proposals[_propId].creationTime + proposalExpirationTime > block.timestamp;
    }

}