// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


contract NITToken is IERC20, IERC20Metadata, Ownable {
    
    uint public totalSupply;
    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;
    mapping(address => bool) private blacklisted;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transferOwnership(address newOwner) override public {
        require(_msgSender() == owner(), "Not the Owner");
        require(newOwner != address(0), "Not valid address");
        require(newOwner == owner(), "Already owner");
        _transferOwnership(newOwner);
    }

    function transfer(address _to, uint _amount) external returns (bool) {
        _transfer(_msgSender(), _to, _amount);
        return true;
    }

    function mint(address _to, uint _amount) external onlyOwner() {
        _mint(_to, _amount);
    }

    function burn(address _from, uint _amount) external onlyOwner() {
        _burn(_from, _amount);
    }

    function approve(address _spender, uint _amount) external returns (bool) {
        _approve(_msgSender(), _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) external returns (bool) {
        require(_to != address(0), "Invalid to address");
        _spendAllowance(_from,_msgSender(), _amount);
        _transfer(_from, _to, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint _amount) external returns (bool) {
        uint allowanceBalance = allowance[_msgSender()][_spender];
        _approve(_msgSender(), _spender, allowanceBalance + _amount);
        return true;
    }

    function decreaseAllowance(address _spender, uint _amount) external returns (bool) {
        _spendAllowance(msg.sender, _spender, _amount);
        return true;
    }

    function blackListAddress(address _account) external onlyOwner() returns (bool) {
        require(_account != address(0), "Invalid address");
        blacklisted[_account] = true;
        return true;
    }

    function removedBlackListAddress(address _account) external onlyOwner() returns (bool) {
        require(_account != address(0), "Invalid address");
        blacklisted[_account] = false;
        return true;
    }

    function _transfer(address _from, address _to, uint _amount) internal {
        require(_from != address(0), "Invalid from adress");
        require(_to != address(0), "Invalid to adress");
        require(balances[_from] >= _amount, "insufficient balance");
        balances[_msgSender()] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }

    function _mint(address _to, uint _amount) internal {
        require(_to != address(0), "Token minted");
        require(_amount > 0, "Invalid amount");
        totalSupply += _amount;
        balances[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function _burn(address _account, uint _amount) internal {
        require(balances[_account] >= _amount, "insufficient balance");
        require(_amount > 0, "Invalid amount");
        totalSupply -= _amount;
        balances[_account] -= _amount;
        emit Transfer(_account, address(0), _amount);
    }

    function _approve(address _account, address _spender, uint _amount) internal {
        require(_amount > 0, "Invalid amount");
        require(_spender != address(0), "Invalid spender");
        require(_account != address(0), "Invalid account");
        allowance[_account][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
    }

    function _spendAllowance(address _from, address _spender, uint _amount) internal {
        uint allowanceBalance = allowance[_from][_spender];
        require(allowanceBalance >= _amount, "Invalid allowance");
        _approve(_from, _spender, allowanceBalance - _amount);
    }

    function balanceOf(address _account) public view override returns (uint) {
        if(blacklisted[_account] == true) {
            return 0;
        } 
        return balances[_account];
    }

}