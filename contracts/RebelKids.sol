// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./BaseContract.sol";

contract RebelKids is BaseContract {

    constructor() BaseContract(
        "Rebel Kids",
        "RBLKDS",
        6666,
        10,
        0.06 ether
    ) {
    }

}