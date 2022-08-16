// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract CutaverseErc20 is ERC20Capped {
    constructor() ERC20Capped(100000000) ERC20("Cutaverse", "CTV") {}
}
