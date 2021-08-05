// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./BaseContract.sol";

contract RebelKids is BaseContract {

    constructor() BaseContract(
        "Rebel Kids",
        "RBLKDS",
        6666,
        false,
        10,
        0.05 ether
    ) {
    }
    
    function mint(uint amountToMint) public payable preMintCheck{
        require(amountToMint > 0, "You must mint at least one Rebel Kid.");
        require(amountToMint <= maxPurchasable, "You cannot mint more than 20 Rebel Kids.");
        require(totalSupply() + amountToMint <= maxSupply, "The amount of Rebel Kids you are trying to mint exceeds the maxSupply.");
        require(tokenPrice * amountToMint >= msg.value, "Incorrect Ether value.");

        for (uint i = 0; i < amountToMint; i++) {
            _safeMint(msg.sender, totalSupply() + 1);
        }
    }
}