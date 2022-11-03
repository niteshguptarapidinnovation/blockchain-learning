// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

/*
Blockchain interview question
1.Write an ERC20 contract which include these functionalities:-
     a) name = TWOISTOONE and symbol = TITO
     b) deposit function :-
a) this function accepts an erc20 token from user.
b) this erc20 token name is ONEISTOTWO and symbol is (OITT)
c) contract will accept the above token and mint TITO tokens in the
    Ratio of 1:2 i.e
    If User will give 1 OITT he will receive 2 TITO
      c) withdraw function :-
            a) user has to give how many OITT he wants to withdraw
            b) withdraw requires (OITT tokens user wants to withdraw * 2) <= user’s TITO balance
            b) if user has sufficient TITO balance then burn (OITT tokens user wants to withdraw * 2)
                TITO tokens from user wallet and transfer (OITT tokens user wants to withdraw) OITT
                Tokens to user
 */

contract TITOToken is ERC20 {
    IERC20 public OITT;

    constructor(string memory _name, string memory _symbol, address _OITTContract) ERC20(_name, _symbol) {
        OITT = IERC20(_OITTContract);
    }

    function deposit(uint amountOITT) external {
        uint approved = OITT.allowance(msg.sender, address(this));
        require(approved >= amountOITT, "insufficient allowance");
        bool success = OITT.transferFrom(msg.sender, address(this), amountOITT);
        require(success, "OITT transfer is failed");
        _mint(msg.sender, amountOITT * 2);
    }

    function withdraw(uint amountOITT) external {
        require(balanceOf(msg.sender) >= amountOITT * 2, "insufficient balance");
        _burn(msg.sender, amountOITT * 2);
        OITT.transfer(msg.sender, amountOITT);
    }

}