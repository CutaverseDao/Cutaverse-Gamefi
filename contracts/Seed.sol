// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./interfaces/ISeed.sol";

contract Seed is ISeed,ERC20Burnable,Ownable{
    uint8 private _decimals;
    address private _shop;

    uint256 private _yield;
    uint256 private _matureTime;

    constructor(string memory name,
        string memory symbol,
        uint256 decimals,
        uint256 yield,
        uint256 matureTime) ERC20(name, symbol){
        _yield = yield;
        _matureTime = matureTime;
    }

    modifier onlyOperator() {
        require(owner() == _msgSender()
            || (_shop != address(0) && _shop == _msgSender()), "Ownable: caller is not the operator");
        _;
    }

    function shop() external view override returns (address) {
        return _shop;
    }

    function decimals() public view override(IERC20Metadata,ERC20) returns (uint8){
        return _decimals;
    }

    function yield() external view override returns (uint256) {
        return _yield;
    }

    function matureTime() external view override returns (uint256) {
        return _matureTime;
    }

    function restShop(address shop) public override onlyOwner{
        require(shop != address(0),"shop is the zero address");
        _shop = shop;
    }

    function mint(address account, uint256 amount) public override onlyOperator {
        _mint(account, amount);
    }

    function burnFrom(address account,uint256 amount) public override(ISeed,ERC20Burnable) onlyOperator{
        super.burnFrom(account,amount);
    }

}
