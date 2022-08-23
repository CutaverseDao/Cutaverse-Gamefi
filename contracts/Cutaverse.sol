// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/ICutaverse.sol";

contract Cutaverse is ERC20,ICutaverse,Ownable{
    address private _farm;
    uint256 private immutable _cap;

    constructor(uint256 cap_) ERC20("Cutaverse", "CTV") {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    modifier onlyMinter() {
        require(owner() == _msgSender()
            || (_farm != address(0) && _farm == _msgSender()), "Ownable: caller is not the minter");
        _;
    }

    function farm() external view override returns (address) {
        return _farm;
    }

    function cap() public view override returns (uint256) {
        return _cap;
    }

    function restFarm(address farm) public override onlyOwner{
        require(farm != address(0),"_farm is the zero address");
        _farm = farm;
    }

    function mint(address account, uint256 amount) public override onlyMinter {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}
