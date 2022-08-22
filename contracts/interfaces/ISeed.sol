pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


interface ISeed is IERC20Metadata{

    function restFarm(address farm) external virtual;
    function mint(address account, uint256 amount) external virtual;
    function burn(uint256 amount) external virtual;

    function farm() external view virtual returns(address);
    function price() external view virtual returns(uint256);
    function yield() external view virtual returns(uint256);
    function matureTime() external view virtual returns(uint256);
    function oneDayLimit() external view virtual returns(uint256);

}
