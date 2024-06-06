## HIGH ISSUES

### [H-1] Incorrect fee calculation in `TSwapPool::getInputAmountBasedOnOutput` causes protocol to take too many tokens from users, resulting in lost fees.

**Description:** The `getInputAmountBasedOnOutput` function is intended ti calculate the amount of tokens a user should deposit given an amount of tokens of output tokens. However, the function currently miscalculates the resulting amount. When calculating the fee, it scales the amount by 10_000 instead of 1_000.

**Impact:** Protocol takes more fees than expected from users.

**Proof of Concept:**

**Recommended Mitigation:** 

## MEDIUM ISSUES

### [M-1] `TSwapPool::deposit` is missing deadline check causing transactions to complete even after the deadline 

**Description:** The `deposit` function accepts a dealine param, which according to the documentation is "The deadline for the transaction to be completed by". However, this param is never used. As a consequence, operations that add liquidity to the pool might be executed at unexpected times, in market
conditions where the deposit rate is unfavorable.

**Impact:** Transactions could be sent when market conditions are unfavorable to deposit, even when adding a deadline param.

**Proof of Concept:** The `deadline` parameter is unused.

**Recommended Mitigation:** Consider making the following change to the function.


```diff
     function deposit(
        uint256 wethToDeposit,
        uint256 minimumLiquidityTokensToMint,
        uint256 maximumPoolTokensToDeposit,
        // @audit - high! deadline not being used
        // if someone sets a deadline, lets say, next block, they could still deposit
        // IMPACT: HIGH a user who expects a deposit to fail, will go through. Severe disruption of functionality
        // LIKELIHOOD: HIGH always the case
        uint64 deadline
    )
        external
+       revertIfDeadlinePassed(deadline)
        revertIfZero(wethToDeposit)
        returns (uint256 liquidityTokensToMint)
    {

```

## LOW ISSUES

### [L-1] `TSwapPool::LiquidityAdded` event has parameter out of order

**Description:** When the `LiquidityAdded` evemt is emitted in the `TSwapPool::_addLiquidityMintAndTransfer` function, it logs values in an incorrect order. The `poolTokensToDeposit` value should go in the third parameter position, whereas the `wethToDeposit` value should go second.

**Impact:** Event emission is incorrect, leading to off-chain functions potentially malfunctioning.

**Proof of Concept:** -

**Recommended Mitigation:** 


```diff
- emit LiquidityAdded(msg.sender, poolTokensToDeposit, wethToDeposit);
+ emit LiquidityAdded(msg.sender, wethToDeposit, poolTokensToDeposit);
```


## INFORMATIONALS
### [I-1] `PoolFactory::PoolFactory_PoolDoesNotExist`is not used and should be removed

```diff
- error PoolFactory::PoolFactory_PoolDoesNotExist();
```


### [I-2] Lacking zero address checks

```diff
    constructor(address wethToken) {
+        if(wethToken == address(0)) {
+            revert();
+        }

        i_wethToken = wethToken;
    }
```

### [I-3] Missing `indexed` keyword on an events

**Description** if the event params have more than 3, its better to include the `indexed` keyword, 
  to make the EVM maching easier to query our event params, if it's only 1 or 2 params then its fine

```diff
+   event PoolCreated(address indexed tokenAddress, address indexed poolAddress);
-   event PoolCreated(address indexed tokenAddress, address indexed poolAddress);
```

### [I-4] `PoolFactory::createPool` should use `.symbol()` instead of `name()`

```diff
- string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).name());
+ string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).symbol());
```

