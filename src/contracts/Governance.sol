// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "interfaces/IGovernance.sol";

contract Governance is IGovernance {
    mapping(address => bool) members;
    mapping(address => uint256) powers;

    function votingPowerOf(address _who) external pure returns (uint256) {
        return 228e18;
    }

    function isProposalCreator(address _who) external pure returns (bool) {
        return true;
    }

    function isProposalVoter(address _who) external pure returns (bool) {
        return true;
    }

    function isProposalExecuter(address _who) external pure returns (bool) {
        return true;
    }

    function isSubDaoApprover(address _who) external pure returns (bool) {
        return true;
    }

    function isSubDaoRemover(address _who) external pure returns (bool) {
        return true;
    }

    function isVetoCaster(address _who) external pure returns (bool) {
        return true;
    }

    function isProposalExpirationTimeChanger(address _who) external pure returns (bool) {
        return true;
    }

    function isGovernanceChanger(address _who) external pure returns (bool) {
        return true;
    }

    function isParentRegistryChanger(address _who) external pure returns (bool) {
        return true;
    }

    function totalVotingPower() external pure returns (uint256) {
        return 228e18;
    }

    function changeMember(address who, bool to) external {
        members[who] = to;
    }

    function changePower(address who, uint256 to) external {
        powers[who] = to;
    }
}
