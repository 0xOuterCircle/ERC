// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "interfaces/IOuterCircleApp.sol";
import "interfaces/IDaoController.sol";
import "contracts/OuterCircleApp.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract DaoController is OuterCircleApp, AccessControl, IDaoController {
    // ==================== EVENTS ====================

    event OCDaoControllerCreated(address indexed parentAddress);
    event OCProposalCreated(uint256 indexed propId);
    event OCProposalAccepted(uint256 indexed propId);
    event OCProposalRejected(uint256 indexed propId);
    event OCProposalExecuted(uint256 indexed propId);
    event OCVetoCasted(uint256 indexed propId);
    event OCChildApproved(address indexed daoController);
    event OCChildRemoved(address indexed daoController);
    event OCParentChanged(address indexed oldParent, address indexed newParent);
    event OCProposalExpirationTimeChanged(uint256 oldTime, uint256 newTime);
    event OCQuorumRequiredChanged(uint256 oldQuorum, uint256 newQuorum);

    // ==================== STORAGE ====================

    mapping(address => mapping(uint256 => VoteType)) private voted; // to track users previous votes for proposals by proposal id
    mapping(IDaoController => bool) public isChildDaoController; // dict of sub-DAOs
    uint256 private proposalCounter; // to change proposal IDs
    mapping(uint256 => Proposal) private proposals; // dict of all proposals by id
    uint256 public proposalExpirationTime; // time proposal to be able to vote for
    uint256 public quorumRequired; // minimal total number of votes to accept proposal
    IDaoController public immutable parentDaoController; // address of parrent dao controller (of which current dao controller is child of)

    mapping(string => bytes32) private _roleByName; // get role ID by string role name
    // all roles set to 0x00 (DEFAULT_ADMIM_ROLE) by default

    // ==================== CONSTRUCTOR ====================

    constructor(
        address _defaultAdminAddress,
        uint256 _proposalExpirationTime,
        uint256 _quorumRequired,
        IDaoController _parentDaoController
    )
        OuterCircleApp(
            "Default DAO Controller",
            "Default DAO Controller made from DAO Controller template. Do not use it in prodiction."
        )
    {
        proposalExpirationTime = _proposalExpirationTime;
        parentDaoController = _parentDaoController;
        quorumRequired = _quorumRequired;

        // set roles here or add special logic to add them
        // all unseted roles will be set to 0x00 (DEFAULT_ADMIN_ROLE)
        _roleByName["DEFAULT_ADMIN_ROLE"] = 0x00;
        _grantRole(_roleByName["DEFAULT_ADMIN_ROLE"], _defaultAdminAddress);

        // _roleByName["VETO_CASTER"] = keccak256("VETO_CASTER");
        // _grantRole(_roleByName["VETO_CASTER"], someAddress);

        emit OCDaoControllerCreated(address(_parentDaoController));
    }

    // ==================== PUBLIC FUNCTIONS ====================

    /**
     * @notice ERC165 interface support
     * @dev Need to identify DaoController
     * @param interfaceId unique id of the interface
     * @return Support or not
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (IERC165, AccessControl, OuterCircleApp)
        returns (bool)
    {
        return interfaceId == type(IDaoController).interfaceId || interfaceId == type(IAccessControl).interfaceId
            || interfaceId == type(IOuterCircleApp).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @notice Voting power of a member
     * @dev If DAO has a governance token, this function should return the token balances
     * @param _who Address to check power of
     * @return Voting power
     */
    function votingPowerOf(address _who) public pure returns (uint256) {
        return 0; // zero for all by default
    }

    // ==================== DAO FUNCTIONS ====================

    /**
     * @notice Create proposal
     * @dev Can be called only by PROPOSAL_CREATOR role
     * @param _pipeline List of Action proposed to execute
     */
    function createProposal(Action[] calldata _pipeline) external virtual onlyRole(_roleByName["PROPOSAL_CREATOR"]) {
        uint256 propId_ = proposalCounter++;

        Proposal storage prop = proposals[propId_];

        require(prop.status == ProposalStatus.NONE, "Proposal with this ID already exists");

        prop.status = ProposalStatus.EXISTS;
        prop.creationBlock = block.number;
        prop.creationTime = block.timestamp;

        // check for IRouter interface supporting
        for (uint256 i = 0; i < _pipeline.length; ++i) {
            Action calldata action = _pipeline[i];

            // if (trans.transType == ActionType.ROUTER) {
            //     require(
            //         IERC165(trans.to).supportsInterface(type(IRouter).interfaceId),
            //         "Router doesn't correspond IRouter interface"
            //     );
            // }

            prop.pipeline.push(action);
        }

        emit OCProposalCreated(propId_);
    }

    /**
     * @notice Vote for proposal
     * @dev Can be called only by PROPOSAL_VOTER role
     * @param _propId id of proposal
     * @param _decision vote decision (1 - yes, 2 - no, 3 - neutral)
     * @param _data list of transactions calldata
     */
    function voteProposal(uint256 _propId, VoteType _decision, bytes[] calldata _data)
        external
        virtual
        onlyRole(_roleByName["PROPOSAL_VOTER"])
    {
        require(!proposalExpired(_propId), "Proposal expired");

        Proposal storage proposal = proposals[_propId];

        require(proposal.status == ProposalStatus.EXISTS, "Proposal must exist");

        uint256 votingPower_ = votingPowerOf(msg.sender);

        require(votingPower_ > 0, "You have no voting power for this proposal");

        if (voted[msg.sender][_propId] == VoteType.FOR) {
            proposal.forVp -= votingPower_;
        }

        if (voted[msg.sender][_propId] == VoteType.AGAINST) {
            proposal.againstVp -= votingPower_;
        }

        if (voted[msg.sender][_propId] == VoteType.ABSTAIN) {
            proposal.abstainVp -= votingPower_;
        }

        voted[msg.sender][_propId] = _decision;

        if (_decision == VoteType.FOR) {
            proposal.forVp += votingPower_;
        } else if (_decision == VoteType.AGAINST) {
            proposal.againstVp += votingPower_;
        } else if (_decision == VoteType.ABSTAIN) {
            proposal.abstainVp += votingPower_;
        }

        // // updating router-transactions states
        // uint256 routerIndex_;
        // for (uint256 i = 0; i < proposal.pipeline.length; ++i) {
        //     Action storage trans = proposal.pipeline[i];
        //     if (trans.transType == TransType.ROUTER) {
        //         trans.data = IRouter(trans.to).onVote(_propId, i, _decision, votingPower_, _data[routerIndex_]);
        //         routerIndex_ += 1;
        //     }
        // }

        bool result = proposalAccepted(_propId);
        if (result) {
            proposal.status = ProposalStatus.ACCEPTED;
            emit OCProposalAccepted(_propId);
        } else {
            proposal.status = ProposalStatus.REJECTED;
            emit OCProposalRejected(_propId);
        }
    }

    /**
     * @notice Result of proposal voting
     * @dev Logic of the acceptance might be changed
     * @param _propId proposal ID
     * @return Accepted or not
     */
    function proposalAccepted(uint256 _propId) public view virtual returns (bool) {
        Proposal storage proposal = proposals[_propId];

        uint256 totalVotes_ = proposal.forVp + proposal.againstVp + proposal.abstainVp;
        return proposal.forVp > proposal.againstVp && totalVotes_ >= quorumRequired;
    }

    /**
     * @notice Execute all transactions in accepted proposal
     * @dev Can be called only by PROPOSAL_EXECUTER role
     * @param _propId proposal ID
     */
    function executeProposal(uint256 _propId) external virtual onlyRole(_roleByName["PROPOSAL_EXECUTER"]) {
        require(!proposalExpired(_propId), "Proposal expired");

        Proposal storage proposal = proposals[_propId];

        require(proposal.status == ProposalStatus.ACCEPTED, "Proposal must be accepted");

        proposal.status = ProposalStatus.EXECUTED;

        for (uint256 i = 0; i < proposal.pipeline.length; ++i) {
            Action storage action = proposal.pipeline[i];
            (bool success_, bytes memory response_) = action.to.call{value: action.value}(action.data);

            require(success_, "Transaction failed");
        }

        emit OCProposalExecuted(_propId);
    }

    /**
     * @notice Forcibly decline proposal
     * @dev Can be called only by VETO_CASTER role
     * @param _propId proposal ID
     */
    function castVeto(uint256 _propId) external virtual onlyRole(_roleByName["VETO_CASTER"]) {
        emit OCVetoCasted(_propId);

        proposals[_propId].status = ProposalStatus.REJECTED;
    }

    /**
     * @notice Check expiration of proposal
     * @dev Expired proposals cannot be executed or voted for
     * @param _propId Proposal ID
     * @return Expired or not
     */
    function proposalExpired(uint256 _propId) public view virtual returns (bool) {
        return proposals[_propId].creationTime + proposalExpirationTime < block.timestamp;
    }

    /**
     * @notice Get proposal by its id
     * @dev This is necessary because getter for "proposals" cannot be created automatically
     * @param _propId Proposal ID
     * @return Struct of the proposal
     */
    function getProposal(uint256 _propId) public view virtual returns (Proposal memory) {
        return proposals[_propId];
    }

    /**
     * @notice Appropve another DaoController as a sub-DAO
     * @dev Can be called only by CHILD_DAO_APPROVER role
     * @param _daoController Address of the DaoController (sub-DAO)
     */
    function approveChildDaoController(IDaoController _daoController)
        external
        virtual
        onlyRole(_roleByName["CHILD_DAO_APPROVER"])
    {
        require(
            address(_daoController.parentDaoController()) == address(this),
            "This dao controller must be parent dao controller of the child"
        );
        require(!isChildDaoController[_daoController], "The dao controller is already a child");

        emit OCChildApproved(address(_daoController));

        isChildDaoController[_daoController] = true;
    }

    /**
     * @notice Remove sub-DAO
     * @dev Can be called only by CHILD_DAO_REMOVER role
     * @param _daoController Address of the sub-DAO to remove
     */
    function removeChildDaoController(IDaoController _daoController)
        external
        virtual
        onlyRole(_roleByName["CHILD_DAO_REMOVER"])
    {
        require(isChildDaoController[_daoController], "The dao controller is not a child");

        emit OCChildRemoved(address(_daoController));

        isChildDaoController[_daoController] = false;
    }

    /**
     * @notice Change proposal expiration time
     * @dev Can be called only by PROPOSAL_EXPIRATION_TIME_CHANGER role
     * @param _newTime New proposal exporation time
     */
    function changeProposalExpirationTime(uint256 _newTime)
        external
        virtual
        onlyRole(_roleByName["PROPOSAL_EXPIRATION_TIME_CHANGER"])
    {
        emit OCProposalExpirationTimeChanged(proposalExpirationTime, _newTime);

        proposalExpirationTime = _newTime;
    }

    /**
     * @notice Change quorum required for a proposal acceptance
     * @dev Can be called only by PROPOSAL_EXPIRATION_TIME_CHANGER role
     * @param _newQuorumRequired New proposal exporation time
     */
    function changeQuorumRequired(uint256 _newQuorumRequired)
        external
        virtual
        onlyRole(_roleByName["QUORUM_REQUIRED_CHANGER"])
    {
        emit OCQuorumRequiredChanged(quorumRequired, _newQuorumRequired);

        quorumRequired = _newQuorumRequired;
    }
}
