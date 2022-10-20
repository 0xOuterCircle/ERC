// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IGovernance {
    function votingPowerOf(address _who) external view returns (uint256);
    function isProposalCreator(address _who) external view returns (bool);
    function isProposalVoter(address _who) external view returns (bool);
    function isProposalExecuter(address _who) external view returns (bool);
    function isSubDaoApprover(address _who) external view returns (bool);
    function isSubDaoRemover(address _who) external view returns (bool);
    function isVetoCaster(address _who) external view returns (bool);
    function isProposalExpirationTimeChanger(address _who) external view returns (bool);
    function isGovernanceChanger(address _who) external view returns (bool);
    function isParentRegistryChanger(address _who) external view returns (bool);
    function totalVotingPower() external view returns (uint256);
}
