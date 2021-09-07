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
        rewards = [0, 3000, 4196, 5222, 6090, 6813, 7406, 7880, 8250, 8528, 8727, 8860, 8941, 8983, 8998, 9000];
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

    function findClaimableTokens(IERC721Enumerable minterContract, uint8 scale) internal view returns (uint, uint[] memory) {
        uint balance = minterContract.balanceOf(_msgSender());

        uint weight = 0;
        address contractAddress = address(minterContract);
        uint month = currentMonth(block.timestamp);
        uint[] memory rewardedTokens = new uint[](balance);
        uint pos = 0;
        for (uint i = 0; i < balance; i++) {
            uint tokenId = minterContract.tokenOfOwnerByIndex(_msgSender(), i);
            uint lastMonth = lastRewardedMonth[contractAddress][tokenId];

            if (lastMonth == 0 || lastMonth < month) {
                uint d = 6 - rewardsCount[contractAddress][tokenId];
                weight += 1 << (d > 0 ? d : 0);
                rewardedTokens[pos] = tokenId;
                pos += 1;
            }
        }

        uint rewardPerToken = rewards[balance > rewards.length ? rewards.length - 1 : balance];
        uint reward = weight * rewardPerToken / scale / 64;
        return (reward > MAX_CAP - totalSupply() ? MAX_CAP - totalSupply() : reward, rewardedTokens);
    }

    function claim(IERC721Enumerable minterContract, uint8 scale) internal {
        (uint tickets, uint[] memory tokens) = findClaimableTokens(minterContract, scale);
        uint month = currentMonth(block.timestamp);
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == 0) {
                break;
            }
            lastRewardedMonth[address(minterContract)][tokens[i]] = month;
            rewardsCount[address(minterContract)][tokens[i]] += 1;
        }
        if (tickets != 0) {
            _mint(_msgSender(), tickets);
        }
    }

    function findClaimableTokensForKids() external view returns (uint) {
        (uint tickets,) = findClaimableTokens(kidsContract, 1);
        return tickets;
    }

    function findClaimableTokensForFamiliars() external view returns (uint) {
        (uint tickets,) = findClaimableTokens(familiarsContract, 3);
        return tickets;
    }

    function claimWithKids() external nonReentrant {
        claim(kidsContract, 1);
    }

    function claimWithFamiliars() external nonReentrant {
        claim(familiarsContract, 3);
    }

}
