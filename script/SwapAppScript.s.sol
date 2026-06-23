// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SwapApp} from "../src/SwapApp.sol";

contract SwapAppScript is Script {
    SwapApp public swapApp;

    address public addressUniSwapRouterV2 = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address public feeReceiver = makeAddr("FEE_RECEIVER");

    // function setUp() public {}

    function run() public returns(SwapApp, address) {
        vm.startBroadcast();

        swapApp = new SwapApp(addressUniSwapRouterV2, feeReceiver);

        vm.stopBroadcast();

        return (swapApp, addressUniSwapRouterV2);
    }
}
