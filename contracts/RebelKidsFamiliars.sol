// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./BaseContract.sol";

contract RebelKidsFamiliars is BaseContract {

    mapping (address => bool) isMinted;

    constructor() BaseContract(
        "Rebel Kids Familiars",
        "RBLKDSFML",
        666,
        true,
        1,
        0.01 ether
    ) {
    }

    function _beforeMint() internal virtual override {
        require(!isMinted[msg.sender], "Can't mint more than 1 Familiar");
        isMinted[msg.sender] = true;
    }

}
