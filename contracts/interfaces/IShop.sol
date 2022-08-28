pragma solidity ^0.8.4;


abstract contract ISeed{

    event AddSeed(address indexed seed);
    event Shopping(address indexed user,address indexed seed,uint256 amount);
}
