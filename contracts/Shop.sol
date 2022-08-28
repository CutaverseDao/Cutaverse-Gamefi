pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/ISeed.sol";



contract Shop is Ownable{


    mapping(address => mapping(uint256 => uint256)) seedLimitTime;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private seedBank;


    constructor (){

    }

    function isBankSeed(address seed) public view returns (bool) {
        return EnumerableSet.contains(seedBank, seed);
    }

    function getBankSeedCount() public view returns (uint256) {
        return EnumerableSet.length(seedBank);
    }

    function getBankSeedAddress(uint256 pid) public view returns (address){
        require(pid <= getBankSeedCount() - 1, "Not find this seed");
        return EnumerableSet.at(seedBank, pid);
    }

    function addSeed(address seed) public onlyOwner returns (bool) {
        require(seed != address(0), "Seed is the zero address");
        require(!isBankSeed(seed),"The seed is already there");
        emit AddSeed(seed);
        return EnumerableSet.add(seedBank, seed);
    }

    function allBankSeed() public view returns(address[] memory){
        return EnumerableSet.values(seedBank);
    }

    function buySeed(address _seed, uint256 count) public nonReentrant whenNotPaused{
        require(isBankSeed(_seed),"An invalid seed");
        require(count >0, "Invalid quantity");

        ISeed seed = ISeed(_seed);
        uint amount = seed.price().mul(count.div(10**seed.decimals()));
        cutaverse.transferFrom(msg.sender, feeTo, amount);

        seed.mint(msg.sender, count);

        emit Shopping(msg.sender,_seed,count);
        //限售TODO
    }


}
