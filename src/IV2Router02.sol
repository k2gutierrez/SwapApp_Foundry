// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

interface IV2Router02 {

    /**
     * @dev Uniswap function to swap exact tokens for other tokens
     * @param amountIn Input Amount
     * @param amountOutMin Minimum amount Out
     * @param path Array of token address for the swap
     * @param to Address to send the tokens
     * @param deadline Time allowed to expect for the swap
     * @return amounts Array of amounts
     */
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
}