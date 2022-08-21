pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface ICutaverse is IERC20Metadata{

    function farm() external view returns(address);
    function cap() external view returns (uint256);

    function restFarm(address farm) external;
    function mint(address account, uint256 amount) external;
}
