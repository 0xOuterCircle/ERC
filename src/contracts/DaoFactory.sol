// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "contracts/ProposalRegistry.sol";
import "contracts/Governance.sol";

contract DaoFactory {
    event DaoCreated(address indexed _proposalRegistry, address indexed _governance);

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
