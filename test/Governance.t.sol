pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../implementation/Sample/Governance.sol";
import {GovernanceSettings} from "../implementation/ERC/IGovernance.sol";
import "../implementation/ERC/IProposalRegistry.sol";

contract GovernanceTest is Test {
    Governance governance;

    function setUp() public {
        if(address(governance) == address(0)) {
            IProposalRegistry[] memory trustedRegistries;
            GovernanceSettings memory settings = GovernanceSettings({
                proposalCreationThreshold: 100,
                minQuorum: 10,
                proposalExpiration: 10000,
                proposalDelay: 0,
                trustedRegistries: trustedRegistries
            });
            governance = new Governance("", settings);
        }
    }

    function testBalanceAfterMint() public {
        assertEq(governance.balanceOf(address(this), 0), 1000);
    }

    function testCreatingSubGovernance() public {
        address[] memory recipients = new address[](2);
        recipients[0] = address(this);
        recipients[1] = 0x43d53d331ABAe5697Bb01093beC11948D8F57f42;
        governance.subGovernance(recipients, 0, 500, new bytes(0));
        assertEq(governance.balanceOf(recipients[0], 1), 500);
        assertEq(governance.balanceOf(recipients[1], 1), 500);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }
}