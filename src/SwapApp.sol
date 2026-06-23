// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IV2Router02} from "./IV2Router02.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SwapApp {

    using SafeERC20 for IERC20;

    address public s_V2Router02Address;
    address public s_FeeReceiver;

    uint256 private s_totalFeeReceived;
    uint256 private constant PERCENTAGE_BASIS = 1000;
    uint256 private s_feeBasisPoints = 25; // basis of 1000 e.g., 25 = 2.5% (amount * s_feeBasisPoints / PERCENTAGE_BASIS)

    event SwapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    constructor(address _V2Router02Address, address _feeReceiver) {
        s_V2Router02Address = _V2Router02Address;
        s_FeeReceiver = _feeReceiver;
    }

    function swapTokens(uint256 _amountIn, uint256 _amountOutMin, address[] memory _path, uint256 _deadline) external {
        
        uint256 fee = (_amountIn * getFeeBasisPoints()) / getPercentageBasis();
        uint256 amountIn = _amountIn - fee;

        IERC20(_path[0]).safeTransferFrom(msg.sender, address(this), _amountIn);

        IERC20(_path[0]).approve(s_V2Router02Address, amountIn);

        uint[] memory amountOut = IV2Router02(s_V2Router02Address).swapExactTokensForTokens(amountIn, _amountOutMin, _path, msg.sender, _deadline);

        IERC20(_path[0]).safeTransfer(s_FeeReceiver, fee);
        
        s_totalFeeReceived += fee;
        
        emit SwapTokens(_path[0], _path[_path.length - 1], _amountIn, amountOut[amountOut.length - 1]);
    }

    function getTotalFeeReceived() external view returns(uint256 totalFeeReceived) {
        totalFeeReceived = s_totalFeeReceived;
    }

    function getFeeBasisPoints() public view returns(uint256 feeBasisPoints) {
        feeBasisPoints = s_feeBasisPoints;
    }

    function getPercentageBasis() public pure returns(uint256 percentageBasis) {
        percentageBasis = PERCENTAGE_BASIS;
    }
    
}
