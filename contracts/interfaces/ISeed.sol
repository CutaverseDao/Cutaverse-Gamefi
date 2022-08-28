pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


interface ISeed is IERC20Metadata{

    function restShop(address shop) external virtual;
    function mint(address account, uint256 amount) external virtual;
    function burnFrom(address account, uint256 amount) external virtual;

    function shop() external view virtual returns(address);
    function yield() external view virtual returns(uint256);
    function matureTime() external view virtual returns(uint256);

}
