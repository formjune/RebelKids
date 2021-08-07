// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseContract is ERC721Enumerable, Ownable {

    struct Recipient {
        address payable recipient;
        uint percentage;
    }

    uint public maxSupply;
    bool isExtendable;
    uint maxPurchasable;
    uint tokenPrice;
    string baseURI;
    bool isSaleActive = false;
    Recipient[] private recipients;

    constructor (
        string memory name,
        string memory symbol,
        uint _maxSupply,
        bool _isExtendable,
        uint _maxPurchasable,
        uint _tokenPrice
    ) ERC721(name, symbol) {
        maxSupply = _maxSupply;
        maxPurchasable = _maxPurchasable;
        isExtendable = _isExtendable;
        tokenPrice = _tokenPrice;
        // test only
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
    }

    function reserveTokens(uint amount) external onlyOwner {
        for (uint i = 1; i <= amount; i++) {
            _safeMint(msg.sender, i);
        }
    }

    function increaseMaxSupply(uint amount) external onlyOwner {
        maxSupply += amount;
    }

    function setBaseUri(string memory _baseURIArg) external onlyOwner {
        baseURI = _baseURIArg;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i].recipient.send(balance * recipients[i].percentage / 100), "transfer error");
        }
    }

    function startSale() public onlyOwner {
        isSaleActive = true;
    }

    function pauseSale() public onlyOwner {
        isSaleActive = false;
    }

    function giftTokens(address[] memory addresses) external onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            _safeMint(addresses[i], totalSupply() + 1);
        }
    }

    modifier preMintCheck(){
        require(isSaleActive, "This sale has not started.");
        require(totalSupply() < maxSupply, "All NFTs have been minted.");
        _;
    }
}