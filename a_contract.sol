pragma solidity ^0.5.2;

contract VendingMachine {
    string public author = "xyz-pc-123";
    address payable public buyer;
    address payable public seller;

    struct Order {
        bool fulfilled;
        int amount;
        int product_id;
        string requester;
    }

    function confirmOrder() public {
        buyer = payable(msg.sender);
    }

    constructor(string memory _text) {
        author = _text;
    }
}