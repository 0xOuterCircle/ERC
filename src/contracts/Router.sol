// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../interfaces/IRouter.sol";
import "../interfaces/IProposalRegistry.sol";
import {Proposal, Transaction} from "./ProposalRegistry.sol";
import "openzeppelin/utils/introspection/ERC165.sol";

abstract contract Router is ERC165, IRouter {
    mapping(bytes4 => string[]) public userVars; // UI Report to frontent purposes

    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC165, IERC165) returns (bool) {
        return interfaceId == type(IRouter).interfaceId || super.supportsInterface(interfaceId);
    }

    function onVote(uint256 _propId, uint256 _transId, bool _vote, bytes calldata _voteData)
        external
        virtual
        returns (bytes memory)
    {
        Proposal memory prop = IProposalRegistry(msg.sender).getProposal(_propId);
        Transaction memory trans = prop.pipeline[_transId];

        bytes memory transData = _processVote(prop, trans, _vote, _voteData);
        return transData;
    }

    function _processVote(Proposal memory prop, Transaction memory trans, bool _vote, bytes calldata _voteData)
        internal
        virtual
        returns (bytes memory);

    /**
     * @param text Any text to vote for: link, message, id, etc.
     */
    function textProposal(string calldata text) external pure returns (string calldata) {
        return text;
    }

    function _setUserVars(bytes4 funcSelector, string[] calldata vars) internal {
        userVars[funcSelector] = vars;
    }
}
