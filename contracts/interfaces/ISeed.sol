pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface ISeed is IERC20Metadata{

    function restFarm(address farm) external;
    function mint(address account, uint256 amount) external;
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;

    function farm() external view returns(address);
    function price() external view returns(uint256);
    function yield() external view returns(uint256);
    function matureTime() external view returns(uint256);
    function oneDayLimit() external view returns(uint256);

}
