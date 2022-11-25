// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "contracts/DaoController.sol";

/**
 * @title This contract created just for simple DAO creation for OuterCictle MVP.
 * You can perceive it as mock contract for test purposes.
 */
contract DaoFactory {
    // ==================== PUBLIC FUNCTIONS ====================

    /**
     * @notice Deploy the most simple DAO ever
     * @dev Base contracts will be deployed
     * @param _proposalExpirationTime Time of proposals life in the DAO in sec
     * @param _quorumRequired Quorum required to accept proposals in the DAO
     * @param _parentRegistry Parent DaoController (of which the DAO will be sub-DAO of) or address(0) if none
     * @return daoController Created DaoController
     */
    function deployDao(uint256 _proposalExpirationTime, uint256 _quorumRequired, address _parentRegistry)
        external
        returns (DaoController daoController)
    {
        daoController =
            new DaoController(msg.sender, _proposalExpirationTime, _quorumRequired, IDaoController(_parentRegistry));
    }
}
