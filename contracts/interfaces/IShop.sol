pragma solidity ^0.8.4;


interface IShop{

    function resetFeeTo(address payable _feeTo) external;
    function addSeed(address seed,uint256 price) external;
    function isBankSeed(address seed) external view returns (bool);
//    function getBankSeedCount() external view returns (uint256) ;
//    function getBankSeedAddress(uint256 pid) external view returns (address);
//    function allBankSeed() external view returns(address[] memory);
    function buySeed(address _seed, uint256 count) external;
    function isOverrun(address _seed, uint256 _count) external view returns(bool);

    event ResetFeeTo(address indexed oldFeeTo,address indexed newFeeTo);
    event AddSeed(address indexed seed,uint256 price);
    event BuySeed(address indexed user,address indexed seed,uint256 amount);
}
