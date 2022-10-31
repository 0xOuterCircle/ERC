// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "interfaces/IGovernance.sol";
import "interfaces/IRouter.sol";
import {IProposalRegistry} from "../interfaces/IProposalRegistry.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
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

contract ProposalRegistry is ERC165, IProposalRegistry {
    event ProposalCreated(uint256 indexed _propId);
    event ProposalAccepted(uint256 indexed _propId);
    event ProposalRejected(uint256 indexed _propId);
    event ProposalExecuted(uint256 indexed _propId);
    event VetoCasted(uint256 indexed _propId);
    event ChildApproved(address indexed _registry);
    event ChildRemoved(address indexed _registry);
    event ParentChanged(address indexed _oldParent, address indexed _newParent);
    event ProposalExpirationTimeChanged(uint256 _oldTime, uint256 _newTime);
    event GovernanceChanged(address indexed _oldGovernance, address indexed _newGovernance);

    mapping(address => mapping(uint256 => VoteType)) private voted;

    mapping(IProposalRegistry => bool) public isChildRegistry;
    uint256 private proposalCounter;

    mapping(uint256 => Proposal) private proposals;
    IGovernance public governance;
    uint256 public proposalExpirationTime;
    uint256 public quorumRequired;
    IProposalRegistry public parentRegistry;

    constructor(
        IGovernance _governance,
        uint256 _proposalExpirationTime,
        uint256 _quorumRequired,
        IProposalRegistry _parentRegistry
    ) {
        proposalExpirationTime = _proposalExpirationTime;
        governance = _governance;
        parentRegistry = _parentRegistry;
        quorumRequired = _quorumRequired;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC165, IERC165) returns (bool) {
        return interfaceId == type(IProposalRegistry).interfaceId || super.supportsInterface(interfaceId);
    }

    function createProposal(Transaction[] calldata _pipeline) external virtual {
        require(governance.isProposalCreator(msg.sender), "This function can be called only by specific role");

        uint256 propId_ = proposalCounter++;
        
        Proposal storage prop = proposals[propId_];

        require(prop.status == Status.NONE, "Proposal with this ID already exists");

        prop.status = Status.EXISTS;
        prop.creationBlock = block.number;
        prop.creationTime = block.timestamp;

        // check for IRouter interface supporting
        for (uint256 i = 0; i < _pipeline.length; ++i) {
            Transaction calldata trans = _pipeline[i];

            require(trans.response.length == 0, "Response should be empty");

            if (trans.transType == TransType.ROUTER) {
                require(
                    IERC165(trans.to).supportsInterface(type(IRouter).interfaceId),
                    "Router doesn't correspond IRouter interface"
                );
            }
            prop.pipeline.push(trans);
        }

        emit ProposalCreated(propId_);
    }

    function vote(uint256 _propId, VoteType _decision, bytes[] calldata _data) external virtual {
        require(!proposalExpired(_propId), "Proposal expired");
        require(governance.isProposalVoter(msg.sender), "This function can be called only by specific role");

        Proposal storage proposal = proposals[_propId];

        require(proposal.status == Status.EXISTS, "Proposal must exist");

        uint256 votingPower_ = governance.votingPowerOf(msg.sender);

        require(votingPower_ > 0, "You have no voting power for this proposal");

        if (voted[msg.sender][_propId] == VoteType.YES) {
            proposal.yesCount -= votingPower_;
        }

        if (voted[msg.sender][_propId] == VoteType.NO) {
            proposal.noCount -= votingPower_;
        }

        if (voted[msg.sender][_propId] == VoteType.NEUTRAL) {
            proposal.neutralCount -= votingPower_;
        }

        voted[msg.sender][_propId] = _decision;

        if (_decision == VoteType.YES) {
            proposal.yesCount += votingPower_;
        } else if (_decision == VoteType.NO) {
            proposal.noCount += votingPower_;
        } else if (_decision == VoteType.NEUTRAL) {
            proposal.neutralCount += votingPower_;
        }

        // updating router-transactions states
        uint256 routerIndex_;
        for (uint256 i = 0; i < proposal.pipeline.length; ++i) {
            Transaction storage trans = proposal.pipeline[i];
            if (trans.transType == TransType.ROUTER) {
                trans.data = IRouter(trans.to).onVote(_propId, i, _decision, votingPower_, _data[routerIndex_]);
                routerIndex_ += 1;
            }
        }

        bool result = voteResult(_propId);
        if (result) {
            proposal.status = Status.ACCEPTED;
            emit ProposalAccepted(_propId);
        } else {
            proposal.status = Status.REJECTED;
            emit ProposalRejected(_propId);
        }
    }

    function voteResult(uint256 _propId) public view virtual returns (bool) {
        Proposal storage proposal = proposals[_propId];

        uint256 totalVotes_ = proposal.yesCount + proposal.noCount + proposal.neutralCount;
        return proposal.yesCount > proposal.noCount && totalVotes_ >= quorumRequired;
    }

    function execute(uint256 _propId) external virtual {
        require(!proposalExpired(_propId), "Proposal expired");
        require(governance.isProposalExecuter(msg.sender), "This function can be called only by specific role");

        Proposal storage proposal = proposals[_propId];

        require(proposal.status == Status.ACCEPTED, "Proposal must be accepted");

        proposal.status = Status.EXECUTED;

        for (uint256 i = 0; i < proposal.pipeline.length; ++i) {
            Transaction storage trans = proposal.pipeline[i];
            (bool success_, bytes memory response_) = trans.to.call{value: trans.value}(trans.data);
            trans.response = response_;

            require(success_, "Transaction failed");
        }

        emit ProposalExecuted(_propId);
    }

    function castVeto(uint256 _propId) external virtual {
        require(governance.isVetoCaster(msg.sender), "This function can be called only by specific role");

        emit VetoCasted(_propId);

        proposals[_propId].status = Status.REJECTED;
    }

    function proposalExpired(uint256 _propId) public view virtual returns (bool) {
        return proposals[_propId].creationTime + proposalExpirationTime > block.timestamp;
    }

    function getProposal(uint256 _propId) public view virtual returns (Proposal memory) {
        return proposals[_propId];
    }

    function approveChildRegistry(IProposalRegistry _registry) external virtual {
        require(governance.isSubDaoApprover(msg.sender), "This function can be called only by specific role");
        require(
            address(_registry.parentRegistry()) == address(this), "This registry must be parent registry of the child"
        );
        require(!isChildRegistry[_registry], "The registry is already a child");

        emit ChildApproved(address(_registry));

        isChildRegistry[_registry] = true;
    }

    function removeChildRegistry(IProposalRegistry _registry) external virtual {
        require(governance.isSubDaoRemover(msg.sender), "This function can be called only by specific role");
        require(isChildRegistry[_registry], "The registry is not a child");

        emit ChildRemoved(address(_registry));

        isChildRegistry[_registry] = false;
    }

    function changeProposalExpirationTime(uint256 _newTime) external virtual {
        require(
            governance.isProposalExpirationTimeChanger(msg.sender), "This function can be called only by specific role"
        );

        emit ProposalExpirationTimeChanged(proposalExpirationTime, _newTime);

        proposalExpirationTime = _newTime;
    }

    function changeGovernance(IGovernance _newGovernance) external virtual {
        require(governance.isGovernanceChanger(msg.sender), "This function can be called only by specific role");

        emit GovernanceChanged(address(governance), address(_newGovernance));

        governance = _newGovernance;
    }

    function changeParentRegistry(IProposalRegistry _newRegistry) external virtual {
        require(governance.isParentRegistryChanger(msg.sender), "This function can be called only by specific role");

        emit ParentChanged(address(parentRegistry), address(_newRegistry));

        parentRegistry = _newRegistry;
    }
}
