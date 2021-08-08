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

}