pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISeed.sol";

contract Seed is ERC20Burnable,ISeed,Ownable{

    constructor(string memory name,
        string memory symbol,
        uint256 _yield,
        uint256 _matureTime,
        uint256 _price) ERC20(name, symbol){
        yield = _yield;
        matureTime = _matureTime;
        price = _price;
    }
}
