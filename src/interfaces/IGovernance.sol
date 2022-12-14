// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IGovernance {
    function votingPowerOf(address _who) external returns (uint256);
    function isMember(address _who) external returns (bool);
}
