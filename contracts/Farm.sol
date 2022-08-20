pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./Seed.sol";
import "./CutaverseErc20.sol";
import "./interfaces/IFarm.sol";

contract Farm is IFarm,Ownable,Pausable{

    constructor (CutaverseErc20 _harvest, uint256 _maxLandCount, uint256 _perLandPrice) {
        harvest = _harvest;
        maxLandCount = _maxLandCount;
        perLandPrice = _perLandPrice;
    }

    function addSeed(address seed) public onlyOwner returns (bool) {
        require(seed != address(0), "Seed is the zero address");
        require(!isBankSeed(seed),"The seed is already there");
        return EnumerableSet.add(seedBank, seed);
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

    function createFarm() public payable whenNotPaused{
        require(accountLandCount[msg.sender] = 0,"You already own a farm");
        require(msg.value >= createFarmPrice, "The ether value sent is not correct");
        payable(_feeTo).transfer(msg.value);
        uint defaultLandCount = 4;

        for (uint j= 0; j < defaultLandCount; j ++) {
            Land memory empty = Land({
                seed: Seed(address(0)),
                index: j,
                gain: 0,
                harvestTime: 0
            });
            accountLandMapping[msg.sender][j] = empty;
        }
        accountLandCount[msg.sender] = defaultLandCount;
        farmerCount = farmerCount.add(1);
    }

//    function operate(Event memory events) public {
//        Action action = events.action;
//        Land[] lands = events.lands;
//        uint256 len = land.length;
//        require(len > 0 && len <= accountLandCount[msg.sender],"The number of land assets is wrong");
//
//        if(action == Action.Plant){
//            plant(lands);
//        }else if(action == Action.Watering){
//            //TODO 减少harvestTime
//        }else if(action == Action.Weeding){
//            //TODO 减少harvestTime
//        }else if(action == Action.Harvest){
//            harvest();
//        }
//    }

    function buySeed(Seed seed, uint256 count) public whenNotPaused{
        require(isBankSeed(seed),"An invalid seed");
        require(count >0, "Invalid quantity");

        uint amount = seed.price().mul(count);
        harvest.transferFrom(msg.sender, feeTo, amount);

        seed.mint(msg.sender, count);
    }

    function plant(Land[] lands) private whenNotPaused{
        for(uint i =0 ;i < lands.length;i++){
            Land _land = lands[i];
            uint index = _land.index;
            Seed seed = _land.seed;

            Land storage land = accountLandMapping[msg.sender][index];
            require(land.seed == address(0),"The land is already planted");
            require(isBankSeed(seed),"An invalid seed");

            land.seed = seed;
            land.harvestTime = block.timestamp.add(seed.harvestTime);
            land.gain = land.seed.yield;
            land.seed.burn(msg.sender,1);
        }
    }

    function watering(Land[] memory lands) public payable whenNotPaused{
        uint256 len = lands.length;
        require(len >= 0, "The lands count sent is not correct");
        require(msg.value >= wateringPrice.mul(len), "The ether value sent is not correct");

        payable(_feeTo).transfer(msg.value);

        for(uint i =0 ;i < lands.length;i++){
            Land _land = lands[i];
            uint index = _land.index;

            Land storage land = accountLandMapping[msg.sender][index];

            uint256 finalHarvestTime = land.harvestTime.mul(SafeMath.sub(1,wateringRate));

            require(land.seed != address(0) && finalHarvestTime > block.timestamp,"");
            land.harvestTime = finalHarvestTime;
        }
    }

    function harvest() public{
        uint length = accountLandCount[msg.sender];
        require(length >0 ,"You don't have your own farm yet");

        for(uint i = 0;i < length; i++){
            Land storage land = accountLandMapping[msg.sender][i];
            if(land.seed != address(0) && block.timestamp < land.harvestTime){
                continue;
            }

            land.seed = address(0);
            land.gain = 0;
            land.harvestTime = 0;

            cutaverse.mint(msg.sender,land.gain);
        }
    }

    //    function removeBankSeed(address seed) public onlyOwner whenPaused {
    //        require(paused(), "No suspension");
    //        uint256 length = getBankSeedCount();
    //        EnumerableSet.remove(seedBank, dAddress);
    //    }

    //    function addLand(uint256 _count) public payable{
    //        require(allowAddLand);
    //        require(accountLandCount[msg.sender].add(_count) <= maxLandCount);
    //        require(msg.value >= _count.mul(perLandPrice), "The ether value sent is not correct");
    //
    //        payable(_feeTo).transfer(msg.value);
    //
    //        accountLandCount[msg.sender] = accountLandCount[msg.sender].add(_count);
    //    }

    //    function weeding(Land[] memory land) public{
    //        //需要质押 hoe（直到成熟解开质押）
    //        for(uint i =0 ;i < lands.length;i++){
    //            Land _land = lands[i];
    //            uint index = _land.index;
    //
    //            Land storage land = accountLandMapping[msg.sender][index];
    //            require(land.seed == address(0) && land.harvestTime.add(1-wateringRate) < block.timestamp,"");
    //            land.harvestTime = land.harvestTime.add(1-wateringRate);
    //        }
    //    }

    //    function steal(address account, Land land) public{
    //        //需要花费 x eth (每块土地每天只能偷盗3次)
    //        //30% 偷盗者胜，成功 x*20% 给到管理员，x*80% 返还，收成归偷盗者
    //        //10% 双方都失败，x 都给到管理员，收成无
    //        //60% 农场主胜, x*20% 给到管理员，x*80% 给到农民
    //    }
}
