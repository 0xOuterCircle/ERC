// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

interface IDdApp {
    function actionsTotal() external view returns (uint256);

    // Add hidden params
    function actionData(
        uint256 actionId
    ) external view returns (
        string memory actionSignature,
        string[] memory paramsInternal,
        string[] memory paramsPublic,
        string[] memory labels
    );

    function voteFor(
        uint256 actionId,
        uint256 votedVp,
        uint256 totalVp,
        bytes[] memory paramsInternal,
        bytes[] memory paramsPublic,
        bytes[] memory paramsVoted
    ) external returns (string[] memory updParamsInternal, string[] memory updParamsPublic);
}