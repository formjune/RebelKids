// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ERC721.sol";

contract People is ERC721, Ownable{

    uint constant GIFT_MAX = 66;
    uint constant SELL_MAX = 6666;
    uint constant MULTI_SELL_MAX = SELL_MAX - 50;
    uint constant MULTI_SELL = 10;
    uint constant PRICE = .05 ether;
    address[] RECEIVERS = [0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db];
    uint[] PERCENTAGE = [30, 70];

    uint public sold = GIFT_MAX;
    uint public gifted = 0;
    bool public multi_mint = true;
    bool public sold_out = false;
    
    constructor() ERC721("People", "People"){}

    function setBaseURI(string memory _uri) public onlyOwner{
        _setBaseURI(_uri);
    }

    function withdraw() private{
        // automatically send ether to receivers
        for (uint i = 0; i < RECEIVERS.length; i++)
            require(payable(RECEIVERS[i]).send(msg.value * PERCENTAGE[i] / 100), "transfer error");
    }

    function sendGift(address _to) public onlyOwner{
        // send a gift
        require(gifted < GIFT_MAX, "no more gifts");
        _safeMint(_to, ++gifted);
    }

    function mint(uint _count) public payable{
        // mint pack (10 max)
        require(!sold_out, "sold out");
        require(multi_mint, "multi mint is no longer available");
        require(_count <= MULTI_SELL, "can't mint more than 10 at once");
        require(msg.value >= _count * PRICE, "not enough money");
        for (uint i = 0; i < _count; i++)  
            _safeMint(msg.sender, ++sold);
        withdraw();
        if(sold >= MULTI_SELL_MAX)
            multi_mint = false;
    }

    function mint() public payable{
        // mint one (at the end of sale)
        require(!sold_out, "sold out");
        require(msg.value >= PRICE, "not enough money");
        _safeMint(msg.sender, ++sold);
        withdraw();
        if(sold == SELL_MAX)
            sold_out = true;
    }
}