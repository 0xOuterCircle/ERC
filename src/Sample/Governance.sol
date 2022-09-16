pragma solidity 0.8.17;
import "solmate/tokens/ERC1155.sol";
import "../ERC/IGovernance.sol";
import "../ERC/Proposal.sol";

contract Governance is ERC1155, IGovernance {

    //// ERC1155 ////
    string private _uri;
    uint256 public lastId = 0;

    //// Governance Settings ////
    GovernanceSettings public settings;

    //// Mappings ////

    mapping(uint256 => uint256) structure;
    mapping(address => mapping(uint256 => uint256)) availableVp; // member => id =>  VP
    mapping(address => mapping(address => mapping(uint256 => uint256))) delegated; // staker => delegatee => id => VP
    mapping(uint256 => uint256) totalVp; // id => totalVp

    //// Functions ////

    //// Constructor ////

    constructor(string memory uri_, GovernanceSettings memory settings_) {
        _uri = uri_;
        settings = settings_;
        ERC1155._mint(
            msg.sender,
            0,
            1000,
            new bytes(0)
        );
    }

    //// ERC165 ////

    // TODO check override
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IGovernance).interfaceId || super.supportsInterface(interfaceId);
    }

    //// ERC1155 ////

    function uri(uint256 id) public view override returns (string memory) {
        return _uri;
    }

    // TODO
    function subGovernance(
        address[] memory to,
        uint256 parentId,
        uint256 amount,
        bytes calldata data
    ) public {
        uint256 balance = ERC1155.balanceOf[msg.sender][parentId];
        require(balance >= settings.proposalCreationThreshold, "qwert");
        lastId += 1;
        structure[parentId] = lastId;
        for (uint256 i = 0; i < to.length; i += 1) ERC1155._mint(to[i], lastId, amount, data);
    }

    //// IGovernance - getters ////

    function parent(uint256 id_) external view returns (address, uint256) {
        return (address(this), structure[id_]);
    }

    function votingPower(address member, uint256 id) public view returns (uint256) {
        return availableVp[member][id];
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

    function stakeFor(address staker, address delegatee, uint256 amount, uint256 id, bytes calldata data) external {

        require(ERC1155.balanceOf[staker][id] >= amount);

        availableVp[delegatee][id] += amount;
        delegated[staker][delegatee][id] += amount;
        ERC1155.safeTransferFrom(staker, address(this), id, amount, data);
    }

    // TODO count Proposals in which delegatee participated
    function unstakeFor(address staker, address delegatee, uint256 amount, uint256 id, bytes calldata data) external {

        require(delegated[staker][delegatee][id] >= amount);

        availableVp[delegatee][id] -= amount;
        delegated[staker][delegatee][id] -= amount;
        ERC1155.safeTransferFrom(address(this), staker, id, amount, data);
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

    // TODO
    function proposalCompleted(uint256 proposalId) external {
        require(true);
    }

}
