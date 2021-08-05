// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./BaseContract.sol";

contract RebelKidsFamiliars is BaseContract {

    constructor() BaseContract(
        "Rebel Kids Familiars",
        "RBLKDSFML",
        666,
        true,
        1,
        0.01 ether
    ) {
    }

    function mint() public payable preMintCheck{
        require(balanceOf(msg.sender) == 0, "Can't mint more than 1 Familiar");
        require(tokenPrice >= msg.value, "Incorrect Ether value.");
        _safeMint(msg.sender, totalSupply() + 1);
    }
}