pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Seed is ERC20Burnable,Ownable{
    address public farm;

    uint256 public price;
    uint256 public yield;
    uint256 public matureTime;
    uint256 public oneDayLimit;

    constructor(string memory name,
        string memory symbol,
        uint256 _price,
        uint256 _yield,
        uint256 _matureTime,
        uint256 _oneDayLimit) ERC20(name, symbol){
        price = _price;
        yield = _yield;
        matureTime = _matureTime;
        oneDayLimit = _oneDayLimit;
    }

    modifier onlyMinter() {
        require(owner() == _msgSender()
            || (farm != address(0) && farm == _msgSender()), "Ownable: caller is not the minter");
        _;
    }

    function mint(address account, uint256 amount) public onlyMinter {
        _mint(account, amount);
    }
}
