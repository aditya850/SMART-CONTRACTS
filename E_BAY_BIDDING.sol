pragma solidity >= 0.7.0 < 0.9.0;
contract EbayBid{
    address payable public auctioneer;
    address internal highBidder;
    uint public endtime;
    uint internal highBidAmt;
    bool ended;

    constructor(uint time,address payable _benificiary,uint baseAmt){
        auctioneer = _benificiary;
        endtime = block.timestamp + time;
        highBidAmt = baseAmt;
    }

    mapping(address => uint)biddingInfo;

    event HighBidding(address Bidder,uint Bid);
    event AuctionEnd(address winner,uint winBid);

    function getHighestBid() view public returns(uint){
        return highBidAmt;
    }

    function setBid(address bidder,uint bidAmt) public payable {
        if(block.timestamp > endtime)
            revert("The Auction is Ended");

        if(bidAmt <= highBidAmt)
            revert("Bid amount must be greater than the current highest bid");

        if(bidAmt != 0)
            biddingInfo[bidder] += bidAmt;
        
        highBidAmt = bidAmt;
        highBidder = bidder;

        emit HighBidding(highBidder, highBidAmt);
    }

    function withdraw() public payable returns(bool) {
        uint amount = biddingInfo[msg.sender];
        if(amount > 0)
        {
            biddingInfo[msg.sender] = 0;
        }

        if(!payable(msg.sender).send(amount)){
            biddingInfo[msg.sender] = amount;
        }
        return true;
    }

    function endAuction() public {
        if(block.timestamp < endtime){
            revert("Auction is not ended yet");
        }

        if(ended){
            revert("Auction is already ended");
        }
        ended = true;
        emit AuctionEnd(highBidder, highBidAmt);
        auctioneer.transfer(highBidAmt);
    }
}
