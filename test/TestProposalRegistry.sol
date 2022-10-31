// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "contracts/ProposalRegistry.sol";
import "contracts/Router.sol";
import "contracts/Governance.sol";
import "forge-std/console.sol";

contract MockCounter {
    uint256 public value;

    function add(uint256 val) external {
        value += val;
    }
}

contract TestProposalRegistry is Test {
    Governance governance;
    ProposalRegistry registry;
    Router router;

    function setUp() public {
        governance = new Governance();
        registry = new ProposalRegistry(governance, 1 days, 228e18, ProposalRegistry(address(0)));
        router = new Router("test", "test description", "https://test.logo.url");

        governance.changeMember(address(this), true);
    }

    function testSupportInterface() public {
        bytes4 interfaceId = type(IProposalRegistry).interfaceId;
        assertTrue(registry.supportsInterface(interfaceId));
    }

    function testCreateEmptyProposal() public {
        Transaction[] memory pipeline;
        registry.createProposal(pipeline);
    }

    function testCreateProposal() public {
        MockCounter counter = new MockCounter();

        Transaction[] memory pipeline = new Transaction[](1);
        pipeline[0] = Transaction({
            to: address(counter),
            value: 0,
            data: abi.encodeWithSignature("add(uint256)", 1),
            response: bytes(""),
            transType: TransType.REGULAR
        });
        registry.createProposal(pipeline);
    }
}
