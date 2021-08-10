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
    uint public maxPurchasable;
    uint public tokenPrice;
    bool public isSaleActive;
    string private baseURI;
    Recipient[] private recipients;

    constructor (
        string memory name,
        string memory symbol,
        uint _maxSupply,
        uint _maxPurchasable,
        uint _tokenPrice
    ) ERC721(name, symbol) {
        maxSupply = _maxSupply;
        maxPurchasable = _maxPurchasable;
        tokenPrice = _tokenPrice;
        // test only
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
    }

    // region setters and getters
    function startSale() public onlyOwner {
        isSaleActive = true;
    }

    function pauseSale() public onlyOwner {
        isSaleActive = false;
    }

    function setBaseUri(string memory _baseURIArg) external onlyOwner {
        baseURI = _baseURIArg;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    // endregion


    // region mint
    function _beforeMint() internal virtual {}

    modifier maxSupplyCheck(uint amount) {
        require(totalSupply() < maxSupply, "All NFTs have been minted.");
        require(amount > 0, "You must mint at least one token.");
        require(totalSupply() + amount <= maxSupply, "The amount of tokens you are trying to mint exceeds the maxSupply.");
        _;
    }

    function reserveTokens(uint amount) external onlyOwner maxSupplyCheck(amount) {
        for (uint i = 0; i < amount; i++) {
            _safeMint(msg.sender, totalSupply() + 1);
        }
    }

    function giftTokens(address[] memory addresses) external onlyOwner maxSupplyCheck(addresses.length) {
        for (uint i = 0; i < addresses.length; i++) {
            _safeMint(addresses[i], totalSupply() + 1);
        }
    }

    function mint(uint amountToMint) external payable maxSupplyCheck(amountToMint) {
        require(isSaleActive, "This sale has not started.");
        require(amountToMint <= maxPurchasable, "You cannot mint such amount of tokens.");
        require(tokenPrice * amountToMint == msg.value, "Incorrect Ether value.");

        _beforeMint();

        for (uint i = 0; i < amountToMint; i++) {
            _safeMint(msg.sender, totalSupply() + 1);
        }
    }
    // endregion

    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i].recipient.send(balance * recipients[i].percentage / 100), "transfer error");
        }
    }

}