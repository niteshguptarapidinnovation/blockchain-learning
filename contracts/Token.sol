// SPDX-License-Identifier: no-license
pragma solidity >=0.8.0 <= 0.8.17;

import "hardhat/console.sol";

contract Token {
    string public name = "Hardhat Token";
    string public symbol = "HHT";
    uint public totalSupply = 1000000;
    address public owner;

    mapping(address => uint) public balanceOf;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address _to, uint _amount) external {
        // console.log("**Sender balance  is %s tokens", balanceOf[msg.sender]);
        // console.log("**Sender is sending %s tokens to %s address", _amount, msg.sender);
        require(balanceOf[msg.sender] >= _amount, "Not enougth tokens");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
    }



}