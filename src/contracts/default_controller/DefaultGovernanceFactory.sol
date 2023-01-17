// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./DefaultGovernance.sol";

contract DefaultGovernanceFactory {

    address public daoFactory;

    constructor(address _daoFactory) {
        daoFactory = _daoFactory;
    }

    function deployGovernance(
        string memory _name,
        string memory _governanceTicker,
        uint256 _governanceInitialSupply,
        address _to,
        address _dao
    ) external returns (address) {
        require(msg.sender == daoFactory, "Only DaoFactory can call this function");

        return address(new DefaultGovernance(
            string.concat(_name, " Governance"),
            _governanceTicker,
            _governanceInitialSupply,
            _to,
            _dao
        ));
    }

}
