pragma solidity ^0.8.0;

import "../DaoController.sol";
import "./DefaultGovernance.sol";

contract DefaultDaoController is DaoController {

    DefaultGovernance public governance;

    modifier onlyGovernance() {
        require(msg.sender == address(governance), "Only governance can call this function");
        _;
    }

    constructor(
        address _owner,
        uint256 _proposalExpirationTime,
        uint256 _quorumRequired,
        IDaoController _parentRegistry,
        string memory _name,
        string memory _description,
        uint256 _governanceInitialSupply,
        string memory _governanceTicker
    ) DaoController(_owner, _proposalExpirationTime, _quorumRequired, _parentRegistry, string.concat(_name, " Default DAO Controller"), _description) {

        governance = new DefaultGovernance(
            string.concat(_name, " Governance"),
            _governanceTicker,
            _governanceInitialSupply,
            address(this)
        );

        _roleByName["PROPOSAL_CREATOR"] = keccak256("PROPOSAL_CREATOR");
        _roleByName["PROPOSAL_VOTER"] = keccak256("PROPOSAL_VOTER");
    }

    function votingPowerOf(address _who) public view override returns (uint256) {
        return governance.balanceOf(_who);
    }

    function grantRolesByGovernance(address _who) public onlyGovernance {
        _grantRole(_roleByName["PROPOSAL_CREATOR"], _who);
        _grantRole(_roleByName["PROPOSAL_VOTER"], _who);
    }

    function revokeRolesByGovernance(address _who) public onlyGovernance {
        _revokeRole(_roleByName["PROPOSAL_CREATOR"], _who);
        _revokeRole(_roleByName["PROPOSAL_VOTER"], _who);
    }

}
