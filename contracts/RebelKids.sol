// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


import "./ERC721.sol";


contract RebelKids is ERC721, Ownable{

    // structures and enums
    struct Recipient{
        address payable recipient;
        uint percentage;
    }

    // events
    event RecipientAdded(
        address payable recipient,
        uint percentage
    );

    event PurchaseMade(
        address payable customer,
        uint amount
    );

    event GiftSent(
        address customer
    );

    event SaleStarted();
    event SalePaused();

    // constants
    uint constant GIFT_MAX = 66;
    uint constant SELL_MAX = 6666;
    uint constant MULTI_SELL = 10;
    uint constant PRICE = .05 ether;
    
    // variables
    uint private gifted = 0;
    Recipient[] private recipients = [];
    bool sale_active = false;

    constructor() ERC721("Rebel Kids", "Rebel Kids"){

        // reserve 66 tokens
        for(uint i = 1; i <= GIFT_MAX; i++)
            _safeMint(msg.sender, i);
    }

    // owner interface

    function setBaseURI(string memory _uri) public onlyOwner{
        _setBaseURI(_uri);
    }

    function addRecipient(address payable _address, uint _percentage) public onlyOwner{
        recipients.push(Recipient(_address, _percentage));
        emit RecipientAdded(_address, _percentage);
    }

    function withdraw() public onlyOwner{
        for (uint i = 0; i < recipients.length; i++)
            require(recipients[i].recipient.send(address(this).balance * recipients[i].percentage / 100), "transfer error");
    }

    function startSale() public onlyOwner{
        sale_active = true;
        emit SaleStarted();
    }

    function pauseSale() public onlyOwner{
        sale_active = false;
        emit SalePaused();
    }

    function sendGift(address _to) public onlyOwner{
        require(gifted < GIFT_MAX, "no more gifts");
        _safeMint(_to, ++gifted);
        emit GiftSent(_to);
    }

    // customer interface

    function mint(uint _amount) public payable{
        require(sale_active, "sale is not active");
        require(totalSupply() < SELL_MAX, "sold out");        
        require(totalSupply() + _amount <= SELL_MAX, "not enough tokens for sale");
        require(0 < _amount <= MULTI_SELL, "number of tokens must be between 1 and 10");
        require(msg.value >= _amount * PRICE, "not enough money");
        for (uint i = 0; i < _amount; i++)  
            _safeMint(msg.sender, totalSupply() + 1);
        emit PurchaseMade(msg.sender, _amount);
    }
}