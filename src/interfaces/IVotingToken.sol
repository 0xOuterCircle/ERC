// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

interface IVotingToken {
    function balanceOfAt(address _who, uint256 _blockNumber) external returns(uint256);
}