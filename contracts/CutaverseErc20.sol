// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract CutaverseErc20 is ERC20Capped,Ownable{
    address public farm;

    constructor() ERC20Capped(100000000) ERC20("Cutaverse", "CTV") {}

    modifier onlyMinter() {
        require(owner() == _msgSender()
            || (farm != address(0) && farm == _msgSender()), "Ownable: caller is not the minter");
        _;
    }

    function mint(address account, uint256 amount) public onlyMinter {
        _mint(account, amount);
    }
}
