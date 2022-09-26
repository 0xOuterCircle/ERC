// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "openzeppelin/utils/introspection/IERC165.sol";

interface IRouter is IERC165 {
    function onVote(
        uint256 propId,
        uint256 transId,  // id of Transaction related to current IRouter in pipeline
        bool vote,  // Vote decision: 0 -- neutral, 1 -- yes, 2 -- no
        bytes calldata voteData  // arbitrary vote data 
    ) external returns(bytes memory); 
}