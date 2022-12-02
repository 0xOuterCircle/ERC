// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "contracts/templates/UniswapRouter.sol";
import "forge-std/console.sol";

contract TestUniswapRouter is Test, UniswapRouter(ISwapRouter(address(0))) {
    function testEncodeMultihopPath() public {
        address[] memory tokenPath = new address[](3);
        tokenPath[0] = address(0);
        tokenPath[1] = address(1);
        tokenPath[2] = address(2);

        uint24[] memory feePath = new uint24[](2);
        feePath[0] = 1000;
        feePath[1] = 2000;

        bytes memory truePath = abi.encodePacked(tokenPath[0], feePath[0], tokenPath[1], feePath[1], tokenPath[2]);

        bytes memory path = _encodeMultihopPath(tokenPath, feePath);

        assertEq(path, truePath);
    }
}
