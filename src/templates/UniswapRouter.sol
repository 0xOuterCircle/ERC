// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "contracts/Router.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

/**
 * @title This Router performs different swaps in Uniswap's SwapRouter
 */
contract UniswapRouter is Router {
    mapping(bytes32 => Session) private sessions;

    ISwapRouter public immutable swapRouter;

    struct Session {
        uint256 totalAmount;
        uint256 totalVotes;
    }

    constructor(ISwapRouter _swapRouter)
        Router("Average Router", "This is an example description", "https://link.to.my.logo.com")
    {
        swapRouter = _swapRouter;
    }

    function _processVote(
        bytes32 _sessionId,
        Proposal memory prop,
        Transaction memory trans,
        VoteType _vote,
        uint256 _votePower,
        bytes calldata _voteData
    )
        internal
        override
        returns (bytes memory)
    {
        Session storage session = sessions[_sessionId];
        if (_vote == VoteType.YES) {
            uint256 amount_ = abi.decode(_voteData, (uint256)); // _voteData must be encoded uint256
            session.totalAmount += amount_ * _votePower;
            session.totalVotes += _votePower;
        }

        uint256 averageTotalValue_ = session.totalAmount / session.totalVotes;
        return abi.encode(averageTotalValue_);
    }

    // ================ EXECUTIVE FUNCTIONS ================

    function swapExactInputSingle(address _tokenIn, address _tokenOut, uint24 _poolFee, uint256 _amountIn)
        external
        returns (uint256 amountOut_)
    {
        TransferHelper.safeTransferFrom(_tokenIn, msg.sender, address(this), _amountIn);

        TransferHelper.safeApprove(_tokenIn, address(swapRouter), _amountIn);

        ISwapRouter.ExactInputSingleParams memory params_ = ISwapRouter.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: _poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        amountOut_ = swapRouter.exactInputSingle(params_);
    }

    function swapExactOutputSingle(
        address _tokenIn,
        address _tokenOut,
        uint24 _poolFee,
        uint256 _amountOut,
        uint256 _amountInMaximum
    )
        external
        returns (uint256 amountIn_)
    {
        TransferHelper.safeTransferFrom(_tokenIn, msg.sender, address(this), _amountInMaximum);

        TransferHelper.safeApprove(_tokenIn, address(swapRouter), _amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params_ = ISwapRouter.ExactOutputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: _poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountOut: _amountOut,
            amountInMaximum: _amountInMaximum,
            sqrtPriceLimitX96: 0
        });

        amountIn_ = swapRouter.exactOutputSingle(params_);

        if (amountIn_ < _amountInMaximum) {
            TransferHelper.safeApprove(_tokenIn, address(swapRouter), 0);
            TransferHelper.safeTransfer(_tokenIn, msg.sender, _amountInMaximum - amountIn_);
        }
    }

    function swapExactInputMultihop(address[] calldata _tokenPath, uint24[] calldata _swapFeePath, uint256 _amountIn)
        external
        returns (uint256 amountOut_)
    {
        require(_tokenPath.length == _swapFeePath.length + 1, "ROUTER::TokenPath and SwapFeePath lengths mismatch");

        TransferHelper.safeTransferFrom(_tokenPath[0], msg.sender, address(this), _amountIn);

        TransferHelper.safeApprove(_tokenPath[0], address(swapRouter), _amountIn);

        bytes memory path_ = _encodeMultihopPath(_tokenPath, _swapFeePath);

        ISwapRouter.ExactInputParams memory params_ = ISwapRouter.ExactInputParams({
            path: path_,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum: 0
        });

        amountOut_ = swapRouter.exactInput(params_);
    }

    function swapExactOutputMultihop(
        address[] calldata _tokenPath,
        uint24[] calldata _swapFeePath,
        uint256 _amountOut,
        uint256 _amountInMaximum
    )
        external
        returns (uint256 amountIn_)
    {
        TransferHelper.safeTransferFrom(_tokenPath[0], msg.sender, address(this), _amountInMaximum);

        TransferHelper.safeApprove(_tokenPath[0], address(swapRouter), _amountInMaximum);

        bytes memory path_ = _encodeMultihopPath(_tokenPath, _swapFeePath);

        ISwapRouter.ExactOutputParams memory params_ = ISwapRouter.ExactOutputParams({
            path: path_,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountOut: _amountOut,
            amountInMaximum: _amountInMaximum
        });

        amountIn_ = swapRouter.exactOutput(params_);

        if (amountIn_ < _amountInMaximum) {
            TransferHelper.safeApprove(_tokenPath[0], address(swapRouter), 0);
            TransferHelper.safeTransferFrom(_tokenPath[0], address(this), msg.sender, _amountInMaximum - amountIn_);
        }
    }

    function _encodeMultihopPath(address[] memory _tokenPath, uint24[] memory _swapFeePath)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory path_ = abi.encodePacked(_tokenPath[0]);
        for (uint256 i = 0; i < _tokenPath.length - 1; ++i) {
            path_ = abi.encodePacked(path_, _swapFeePath[i], _tokenPath[i + 1]);
        }
        return path_;
    }
}
