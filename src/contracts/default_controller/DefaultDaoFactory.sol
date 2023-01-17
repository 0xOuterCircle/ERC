// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./DefaultDaoController.sol";

interface IGovernanceFactory {
    function deployGovernance(
        string memory _name,
        string memory _governanceTicker,
        uint256 _governanceInitialSupply,
        address _to,
        address _dao
    ) external returns (address);
}

contract DefaultDaoFactory {

    address public owner;
    IGovernanceFactory public governanceFactory;

    // For tests
    // address[] public daos;

    constructor() {
        owner = msg.sender;
    }

    function setGovernanceFactory(address _governanceFactory) external {
        require(msg.sender == owner, "Only owner can call this function");

        governanceFactory = IGovernanceFactory(_governanceFactory);
        owner = 0x0000000000000000000000000000000000000000;
    }

    function deployDao(
        uint256 _proposalExpirationTime,
        uint256 _quorumRequired,
        address _parentRegistry,
        string memory _name,
        uint256 _governanceInitialSupply,
        string memory _governanceTicker
    ) external returns (DefaultDaoController daoController) {

        daoController = new DefaultDaoController(
            msg.sender,
            _proposalExpirationTime,
            _quorumRequired,
            IDaoController(_parentRegistry),
            _name,
            "Used only for tests.",
            address(this)
        );

        address governance = governanceFactory.deployGovernance(
            _name,
            _governanceTicker,
            _governanceInitialSupply,
            msg.sender,
            address(daoController)
        );

        daoController.setGovernance(governance);

        // For tests
        // daos.push(address(daoController));
    }
}
