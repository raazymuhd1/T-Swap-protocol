// SPDX-Licenses-Identifier: MIT;
pragma solidity 0.8.20;


import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { ERC20Mock } from "../mocks/ERC20Mock.sol";
import { PoolFactory } from "../../src/PoolFactory.sol";
import { TSwapPool } from "../../src/TSwapPool.sol";
import { Handler } fron "./Handler.t.sol";

contract Invariant is StdInvariant, Test {
    ERC20Mock poolToken; // any token u want to deposit on liquidity pool
    ERC20Mock weth;
    Handler handler;

    PoolFactory factory;
    TSwapPool pool;

    int256 constant STARTING_X = 100e18;
    int256 constant STARTING_Y = 50e18;

    function setUp() public {
        weth = new ERC20Mock();
        poolToken = new ERC20Mock();
        factory = new PoolFactory();
        pool = TSwapPool(factory.createPool(address(weth)));

        // minting the pool token and weth into this contract
        poolToken.mint(address(this), uint256(STARTING_X));
        weth.mint(address(this), uint256(STARTING_Y));

        // approving the pool token and weth to the pool
        poolToken.approve(address(pool), type(uint256).max);
        weth.approve(address(pool), type(uint256).max);

        // add liquidity by calling deposit function
        pool.deposit(uint256(STARTING_Y), uint256(STARTING_Y), uint256(STARTING_X), uint64(block.timestamp));

        handler = new Handler();
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.deposit.selector;
        selectors[1] = handler.swapPoolTokenForWethBasedOnOuputWeth.selector;

        targetSelector(FuzzSelector({ addr: address(handler), selectors: selectors }));
        targetContract(address(handler));
    }


    function statefulFuzz_constantProductFormulaStaysTheSame() public {
        // the change in the pool size of WETH should follow this function
        // Dx = (B/(1-B)) * x
        // actual deltaX == Dx = (B/(B-1)) * x
        assertEq(handler.actualDeltaX, handler.expectedDeltaX);
    }
}