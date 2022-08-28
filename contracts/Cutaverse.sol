// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "./interfaces/ICutaverse.sol";

contract Cutaverse is ICutaverse,ERC20Capped,Ownable{
    address private _farm;

    constructor(uint256 cap, string memory name, string memory symbol) ERC20Capped(cap) ERC20(name, symbol) {}

    modifier onlyMinter() {
        require(owner() == _msgSender()
            || (_farm != address(0) && _farm == _msgSender()), "Ownable: caller is not the minter");
        _;
    }

    function farm() external view override returns (address) {
        return _farm;
    }

    function cap() public view override(ICutaverse,ERC20Capped) returns (uint256){
        return super.cap();
    }

    function restFarm(address farm) public override onlyOwner{
        require(farm != address(0),"farm is the zero address");
        _farm = farm;
    }

    function mint(address account, uint256 amount) public override onlyMinter {
        _mint(account, amount);
    }
}
