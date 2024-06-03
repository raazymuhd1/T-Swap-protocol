// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { TSwapPool } from "../../src/TSwapPool.sol";
import { ERC20Mock } from "../mocks/ERC20Mock.sol";

contract Handler is Test {
    TSwapPool pool;
    ERC20Mock weth;
    ERC20Mock poolToken; // any token u want to add to the lp pool; (its not LP token)

    address liquidityProvider = makeAddr("LP");
    address swapper = makeAddr("swapper");

    // Ghost Variables (bcoz they dont exist the actual pool contract, only exist in this handler)
    int256 public startingX;
    int256 public startingY;

    int256 public expectedDeltaX;
    int256 public expectedDeltaY;
    int256 public actualDeltaY;
    int256 public actualDeltaY;


    constructor(TSwapPool _pool) {
        pool = _pool;
        weth = ERC20Mock(pool.getWeth());
        poolToken = ERC20Mock(pool.getPoolToken());
    }


    function deposit(uint256 wethAmount) public {
        uint256 minWeth = pool.getMinimumWethDepositAmount();
        wethAmount = bound(wethAmount, minWeth, type(uint64).max);

        startingX = int256(weth.balanceOf(address(this)));
        startingY = int256(poolToken.balanceOf(address(this)));
        expectedDeltaX = int256(wethAmount);
        expectedDeltaY = int256(pool.getPoolTokensToDepositBasedOnWeth(wethAmount));

        vm.startPrank(liquidityProvider);
        weth.mint(liquidityProvider, wethAmount);
        poolToken.mint(liquidityProvider, expectedDeltaX);
        weth.approve(address(pool), type(uint256).max);
        poolToken.approve(address(pool), type(uint256).max);
        // add liquidity with deposit function
        pool.deposit(wethAmount, 0, uint256(expectedDeltaX), uint64(block.timestamp));
        vm.stopPrank();

        uint256 endingY = weth.balanceOf(address(this));  
        uint256 endingX = poolToken.balanceOf(address(this));

        actualDeltaY = int256(endingY) - int256(startingY);
        actualDeltaX = int256(endingX) - int256(startingX);
    }

    function swapPoolTokenForWethBasedOnOuputWeth(uint256 outputWeth) public {
        uint256 minWeth = pool.getMinimumWethDepositAmount();
        outputWeth = bound(outputWeth, minWeth, type(uint64).max);

        // if the output weth greater than the amount on the pool, revert;
        if(outputWeth >= weth.balanceOf(address(this))) {
            return;
        }

        // Dx = (B/(1-B)) * x
        uint256 poolTokenAmount = pool.getInputAmountBasedOnOutput(
            outputWeth,
            poolToken.balanceOf(address(pool)),
            weth.balanceOf(address(pool))
        );

        if(poolTokenAmount > type(uint64).max) return;

        startingX = int256(weth.balanceOf(address(this)));
        startingY = int256(poolToken.balanceOf(address(this)));
        expectedDeltaX = uint256(-1) * int256(outputWeth);
        expectedDeltaY = int256(pool.getPoolTokensToDepositBasedOnWeth(poolTokenAmount));

        if(poolToken.balanceOf(swapper) < poolTokenAmount) {
            poolToken.mint(swapper, poolToken - poolToken.balanceOf(swapper) + 1);
        }

        vm.startPrank(swapper);
        poolToken.approve(address(pool), type(uint256).max);
        // input token and retrieve WETH
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        vm.stopPrank();


        uint256 endingY = weth.balanceOf(address(this));  
        uint256 endingX = poolToken.balanceOf(address(this));

        actualDeltaY = int256(endingY) - int256(startingY);
        actualDeltaX = int256(endingX) - int256(startingX);
    }

}