pragma solidity ^0.8.16;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "../ERC/IGovernance.sol";
import "../ERC/Proposal.sol";

contract Governance is ERC165, ERC1155, IGovernance {

    //// Governance Settings ////
    GovernanceSettings settings;

    //// Mappings ////

    mapping(uint256 => uint256) structure;
    mapping(uint256 => mapping(address => uint256)) availableVp; // id => member => VP
    mapping(uint256 => mapping(address => uint256)) availableBalance; // id => member => VP
    mapping(uint256 => mapping(address => mapping(address => uint256))) delegated; // id => staker => delegatee => VP
    mapping(uint256 => uint256) totalVp; // id => totalVp

    //// Functions ////

    //// Constructor ////

    constructor(string memory uri_) ERC1155(uri_) {}

    //// ERC165 ////

    // TODO check override
    function supportsInterface(bytes4 interfaceId) public view override(ERC165, ERC1155) returns (bool) {
        return interfaceId == type(IGovernance).interfaceId || super.supportsInterface(interfaceId);
    }

    //// ERC1155 ////

    function subGovernance(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        require(votingPower(tx.origin) >= settings.proposalCreationThreshold);
    }

    //// ERC1155 Overrides ////

    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return availableBalance[id][account];
    }

    //// IGovernance - getters ////

    function parent(uint256 id_) external view returns (address, uint256) {
        return (address(this), structure[id_]);
    }

    function votingPower(address member, uint256 id) public view returns (uint256) {
        return availableVp[id][member];
    }

    function totalVotingPower(uint256 id) external view returns (uint256) {
        return totalVp[id];
    }

    function governanceSettings() external view returns (GovernanceSettings memory) {
        return settings;
    }

    function totalTrustedRegistries() external view returns (uint256) {
        return settings.trustedRegistries.length;
    }

    function trustedRegistry(uint256 registryId) external view returns (IProposalRegistry) {
        return settings.trustedRegistries[registryId];
    }

    //// IGovernance - Managing Settings ////

    // TODO mechanics
    function updateSettings(GovernanceSettings memory newSettings) external {
        settings = newSettings;
    }

    //// Managing Voting Power ////

    function stakeFor(address staker, address delegatee, uint256 amount, uint256 id) external {

        require(availableBalance[id][staker] >= amount);

        availableVp[id][delegatee] += amount;
        availableBalance[id][staker] -= amount;
        delegated[id][staker][delegatee] += amount;
    }

    // TODO count Proposals in which delegatee participated
    function unstakeFor(address staker, address delegatee, uint256 amount, uint256 id) external {

        require(delegated[id][staker][delegatee] >= amount);

        availableVp[id][delegatee] -= amount;
        availableBalance[id][staker] += amount;
        delegated[id][staker][delegatee] -= amount;
    }

    //// Proposals management ////

    function registerProposal(uint256 registryId, Proposal memory proposal, uint256 id) external returns (uint256 id_) {
        IProposalRegistry registry = settings.trustedRegistries[registryId];

        require(address(registry) != address(0));
        require(votingPower(msg.sender, id) >= settings.proposalCreationThreshold);

        return registry.registerProposal(proposal);
    }

    function executeProposal(uint256 registryId, uint256 proposalId) external returns (bool success) {
        IProposalRegistry registry = settings.trustedRegistries[registryId];

        require(address(registry) != address(0));
        return registry.executeProposal(proposalId);
    }

    function vote(uint256 registryId, uint256 proposalId, uint256 vp) external {
        IProposalRegistry registry = settings.trustedRegistries[registryId];

        require(address(registry) != address(0));
        registry.vote(proposalId, vp);
    }

    //// Hooks ////
    // Must be run by IProposalRegistry

    function proposalCompleted(uint256 proposalId) external {
        require(true);
    }

}
