## 1. Reentrancy Attacks
Reentrancy occurs when an external call to an untrusted contract makes a callback into the original function before it finishes execution. This allows the attacker to manipulate the contract’s state in ways the developer did not anticipate—most famously exploited in The DAO hack (2016).

- **Example**: A function sends ETH/tokens first and then updates internal state (e.g., balances), allowing an attacker’s fallback function to call back into the contract and drain funds repeatedly.
- **Mitigation**: Use the “Checks-Effects-Interactions” pattern, mutexes, or OpenZeppelin’s `ReentrancyGuard`.

## 2. Integer Overflows/Underflows
Although Solidity 0.8.x now includes built-in overflow and underflow checks by default, older versions or manually implemented arithmetic operations can be susceptible.

- **Example**: `uint256 a = 0; a - 1;` in older Solidity versions wraps around to the maximum `uint256` value, enabling an attacker to manipulate arithmetic-based logic.
- **Mitigation**: Upgrade to Solidity 0.8.x or use SafeMath libraries when working in older versions.

## 3. Incorrect `delegatecall` Usage
`delegatecall` executes code in the context of the caller’s storage, meaning the callee can modify the caller’s state variables. If you pass arbitrary addresses to `delegatecall`, malicious contracts can hijack your contract’s storage.

- **Example**: A proxy pattern that points to an untrusted contract (or incorrectly validated upgrade) can allow an attacker to overwrite critical storage variables, such as ownership or balances.
- **Mitigation**: Limit and carefully validate the implementation address. Ensure only authorized users can upgrade logic contracts.

## 4. Access Control Vulnerabilities
Smart contract functions may rely on the wrong variable or method to check permissions, or they might omit checks entirely.

- **Example**: A contract that uses `tx.origin` for authorization can be tricked when a malicious contract initiates a transaction on behalf of a victim, bypassing proper checks.
- **Mitigation**: Use `msg.sender` for role-based access control; implement well-reviewed Access Control (e.g., OpenZeppelin’s `Ownable` or `AccessControl`).

## 5. `tx.origin` Usage
Closely related to access control, using `tx.origin` (the external account that started the transaction) in authorization checks is generally unsafe because a contract can be called by another contract, leading to unexpected origins.

- **Example**: If your `require(tx.origin == owner, "Unauthorized")` logic is exploited through a contract call, an attacker contract can trick a user into calling it, and `tx.origin` will be that user’s address instead of the attacker’s contract.
- **Mitigation**: Use `msg.sender` and established patterns like `Ownable` or `AccessControl` libraries.

## 6. Uninitialized Storage Pointers
When using low-level Solidity constructs like inline assembly or certain library patterns, uninitialized references to storage can cause unexpected data manipulation.

- **Example**: Declaring a local storage variable but not initializing it can point to an arbitrary location in storage, allowing unintended overwriting of critical variables.
- **Mitigation**: Always initialize state variables explicitly. Use high-level patterns or well-tested libraries.

## 7. Front-Running / MEV (Miner/Maximal Extractable Value)
Because all transactions on Ethereum are public before inclusion in a block, attackers (or sophisticated bots) can observe a pending transaction and quickly send a competing transaction with higher gas fees to reorder or sandwich the original.

- **Example**: On-chain DEX trades can be “sandwiched” by bots that profit from the slippage a user introduced.
- **Mitigation**: Use commit-reveal schemes for critical data (e.g., auctions), apply maximum slippage bounds on DEX trades, or utilize private mempools/Flashbots-like solutions.

## 8. Oracle Manipulation
Smart contracts often rely on external data (prices, feeds). If the oracle is not secure or can be influenced by an attacker, they can provide fake data.

- **Example**: A lending platform that uses a single, manipulable on-chain AMM pair for pricing can be tricked if the attacker pumps or dumps the asset price in a single transaction, borrowing more than they should.
- **Mitigation**: Use reputable oracles (Chainlink, etc.), decentralize data sources, set safe boundaries (circuit breakers, time-weighted averages).

## 9. Signature Replay Attacks
Signature-based authorizations can be reused unless they include nonces or expiration timestamps.

- **Example**: A user signs a message allowing a token transfer. If the same signed message (without a nonce) is broadcast again, the attacker can re-trigger the same action (transfer).
- **Mitigation**: Include a nonce and/or timestamp in all off-chain signatures. Ensure the contract invalidates signatures after one use.

## 10. Insufficient Validation of External Calls
Calling external contracts can lead to unexpected behavior, especially if you assume success/failure. Use cases like `require(success, "Call failed")` are standard, but ignoring the return value or not handling reverts can introduce issues.

- **Example**: If your contract calls another contract’s function but doesn’t check for revert conditions, the external call might fail silently, leaving your contract in an inconsistent state.
- **Mitigation**: Always handle the success/failure boolean in low-level calls. Use `try/catch` in Solidity 0.6+ for external calls.

## 11. Denial of Service (DoS) by Gas Limit or Unexpected Revert
Attackers can purposefully revert transactions or cause high gas usage so that they block crucial functions.

- **Example**: A malicious contract always reverts if it’s included in a loop for distributing rewards, blocking the entire reward distribution.
- **Mitigation**: Avoid unbounded loops over dynamic arrays in state. Use pull over push patterns for withdrawing rewards (e.g., each user claims individually).

## 12. Timestamp Manipulation
Block timestamp can be influenced slightly by miners/validators. Using block timestamps for critical logic (e.g., random number generation or large-scale time-based condition) can open a small but exploitable window.

- **Example**: A contract uses `block.timestamp` to calculate random outcomes in a game, allowing a miner to withhold a block if the outcome is unfavorable.
- **Mitigation**: Use a reliable randomness source (Chainlink VRF or commit-reveal). Tolerate small skew in time-based logic.

## 13. Selfdestruct Vulnerabilities
A contract can self-destruct, sending its remaining Ether to a target address. In older Solidity versions, if used improperly, selfdestruct can break assumptions about contract availability or forcibly send Ether to addresses not designed to handle it.

- **Example**: Attackers can use `selfdestruct` to forcibly send Ether to a contract that reverts on `receive()` or `fallback()`. This might disrupt certain logic that checks contract balances.
- **Mitigation**: Refrain from using `selfdestruct` unless absolutely necessary. Don’t rely solely on `payable` reverts to keep Ether out of a contract.

## 14. Logic Bugs / Misconfiguration
Beyond typical security exploits, many attacks happen simply due to logic mistakes, missing `require` statements, or misconfigured contract variables.

- **Example**: An NFT contract that inadvertently sets the max supply to `0` might allow infinite minting. A stablecoin contract with incorrect peg logic can lead to insolvency.
- **Mitigation**: Thorough testing, formal verification where possible, professional audits, bug bounties.

## 15. Improper Upgradeable Proxy Patterns
Upgradeable proxies are popular, but incorrectly implemented initialization or upgrade steps can lead to catastrophic vulnerabilities.

- **Example**: A storage collision between the proxy and implementation can allow overwriting of crucial state. Or forgetting to initialize the logic contract properly might allow anyone to become the owner (the “uninitialized proxy” bug).
- **Mitigation**: Use well-tested frameworks (e.g., OpenZeppelin’s Transparent or UUPS proxies). Ensure initialization only happens once, with correct access control.
