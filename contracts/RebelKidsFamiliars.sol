// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./BaseContract.sol";

contract RebelKidsFamiliars is BaseContract {

    uint constant EDITION_SUPPLY = 666;
    mapping (address => mapping (uint => bool)) isEditionMinted;

    constructor() BaseContract(
        "Rebel Kids Familiars",
        "RBLKDSFML",
        666,
        1,
        0.01 ether
    ) {
    }

    function setMaxSupply(uint _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setPrice(uint _tokenPrice) external onlyOwner {
        tokenPrice = _tokenPrice;
    }

    function _beforeMint() internal virtual override {
        uint editionNum = totalSupply() / EDITION_SUPPLY;
        require(!isEditionMinted[msg.sender][editionNum], "Can't mint more than 1 Familiar");
        isEditionMinted[msg.sender][editionNum] = true;
    }

}
