// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "interfaces/IGovernance.sol";

contract Governance is IGovernance {
    function votingPowerOf(address _who) external pure returns (uint256) {
        return 228e18;
    }

    function isMember(address _who) external pure returns (bool) {
        return true;
    }
}
