// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "interfaces/IRouter.sol";
import "interfaces/IProposalRegistry.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract Router is ERC165, IRouter {
    // ==================== STORAGE ====================

    mapping(bytes4 => string[]) private userVars; // Mapping from func selector to list of names of parameters that user can fill. Frontend needs it

    string public name; // name of the Router
    string public description; // description of the Router
    string public logoUrl; // logo url of the Router

    // ==================== CONSTRUCTOR ====================

    constructor(string memory _name, string memory _description, string memory _logoUrl) {
        name = _name;
        description = _description;
        logoUrl = _logoUrl;
    }

    // ==================== PUBLIC FUNCTIONS ====================

    /**
     * @notice ERC165 interface support
     * @dev Need to identify ProposalRegistry
     * @param interfaceId unique id of the interface
     * @return Support or not
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC165, IERC165) returns (bool) {
        return interfaceId == type(IRouter).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @notice Get parameters that user can fill while creating proposal
     * @dev For frontend purpises
     * @param funcSelector Selector of the function to check params of
     * @return List of user-to-fill params names
     */
    function getUserVars(bytes4 funcSelector) external view returns (string[] memory) {
        return userVars[funcSelector];
    }

    // ==================== EXECUTIVE FUNCTIONS ====================

    /**
     * @notice Blank proposal, Snapshot proposal, Text proposal
     * @dev If DAO wants to vote on-chain for some off-chain proposal, they can use this function in proposal
     * @param text Any text to vote for: link, message, id, etc.
     * @return Always exactly the same text
     */
    function textProposal(string calldata text) external view virtual returns (string calldata) {
        return text;
    }

    // ==================== REGISTRY FUNCTIONS ====================

    /**
     * @dev Function which is called every time when someone vote for proposal which contains this Router transaction.
     * This function recalculates proposal CALLDATA (changes some parameters or something)
     * and returns new calldata of the transaction back to the ProposalRegistry
     * @return New CALLDATA of the Router transaction (changes proposal)
     */
    function onVote(uint256 _propId, uint256 _transId, VoteType _vote, uint256 _votingPower, bytes calldata _voteData)
        external
        virtual
        returns (bytes memory)
    {
        Proposal memory prop = IProposalRegistry(msg.sender).getProposal(_propId);
        Transaction memory trans = prop.pipeline[_transId];

        bytes32 sessionId_ = _getSessionId(_propId, _transId);

        if (prop.yesCount + prop.noCount == 0) {
            _onVoteStart(sessionId_, prop, trans, _vote, _votingPower, _voteData);
        }

        bytes memory transData = _processVote(sessionId_, prop, trans, _vote, _votingPower, _voteData);

        return transData;
    }

    // ==================== INTERNAL FUNCTIONS ====================

    function _getSessionId(uint256 _propId, uint256 _transId) internal view returns (bytes32) {
        return keccak256(abi.encode(msg.sender, _propId, _transId));
    }

    function _onVoteStart(
        bytes32 _sessionId,
        Proposal memory prop,
        Transaction memory trans,
        VoteType _vote,
        uint256 _votingPower,
        bytes calldata _voteData
    )
        internal
        virtual
        returns (bytes memory)
    {}

    function _processVote(
        bytes32 _sessionId,
        Proposal memory prop,
        Transaction memory trans,
        VoteType _vote,
        uint256 _votingPower,
        bytes calldata _voteData
    )
        internal
        virtual
        returns (bytes memory)
    {}

    function _setUserVars(bytes4 funcSelector, string[] calldata vars) internal virtual {
        userVars[funcSelector] = vars;
    }
}
