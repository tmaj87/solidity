pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenX is ERC20 {
    uint constant _initial_supply = 1000 * (10**18);
    constructor() ERC20("TokenX", "TKX") {
        _mint(msg.sender, _initial_supply);
    }
}