// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "openzeppelin/utils/introspection/IERC165.sol";
import "./IProposalRegistry.sol";

interface IRouter is IERC165 {
    function onVote(uint256 _propId, uint256 _transId, bool _vote, bytes calldata _voteData)
        external
        returns (bytes memory);

    function textProposal(string calldata text) external view returns (string calldata);
    function getUserVars(bytes4 selector) external view returns (string[] memory);
}
