// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "contracts/ProposalRegistry.sol";
import "contracts/Governance.sol";

/**
 * @title This contract created just for simple DAO creation for OuterCictle MVP.
 * You can perceive it as mock contract for test purposes.
 */
contract DaoFactory {
    // ==================== EVENTS ====================

    event DaoCreated(address indexed _proposalRegistry, address indexed _governance);

    // ==================== PUBLIC FUNCTIONS ====================

    /**
     * @notice Deploy the most simple DAO ever
     * @dev Base contracts will be deployed
     * @param _governance Desired Governance address or address(0) if none
     * @param _proposalExpirationTime Time of proposals life in the DAO in sec
     * @param _quorumRequired Quorum required to accept proposals in the DAO
     * @param _parentRegistry Parent ProposalRegistry (of which the DAO will be sub-DAO of) or address(0) if none
     * @return registry Created ProposalRegistry
     */
    function deployDao(
        address _governance,
        uint256 _proposalExpirationTime,
        uint256 _quorumRequired,
        address _parentRegistry
    )
        external
        returns (ProposalRegistry registry)
    {
        Governance governance_ = _governance == address(0) ? new Governance() : Governance(_governance);

        registry =
        new ProposalRegistry(governance_, _proposalExpirationTime, _quorumRequired, IProposalRegistry(_parentRegistry));

        emit DaoCreated(address(registry), address(governance_));
    }
}
