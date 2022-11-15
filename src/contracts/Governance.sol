// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "interfaces/IGovernance.sol";

/**
 * @title Mock Governance contract which allows everyone everything to do.
 * All addresses have all roles and voting somewhat voting power.
 * This contract exists for test purposes.
 */
contract Governance is IGovernance {
    // ==================== STORAGE ====================

    mapping(address => bool) members; // members of the DAO
    mapping(address => uint256) powers; // members voting powers

    // ==================== PUBLIC FUNCTIONS ====================

    /**
     * @notice Voting power of a member
     * @dev If DAO has a governance token, this function should return the token balances
     * @param _who Address to check power of
     * @return Voting power
     */
    function votingPowerOf(address _who) external pure returns (uint256) {
        return 228e18;
    }

    /**
     * @notice Check for proposalCreator role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isProposalCreator(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Check for proposalVoter role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isProposalVoter(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Check for proposalExecuter role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isProposalExecuter(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Check for subDaoApprover role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isSubDaoApprover(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Check for subDaoRemover role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isSubDaoRemover(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Check for vetoCaster role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isVetoCaster(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Check for proposalExpirationTimeChanger role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isProposalExpirationTimeChanger(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Check for governanceChanger role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isGovernanceChanger(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Check for parentRegistryChanger role
     * @param _who Address to check role of
     * @return Does the user have a role or not
     */
    function isParentRegistryChanger(address _who) external pure returns (bool) {
        return true;
    }

    /**
     * @notice Voting power of all members in total
     * @dev If DAO has governance token, this function sould return totalSupply() of the token
     * @return Total voting power
     */
    function totalVotingPower() external pure returns (uint256) {
        return 228e18;
    }

    // ==================== MOCK FUNCTIONS ====================

    /**
     * @dev Add or remove member from DAO
     */
    function changeMember(address who, bool to) external {
        members[who] = to;
    }

    /**
     * @dev Change member voting power
     */
    function changePower(address who, uint256 to) external {
        powers[who] = to;
    }
}
