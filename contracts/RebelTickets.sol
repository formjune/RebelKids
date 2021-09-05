// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RebelTickets is ERC20, ReentrancyGuard {

    uint public constant MAX_CAP = 66666000;

    ERC721Enumerable public kidsContract;
    ERC721Enumerable public familiarsContract;

    uint[] public rewards;
    uint[] public months;
    mapping(address => mapping(uint => uint)) public lastRewardedMonth;
    mapping(address => mapping(uint => uint)) public rewardsCount;


    constructor(ERC721Enumerable _kidsContract, ERC721Enumerable _familiarsContract) ERC20("Rebel Tickets", "RBLTCKT") {
        _mint(_msgSender(), MAX_CAP * 15 / 100);
        months = [1633046400, 1635724800, 1638316800, 1640995200, 1643673600, 1646092800];
        rewards = [3000, 4196, 5222, 6090, 6813, 7406, 7880, 8250, 8528, 8727, 8860, 8941, 8983, 8998, 9000];
        kidsContract = _kidsContract;
        familiarsContract = _familiarsContract;
    }

    function decimals() public view virtual override returns (uint8) {
        return 3;
    }

    function currentMonth(uint currentTimestamp) internal view returns (uint) {
        if (currentTimestamp < months[0]) {
            return 1;
        }
        for (uint i = 1; i < months.length; i++) {
            if (months[i] > currentTimestamp) {
                return i + 1;
            }
        }
        return months.length + 1;
    }

    function claim(IERC721Enumerable minterContract, uint8 scale) internal {
        uint balance = minterContract.balanceOf(_msgSender());
        require(balance > 0, "Your token must be positive to claim tickets");

        uint notRewardedTokens = 0;
        uint weight = 0;
        address contractAddress = address(minterContract);

        for (uint i = 0; i < balance; i++) {
            uint tokenId = minterContract.tokenOfOwnerByIndex(_msgSender(), i);
            uint lastMonth = lastRewardedMonth[contractAddress][tokenId];
            uint month = currentMonth(block.timestamp);

            if (lastMonth == 0 || lastMonth < month) {
                notRewardedTokens += 1;
                lastRewardedMonth[contractAddress][tokenId] = month;
                weight += 1 << (6 - rewardsCount[contractAddress][tokenId]);
                rewardsCount[contractAddress][tokenId] += 1;
            }
        }
        require(notRewardedTokens > 0, "No tokens to claim reward for");
        uint rewardPerToken = rewards[balance > rewards.length ? rewards.length - 1 : balance - 1];
        uint reward = weight * rewardPerToken * notRewardedTokens / scale / 64;
        _mint(_msgSender(), reward > MAX_CAP - totalSupply() ? MAX_CAP - totalSupply() : reward);
    }

    function claimWithKids() external nonReentrant {
        claim(kidsContract, 1);
    }

    function claimWithFamiliars() external nonReentrant {
        claim(familiarsContract, 3);
    }

}
