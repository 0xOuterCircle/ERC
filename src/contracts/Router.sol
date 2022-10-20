// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "interfaces/IRouter.sol";
import "interfaces/IProposalRegistry.sol";
import {Proposal, Transaction, Status} from "./ProposalRegistry.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract Router is ERC165, IRouter {
    mapping(bytes4 => string[]) private userVars; // UI Report to frontent purposes

    string public name;
    string public description;
    string public logoUrl;

    constructor(string memory _name, string memory _description, string memory _logoUrl) {
        name = _name;
        description = _description;
        logoUrl = _logoUrl;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC165, IERC165) returns (bool) {
        return interfaceId == type(IRouter).interfaceId || super.supportsInterface(interfaceId);
    }

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

    /**
     * @param text Any text to vote for: link, message, id, etc.
     */
    function textProposal(string calldata text) external view virtual returns (string calldata) {
        return text;
    }

    function _setUserVars(bytes4 funcSelector, string[] calldata vars) internal virtual {
        userVars[funcSelector] = vars;
    }

    function getUserVars(bytes4 funcSelector) external view returns (string[] memory) {
        return userVars[funcSelector];
    }
}
