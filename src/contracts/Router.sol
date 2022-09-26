// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


import "../interfaces/IRouter.sol";
import "../interfaces/IProposalRegistry.sol";
import {Proposal, Transaction} from "./ProposalRegistry.sol";

abstract contract Router is IRouter {
    function onVote (
        uint256 _propId, 
        uint256 _transId, 
        bool _vote, 
        bytes calldata _voteData
        ) external virtual returns(bytes memory) {

        Proposal memory prop = IProposalRegistry(msg.sender).getProposal(_propId);
        Transaction memory trans = prop.pipeline[_transId];

        bytes memory transData = _processVote(prop, trans, _vote, _voteData);
        return transData;
    }

    function _processVote(
        Proposal memory prop, 
        Transaction memory trans, 
        bool _vote, bytes calldata 
        _voteData
        ) internal virtual returns(bytes memory);

}