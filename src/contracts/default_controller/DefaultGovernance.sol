pragma solidity ^0.8.0;

import "../../../lib/solmate/src/tokens/ERC20.sol";

interface IDefaultDaoController {
    function grantRolesByGovernance(address who) external;
    function revokeRolesByGovernance(address who) external;
}

contract DefaultGovernance is ERC20 {

    IDefaultDaoController public dao;

    constructor(
        string memory name,
        string memory ticker,
        uint256 initialSupply,
        address _dao
    ) ERC20(name, ticker, 0) {
        _mint(msg.sender, initialSupply);
        dao = IDefaultDaoController(_dao);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        ERC20.transfer(to, amount);
        manageDaoRoles(to);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        ERC20.transferFrom(from, to, amount);
        manageDaoRoles(from);
        manageDaoRoles(to);

        return true;
    }

    function manageDaoRoles(address who) private {
        if(balanceOf[who] > 0) {
            dao.grantRolesByGovernance(who);
        } else {
            dao.revokeRolesByGovernance(who);
        }
    }

}
