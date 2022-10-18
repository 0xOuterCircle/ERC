// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "contracts/DaoFactory.sol";
import "forge-std/console.sol";

contract TestUniswapRouter is Test, DaoFactory {
    DaoFactory daoFactory;

    function setUp() public {
        daoFactory = new DaoFactory();
    }

    function testDeployDao() public {
        ProposalRegistry res = daoFactory.deployDao(Governance(address(0)), 3600, 228, ProposalRegistry(address(0)));
        assertFalse(address(res) == address(0));
    }
}
