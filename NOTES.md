<!-- VIDEO STOP AT 12.19.01 -->

## Keynote
 - Invariant Test is good when u are on private audit, but its just waste of time for competitive audit

## Makefile Docs
    - [Makefile Docs](https://makefiletutorial.com/)

## How to generate report.md to report.pdf file
 - run this command `pandoc file-path -o fileOutput.pdf --from markdown --template=eisvogel --listings`

## Invariants ( also known as stateful fuzzing )
  - `stateful` fuzzing is where the final state of your previous run on the same function is the starting state of your next run ( basically it will use the same contract, not started from scratch like stateless fuzz ). 
   `Stateful testing` keeps track of changes made by previous calls, allowing us to test invariants, which are properties of the system that must always hold. This type of testing is different from stateless testing, where the state is discarded after each test. after each function call is performed, all invariants are asserted.
   In a nutshell, `stateful fuzz` purposes is to check our system `invariant` didn't break. state of the previous run on the same function is not discarded.

  - `invariants` - a property that our system should always hold  

**Invariants** A property of our system should always hold (ex: contract balance should always more than 0)
- in `foundry.toml` file we can change `runs (the number of times of random input that foundry will try to pass in)` property to whatever number we want (ex: 1000) under `[fuzz]`
- `invariants / stateful fuzz` test will call all of our function inside our contract randomly and passes a     random data to each one of the function.
- the function name should starts with `invariant` following by function name.
- Test contract should be inherited from `StdInvariant` contract provided by foundry.    
- 

## Resources to learn more about `AMM`
 - [chainlink AMM](https://chain.link/education-hub/what-is-an-automated-market-maker-amm)
  

## What I've learn so far in this lesson
   - `Invariant Test` or a stateful fuzzing
      - `open stateful fuzzing` with no guard or limit a function inputs.
      - `handler stateful fuzzing` limit the input to some values
      - always set `fail_on_revert` to true is a better, so that it will fail when reverted
      - `handler` contract acts like a proxy contract `Test contract => Handler Contract => Our Contract`
      - `Invariant` contract will interact with handler contract for fuzzing test our contract
   - `AMM` - an automated market maker
 

  ## 5 Types of smart contract upgrading mmechanism
  -  `Contract migration`
  -  `Data separation`
  -  `Proxy patterns`
  -  `Strategy pattern`
  -  `Diamond pattern`
  
  ## CONSIDERATIONS FOR UPGRADING SMART CONTRACTS
  - use multisig wallet to control upgrades or requiring members of a DAO to vote on approving the upgrade.
  - Consider implementing timelocks to protect users. A timelock refers to a delay enforced on changes to a system. Timelocks can be combined with a multi-sig governance system to control upgrades: if a proposed action reaches the required approval threshold, it doesn't execute until the predefined delay period elapses.
  - Be aware of the costs involved in upgrading contracts. For instance, copying state (e.g., user balances) from an old contract to a new contract during contract migration may require more than one transaction, meaning more gas fees.

  

 ## About Product Formula ( at 11.01 )
  - need to re-watch to fully understand it.



 ## Multiple ways todo manual reviews
 - using slither library by running `slither .`
 - using `solidity` compiler by running `forge build` or `forge compile` to compile the code
 - using `Aderyn` library from `cyfrin updraft` team. 