// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SimpleAuction {
    address payable public beneficiary;
    uint public auctionEnd;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(
        uint _biddingTime,
        address payable _beneficiary
    )  {
        beneficiary = _beneficiary;
        auctionEnd = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        require(
            block.timestamp < auctionEnd,
            "Auction already ended"
        );

        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        
        highestBidder = msg.sender;
        highestBid = msg.value;
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool result) {
        uint amount = pendingReturns[msg.sender];
        address payable sender = payable(msg.sender);
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                result = false;
            }
        }
        result = true;
    }

    function checkAuctionEnd() public {
        require(block.timestamp >= auctionEnd, "Auction not yet ended.");
        require(!ended, "actionEnd has already been called");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
} 