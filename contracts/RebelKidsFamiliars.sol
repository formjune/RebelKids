// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./BaseContract.sol";
import "./RebelKids.sol";

contract RebelKidsFamiliars is BaseContract {

    uint constant EDITION_SUPPLY = 666;
    mapping (address => mapping (uint => bool)) isEditionMinted;

    bool public isOnlyForKids = false;
    RebelKids public rebelKids;

    constructor() BaseContract(
        "Rebel Kids Familiars",
        "RBLKDSFML",
        666,
        1,
        0.01 ether
    ) {
    }

    function setRebelKids(RebelKids rebelKidsAddress) external onlyOwner {
        rebelKids = rebelKidsAddress;
    }

    function setOnlyForKids(bool _isOnlyForKids) external onlyOwner {
        isOnlyForKids = _isOnlyForKids;
    }

    function setMaxSupply(uint _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setPrice(uint _tokenPrice) external onlyOwner {
        tokenPrice = _tokenPrice;
    }

    function _beforeMint() internal virtual override {
        uint editionNum = totalSupply() / EDITION_SUPPLY;
        require(!isEditionMinted[msg.sender][editionNum], "Can't mint more than 1 Familiar in that edition");
        isEditionMinted[msg.sender][editionNum] = true;
        if (isOnlyForKids) {
            require(rebelKids.balanceOf(msg.sender) > 0, "You must own at least one Rebel Kid to mint Familiar");
        }
    }

}
