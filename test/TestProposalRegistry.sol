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

contract MockRouter is ERC165{
    uint256 public value; 

    bool public testExecuted;

    function onVote(uint256 propId, uint256 transId, VoteType vote, uint256 votingPower, bytes calldata voteData)
        external
        returns (bytes memory) {
            value += 1;
            return IProposalRegistry(msg.sender).getProposal(propId).pipeline[transId].data;
        }
    
    function testFunc(bytes32 val1, uint256 val2) external {
        testExecuted = true;
    }

    function getUserVars(bytes4 selector) external view returns (string[] memory) {}
    
    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC165) returns (bool) {
        return interfaceId == type(IRouter).interfaceId || super.supportsInterface(interfaceId);
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

    function _createProposalCounter(MockCounter counter) internal {
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

    function testCreateProposal() public {
        MockCounter mockCounter = new MockCounter();
        _createProposalCounter(mockCounter);
    }

    function testVote() public {
        MockCounter mockCounter = new MockCounter();

        _createProposalCounter(mockCounter);

        bytes[] memory none;
        registry.vote(0, VoteType.YES, none);

        assertEq(registry.getProposal(0).yesCount, 228e18);
        assertTrue(registry.getProposal(0).status == Status.ACCEPTED); 
    }

    function _createProposalRouter(MockCounter mockCounter, MockRouter mockRouter) internal {
        Transaction[] memory pipeline = new Transaction[](2);
        pipeline[0] = Transaction({
            to: address(mockCounter),
            value: 0,
            data: abi.encodeWithSignature("add(uint256)", 1),
            response: bytes(""),
            transType: TransType.REGULAR
        });

        pipeline[1] = Transaction({
            to: address(mockRouter),
            value: 0,
            data: abi.encodeWithSignature("testFunc(bytes32,uint256)", bytes32(0), 1),
            response: bytes(""),
            transType: TransType.ROUTER
        });

        registry.createProposal(pipeline);
    }

    function testCreateProposalRouter() public {
        MockCounter mockCounter = new MockCounter();
        MockRouter mockRouter = new MockRouter();
        _createProposalRouter(mockCounter, mockRouter);
    }

    function testRouterVote() public {
        MockCounter mockCounter = new MockCounter();
        MockRouter mockRouter = new MockRouter();
        _createProposalRouter(mockCounter, mockRouter);

        bytes[] memory none = new bytes[](1);
        none[0] = '';
        registry.vote(0, VoteType.YES, none);

        assertTrue(registry.getProposal(0).status == Status.ACCEPTED);
        assertTrue(mockRouter.value() == 1);
    }   

    function testCounterExecute() public {
        MockCounter mockCounter = new MockCounter();
        _createProposalCounter(mockCounter);

        bytes[] memory none = new bytes[](0);
        registry.vote(0, VoteType.YES, none);

        assertTrue(mockCounter.value() == 0);

        registry.execute(0);

        assertTrue(mockCounter.value() == 1);
    }

    function testRouterExecute() public {
        MockCounter mockCounter = new MockCounter();
        MockRouter mockRouter = new MockRouter();
        _createProposalRouter(mockCounter, mockRouter);

        bytes[] memory none = new bytes[](1);
        none[0] = '';
        registry.vote(0, VoteType.YES, none);

        assertTrue(mockCounter.value() == 0);
        assertTrue(!mockRouter.testExecuted());

        registry.execute(0);

        assertTrue(mockCounter.value() == 1);
        assertTrue(mockRouter.testExecuted());
    }
}
