// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

interface IGovernance {
    function votingPowerOf(address _who) external returns (uint256);
}
