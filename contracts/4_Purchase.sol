// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Purchase {
    uint public value;
    address payable public seller;
    address payable public buyer;
    enum State {
        Created,
        Locked,
        Inactive
    }
    State public state;

    constructor()  payable  {
        seller = payable(msg.sender);
        value = msg.value / 2;
        require(2*value == msg.value, "Value has to be even.");
    }

    modifier condition(bool _condition) {
        require(_condition, "Condition not match.");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender==buyer, "Only buyer can call this.");
        _;
    }

    modifier onlySeller() {
        require(msg.sender==seller, "Only seller can call this.");
        _;
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid state.");
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();

    function abort() public onlySeller inState(State.Created) {
        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

    function confirmPurchase() public inState(State.Created) condition(msg.value == 2*value) payable {
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    } 

    function confirmReceived() public onlyBuyer inState(State.Locked) {
        emit ItemReceived();
        state = State.Inactive;
        buyer.transfer(value);
        seller.transfer(address(this).balance);
    }

}