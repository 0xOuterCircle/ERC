// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./IDaoController.sol";

interface IOuterCircleApp is IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
