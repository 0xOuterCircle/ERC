// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "contracts/ProposalRegistry.sol";
import "contracts/Router.sol";
import "forge-std/console.sol";

contract MockGovernance is IGovernance {
    mapping(address => bool) members;
    mapping(address => uint256) powers;

    function votingPowerOf(address who) external view returns (uint256) {
        return powers[who];
    }

    function isMember(address who) external view returns (bool) {
        return members[who];
    }

    function changeMember(address who, bool to) external {
        members[who] = to;
    }

    function changePower(address who, uint256 to) external {
        powers[who] = to;
    }
}

contract MockCounter {
    uint256 public value;

    function add(uint256 val) external {
        value += val;
    }
}

contract TestProposalRegistry is Test {
    MockGovernance governance;
    ProposalRegistry registry;
    Router router;

    function setUp() public {
        governance = new MockGovernance();
        registry = new ProposalRegistry(governance, 1 days);
        router = new Router("test", "test description", "https://test.logo.url");

        governance.changeMember(address(this), true);
    }

    function testSupportInterface() public {
        bytes4 interfaceId = type(IProposalRegistry).interfaceId;
        assertTrue(registry.supportsInterface(interfaceId));
    }

    function testCreateEmptyProposal() public {
        Transaction[] memory pipeline;
        registry.createProposal(0, pipeline);
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
        registry.createProposal(0, pipeline);
    }
}
