pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./interfaces/ISeed.sol";

contract Seed is ERC20Burnable,ISeed,Ownable{
    address private _farm;

    uint256 private _price;
    uint256 private _yield;
    uint256 private _matureTime;
    uint256 private _oneDayLimit;

    constructor(string memory name,
        string memory symbol,
        uint256 price,
        uint256 yield,
        uint256 matureTime,
        uint256 oneDayLimit) ERC20(name, symbol){
        _price = price;
        _yield = yield;
        _matureTime = matureTime;
        _oneDayLimit = oneDayLimit;
    }

    modifier onlyMinter() {
        require(owner() == _msgSender()
            || (_farm != address(0) && _farm == _msgSender()), "Ownable: caller is not the minter");
        _;
    }

    function farm() external view override returns (address) {
        return _farm;
    }

    function price() external view override returns (uint256) {
        return _price;
    }

    function yield() external view override returns (uint256) {
        return _yield;
    }

    function matureTime() external view override returns (uint256) {
        return _matureTime;
    }

    function oneDayLimit() external view override returns (uint256) {
        return _oneDayLimit;
    }

    function restFarm(address farm) public override onlyOwner{
        require(farm != address(0),"_farm is the zero address");
        _farm = farm;
    }

    function mint(address account, uint256 amount) public override onlyMinter {
        _mint(account, amount);
    }

    function burn(uint256 amount) public override (ERC20Burnable,ISeed){
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override (ERC20Burnable,ISeed){
        super.burnFrom(account,amount);
    }
}
