pragma solidity ^0.8.4;

import "./Farm.sol";

contract CutaverseLens {

    struct BasicMetadata{
        uint256 farmerCount;
        uint256 createFarmPrice;
        uint256 wateringPrice;
        uint256 landUintPrice;
        uint256 wateringRate;
        bool allowAddLand;
    }

    // 获取基础信息
    function getBasicInfo(Farm farm) public view returns(BasicMetadata memory){
        return BasicMetadata({
            farmerCount: farm.farmerCount(),
            createFarmPrice: farm.createFarmPrice(),
            wateringPrice: farm.wateringPrice(),
            landUintPrice: farm.landUintPrice(),
            wateringRate: farm.wateringRate(),
            allowAddLand: farm.allowAddLand()
        });
    }

    struct FarmMetadata{
        uint256 landCount;
        uint256[] gains;
        uint256[] harvestTimes;
        ISeed[] seeds;
    }

    function getFarmInfo(Farm farm, address farmer) public view returns(FarmMetadata memory){
        uint256 _landCount = farm.accountLandCount(farmer);
        uint256[] memory _gains = new uint256[](_landCount);
        uint256[] memory _harvestTimes = new uint256[](_landCount);
        ISeed[] memory _seeds = new ISeed[](_landCount);

        for(uint i=0; i<_landCount;i++){
            (ISeed _seed, ,uint256 _gain, uint256 _harvestTime) = farm.accountLandMapping(farmer,i);
            _seeds[i] = _seed;
            _gains[i] = _gain;
            _harvestTimes[i] = _harvestTime;
        }

        return FarmMetadata({
            landCount: _landCount,
            gains:_gains,
            harvestTimes: _harvestTimes,
            seeds: _seeds
        });
    }
}
