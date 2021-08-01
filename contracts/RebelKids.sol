// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


import "./ERC721.sol";


contract RebelKids is ERC721, Ownable{

    uint constant GIFT_MAX = 66;
    uint constant SELL_MAX = 6666;
    uint constant MULTI_SELL = 10;
    uint constant PRICE = .05 ether;
    enum SALE_STATES{NOT_STARTED, ACTIVE, PAUSED, FINISHED}
    address[] private RECEIVERS = [0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db];
    uint[] private PERCENTAGE = [30, 70];

    uint private gifted = 0;
    SALE_STATES public sale_state = SALE_STATES.NOT_STARTED;

    constructor() ERC721("People", "People"){
        for(uint i = 1; i <= GIFT_MAX; i++)
            _safeMint(msg.sender, i);
    }

    function setBaseURI(string memory _uri) public onlyOwner{
        _setBaseURI(_uri);
    }

    function startSale() public onlyOwner{
        require(sale_state != SALE_STATES.FINiSHED, "sale is finished");
        sale_state = SALE_STATES.ACTIVE;
    }

    function pauseSale() public onlyOwner{
        require(sale_state != SALE_STATES.FINiSHED, "sale is finished");
        sale_state = SALE_STATES.PAUSED;
    }

    function withdraw() private{
        for (uint i = 0; i < RECEIVERS.length; i++)
            require(payable(RECEIVERS[i]).send(address(this).balance * PERCENTAGE[i] / 100), "transfer error");
    }

    function sendGift(address _to) public onlyOwner{
        require(gifted < GIFT_MAX, "no more gifts");
        _safeMint(_to, ++gifted);
    }

    function mint(uint _count) public payable{
        require(sale_state != SALE_STATES.NOT_STARTED, "embrace patience and return whence thou hast cometh");
        require(sale_state != SALE_STATES.FINISHED, "sold out");
        require(sale_state != SALE_STATES.PAUSED, "sale is paused");
        require(0 < _count <= MULTI_SELL, "number of tokens must be between 1 and 10");
        require(msg.value >= _count * PRICE, "not enough money");
        require(totalSupply() + _count <= SELL_MAX, "not enough tokens for sale");
        for (uint i = 0; i < _count; i++)  
            _safeMint(msg.sender, totalSupply() + 1);
        if(totalSupply() == SELL_MAX)
            sale_state = SALE_STATES.FINISHED;
    }
}