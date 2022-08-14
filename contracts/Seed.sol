pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISeed.sol";

contract Seed is ERC20,ISeed,Ownable{

    constructor (string memory name,string memory symbol, uint256 _harvestAt,uint256 _harvestAmount,uint256 _price)
        payable ERC20(name, symbol){
        harvestAt = _harvestAt;
        harvestAt = _harvestAmount;
        price = _price;
    }

    function getOwner() public view returns (address) {
        return owner();
    }

    function mint(address account, uint256 amount) public onlyOwner{
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner{
        _burn(account, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        if (msg.sender == owner()) {
            _transfer(sender, recipient, amount);
            return true;
        }

        super.transferFrom(sender, recipient, amount);
        return true;
    }

}
