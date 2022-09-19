// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import 'src/interfaces/IRouter.sol';

abstract contract DAOControlled {

    IRouter router;
    constructor(IRouter _router) {
        router = _router;
    }

    modifier onlyRegistry {
        require(msg.sender == address(router), "ONLY_REGISTRY");
        _;
    }

    function onVote(bytes calldata _data) external virtual onlyRegistry() {

    }

    function getVoteResult() public view virtual {

    }
}