// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RebelKids is ERC721Enumerable, Ownable {

    // structures and enums
    struct Recipient {
        address payable recipient;
        uint percentage;
    }

    // constants
    uint constant MAX_NFT_SUPPLY = 6666;
    uint constant MAX_GIFT_SUPPLY = 66;
    uint public constant MAX_PURCHASABLE = 10;
    uint public constant TOKEN_PRICE = 0.06 ether;

    bool public saleStarted = true;
    string private baseURI;

    // variables
    Recipient[] private recipients;

    bool public isSaleActive = false;

    constructor() ERC721("Rebel Kids", "RBLKDS") {
        // test only
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
        //        recipients.push(Recipient(payable(0x0C37525f7600B5267f259b13617607b72388d6E2), 33));
    }

    function reserveTokens() external onlyOwner {
        // reserve 66 tokens
        for (uint i = 1; i <= MAX_GIFT_SUPPLY; i++) {
            _safeMint(msg.sender, i);
        }
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

    // customer interface
    function mint(uint amountToMint) public payable {
        require(isSaleActive, "This sale has not started.");
        require(totalSupply() < MAX_NFT_SUPPLY, "All NFTs have been minted.");
        require(amountToMint > 0, "You must mint at least one Rebel Kid.");
        require(amountToMint <= MAX_PURCHASABLE, "You cannot mint more than 20 Rebel Kids.");

        require(totalSupply() + amountToMint <= MAX_NFT_SUPPLY, "The amount of Rebel Kids you are trying to mint exceeds the MAX_NFT_SUPPLY.");
        require(TOKEN_PRICE * amountToMint == msg.value, "Incorrect Ether value.");

        for (uint i = 0; i < amountToMint; i++) {
            _safeMint(msg.sender, totalSupply() + 1);
        }
    }

}