// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract People is ERC721Enumerable, Ownable {

    uint16 public constant MAX_NFT_SUPPLY = 6666;
    uint8 public constant MAX_PURCHASABLE = 50;
    uint256 public constant TOKEN_PRICE = 0.05 ether;

    bool public saleStarted = false;
    string private baseURI;

    // TODO move to mapping or delete
    address[] RECEIVERS = [0x144a2ee5fA066E8Dc6F6dBF6E4E616B7aE87D44b, 0x144a2ee5fA066E8Dc6F6dBF6E4E616B7aE87D44b];
    uint[] PERCENTAGE = [30, 70];

    constructor() ERC721("PEOPLE", "PPLCN") {}

    // TODO move to mapping or delete
    function withdraw() private {
        // automatically send ether to receivers
        for (uint i = 0; i < RECEIVERS.length; i++)
            require(payable(RECEIVERS[i]).send(msg.value * PERCENTAGE[i] / 100), "transfer error");
    }

    function mint(uint256 amountToMint) public payable {
        require(saleStarted == true, "This sale has not started.");
        //        require(block.timestamp >= SALE_START_TIME, "Sale has not started.");
        require(totalSupply() < MAX_NFT_SUPPLY, "All NFTs have been minted.");
        require(amountToMint > 0, "You must mint at least one Cypher.");
        require(amountToMint <= MAX_PURCHASABLE, "You cannot mint more than 20 Cyphers.");
        require(totalSupply() + amountToMint <= MAX_NFT_SUPPLY, "The amount of Cyphers you are trying to mint exceeds the MAX_NFT_SUPPLY.");

        require(TOKEN_PRICE * amountToMint == msg.value, "Incorrect Ether value.");

        for (uint256 i = 0; i < amountToMint; i++) {
            uint256 mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
        }
        // TODO move to mapping or delete
        withdraw();
    }

    function startSale() public onlyOwner {
        saleStarted = true;
    }

    function pauseSale() public onlyOwner {
        saleStarted = false;
    }

    // reserveTokens before sale
    function reserveTokens() public onlyOwner {
        for (uint256 i = 0; i < 100; i++) {
            uint256 mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
        }
    }

    function setBaseUri(string memory _baseURIArg) external onlyOwner {
        baseURI = _baseURIArg;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function withdrawToOwner() external payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

}