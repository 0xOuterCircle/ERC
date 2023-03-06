pragma solidity ^0.8.0;

import "../DaoController.sol";

interface IGovernance {
    function balanceOf(address _who) external view returns (uint256);
}

contract DefaultDaoController is DaoController {

    IGovernance public governance;
    address public factory;

    modifier onlyGovernance() {
        require(msg.sender == address(governance), "Only governance can call this function");
        _;
    }

    constructor(
        address _owner,
        uint256 _proposalExpirationTime,
        uint256 _quorumRequired,
        uint256 _totalVotingPower,
        IDaoController _parentRegistry,
        string memory _name,
        string memory _description,
        address _factory
    ) DaoController(_owner,
                    _proposalExpirationTime,
                    _quorumRequired,
                    _totalVotingPower,
                    _parentRegistry,
                    string.concat(_name, " Default DAO Controller"),
                    _description)
    {
        factory = _factory;
        _roleByName["PROPOSAL_CREATOR"] = keccak256("PROPOSAL_CREATOR");
        _roleByName["PROPOSAL_VOTER"] = keccak256("PROPOSAL_VOTER");
    }

    function setGovernance(address _governance) external {
        require(msg.sender == factory, "Only factory can call this function");
        governance = IGovernance(_governance);
    }

    function votingPowerOf(address _who) public view override returns (uint256) {
        return governance.balanceOf(_who);
    }

    function grantRolesByGovernance(address _who) external {
        _grantRole(_roleByName["PROPOSAL_CREATOR"], _who);
        _grantRole(_roleByName["PROPOSAL_VOTER"], _who);
    }

    function revokeRolesByGovernance(address _who) external {
        _revokeRole(_roleByName["PROPOSAL_CREATOR"], _who);
        _revokeRole(_roleByName["PROPOSAL_VOTER"], _who);
    }

}
