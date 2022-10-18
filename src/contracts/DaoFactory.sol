// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "contracts/ProposalRegistry.sol";
import "contracts/Governance.sol";

contract DaoFactory {
    event DaoCreated(address indexed _proposalRegistry, address indexed _governance);

    function deployDao(
        Governance _governance,
        uint256 _proposalExpirationTime,
        uint256 _quorumRequired,
        IProposalRegistry _parentRegistry
    )
        external
        returns (ProposalRegistry registry)
    {
        Governance governance_ = address(_governance) == address(0) ? new Governance() : _governance;

        registry = new ProposalRegistry(governance_, _proposalExpirationTime, _quorumRequired, _parentRegistry);

        emit DaoCreated(address(registry), address(governance_));
    }
}
