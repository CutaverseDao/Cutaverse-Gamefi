// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "./interfaces/ICutaverse.sol";

contract Cutaverse is ERC20Capped,ICutaverse,Ownable{
    address private _farm;

    constructor() ERC20Capped(100000000) ERC20("Cutaverse", "CTV") {}

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
        require(farm != address(0),"_farm is the zero address");
        _farm = farm;
    }

    function mint(address account, uint256 amount) public override onlyMinter {
        _mint(account, amount);
    }
}
