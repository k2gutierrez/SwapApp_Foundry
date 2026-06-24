<div align="center">
  <h1>💱 DEX Swap Application</h1>
  <p><b>A robust, fee-integrated DeFi token swap layer powered by Uniswap V2</b></p>
</div>

## 📖 About the Project

The **DEX Swap Application** is a production-ready Web3 Smart Contract project built with **Solidity** and tested/deployed using the **Foundry** framework. At its core, the project provides a seamless wrapper over the Uniswap V2 architecture (specifically utilizing the Arbitrum Mainnet environment for highly realistic test forks). 

It allows users to exchange ERC20 tokens (e.g., USDT for DAI) effortlessly while incorporating a highly efficient, transparent **fee mechanism**. This architecture is ideal for DeFi protocols, decentralized treasuries, or dApps looking to monetize their liquidity routing or user-facing swap interfaces securely.

**Key Technical Highlights:**
* **Solidity `^0.8.30`:** Leveraging the latest compiler features for maximum security and gas efficiency.
* **OpenZeppelin Contracts:** Utilizing standard `IERC20` and `SafeERC20` implementations to prevent common attack vectors and handle non-standard ERC20 token interactions flawlessly.
* **Foundry Framework:** Complete with high-speed fuzz testing, state assertions, and mainnet-fork simulations via Arbitrum RPC.

---

## ⚙️ How It Works

When a user initiates a transaction, the `SwapApp` contract calculates a predefined fee using basis points (by default `2.5%`). It retains this fee in the initial input token and routes the remainder to the **Uniswap V2 Router** to execute the decentralized exchange. The output tokens are sent directly back to the user's wallet, while the fee is safely directed to a designated `Fee Receiver` address.

### Architecture Diagram

![Project Diagram](./images/diagram.png)

[SwapApp.sol](./src/SwapApp.sol) - Main Application Logic

[IV2Router02.sol](./src/IV2Router02.sol) - Uniswap Router Interface

💻 Technical Docs
The primary interaction point of the application is the swapTokens function. It strictly handles state transfers using SafeERC20, dynamically calculates the exact fee via basis points, and interfaces with the underlying Uniswap liquidity.

swapTokens
File: src/SwapApp.sol

Solidity
function swapTokens(
    uint256 _amountIn, 
    uint256 _amountOutMin, 
    address[] memory _path, 
    uint256 _deadline
) external {
    
    // 1. Calculate the fee based on constant basis points
    uint256 fee = (_amountIn * getFeeBasisPoints()) / getPercentageBasis();
    uint256 amountIn = _amountIn - fee;

    // 2. Safely transfer the full amount from the user to this contract
    IERC20(_path[0]).safeTransferFrom(msg.sender, address(this), _amountIn);

    // 3. Approve the Uniswap V2 Router to spend the post-fee amount
    IERC20(_path[0]).approve(s_V2Router02Address, amountIn);

    // 4. Execute the swap via Uniswap V2 Router
    uint[] memory amountOut = IV2Router02(s_V2Router02Address).swapExactTokensForTokens(
        amountIn, 
        _amountOutMin, 
        _path, 
        msg.sender, 
        _deadline
    );

    // 5. Route the accumulated fee to the designated receiver vault
    IERC20(_path[0]).safeTransfer(s_FeeReceiver, fee);
    
    s_totalFeeReceived += fee;
    
    // 6. Emit on-chain logging event
    emit SwapTokens(_path[0], _path[_path.length - 1], _amountIn, amountOut[amountOut.length - 1]);
}
🚀 Execution Example
Here is a step-by-step example of how a user interacts with the SwapApp to exchange USDT for DAI.

Step 1: Setup & Deploy
The contract is deployed onto the network. During deployment, the s_V2Router02Address (Uniswap Router) and the s_FeeReceiver (e.g., a project's multisig treasury) are configured.
Current Fee is configured to 2.5% (25 / 1000 basis points).

Step 2: User Approval
The User wants to swap 100 USDT. Because USDT is an ERC20 standard token, the user must first call approve() on the USDT contract directly, granting the SwapApp contract permission to move their 100 USDT.

Step 3: Execute Swap
The user calls swapTokens on the SwapApp contract, passing in:

_amountIn: 100,000,000 (100 USDT, properly scaled to 6 decimals).

_amountOutMin: Minimum acceptable DAI out (to prevent sandwich attacks/slippage).

_path: [USDT_ADDRESS, DAI_ADDRESS].

_deadline: Unix timestamp for transaction expiration.

Step 4: Under the Hood execution

SwapApp calculates a 2.5 USDT fee from the inputs.

SwapApp safely pulls 100 USDT from the User's wallet into itself.

SwapApp approves the remaining 97.5 USDT to the Uniswap Router.

Uniswap swaps the 97.5 USDT for DAI and sends that DAI directly to the User's wallet.

SwapApp sends the 2.5 USDT fee to the configured Fee Receiver.

🧪 Testing
(Provide testing instructions or commands here)

📊 Coverage
(Provide coverage instructions or commands here)

📜 Contract Address
(Provide deployed contract addresses here)





























## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
