// SPDX-License-Identifier: MIT
// forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc
// forge coverage --fork-url https://arb1.arbitrum.io/rpc
// chainlist.org

pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SwapApp} from "../src/SwapApp.sol";
import {SwapAppScript} from "../script/SwapAppScript.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapAppTest is Test {
    SwapApp public swapApp;
    address public addressUniSwapRouterV2;
    address public feeReceiver;
    address public user = makeAddr("user");
    address public USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9; // 6 decimals USDT address un arbitrum mainnet
    address public DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1; // 18 decimals DAI address un arbitrum mainnet

    // starting parameters
    uint256 constant feeReceived = 0;
    uint256 constant PERCENTAGE_BASIS = 1000;
    uint256 constant feeBasisPoints = 25;

    function setUp() public {
        SwapAppScript deployer = new SwapAppScript();
        (swapApp, addressUniSwapRouterV2) = deployer.run();
        feeReceiver = swapApp.s_FeeReceiver();
        deal(USDT, user, 2000 * 1e6, true);
    }

    function testHasBeenDeployedCorrectly() public view {
        assert(swapApp.s_V2Router02Address() == addressUniSwapRouterV2);
        assert(swapApp.s_FeeReceiver() == feeReceiver);
        assert(swapApp.getFeeBasisPoints() == feeBasisPoints);
        assert(swapApp.getPercentageBasis() == PERCENTAGE_BASIS);
        assert(swapApp.getTotalFeeReceived() == feeReceived);
    }

    

    function testSwapTokensCorrectly() public {
        vm.startPrank(user);
        uint256 amountIn = 100e6; // smart contract of USDT in arbitrum has 6 decimals
        uint256 fee = (amountIn * swapApp.getFeeBasisPoints()) / swapApp.getPercentageBasis();
        uint256 amountOutMin = (((amountIn - fee) * 1e18) / 1e6) - 1e18; // smart contract of DAI has 18 decimals in arbitrum
        

        IERC20(USDT).approve(address(swapApp), amountIn);
        uint256 _deadline = block.timestamp + 4 minutes;
        address[] memory _path = new address[](2);
        _path[0] = USDT;
        _path[1] = DAI;

        uint256 usdtBalanceBefore = IERC20(USDT).balanceOf(user);
        uint256 daiBalanceBefore = IERC20(DAI).balanceOf(user);
        console2.log("DAI Before: ", daiBalanceBefore);
        swapApp.swapTokens(amountIn, amountOutMin, _path, _deadline);
        uint256 usdtBalanceAfter = IERC20(USDT).balanceOf(user);
        uint256 daiBalanceAfter = IERC20(DAI).balanceOf(user);
        console2.log("DAI After: ", daiBalanceAfter);

        assert(usdtBalanceAfter == usdtBalanceBefore - amountIn);
        assert(daiBalanceAfter > daiBalanceBefore);
        assert(IERC20(USDT).balanceOf(swapApp.s_FeeReceiver()) == fee);

        vm.stopPrank();
    }
    
}
