pragma solidity ^0.8.4;

import "../storage/FarmStorage.sol";

abstract contract IFarm is FarmStorage{

    event ResetFeeTo(address indexed oldFeeTo, address indexed newFeeTo);
    event ResetCreateFarmPrice(uint256 oldCreateFarmPrice, uint256 newCreateFarmPrice);
    event ResetLandUintPrice(uint256 oldLandUintPrice, uint256 newLandUintPrice);
    event ResetWateringRate(uint256 oldLandWateringRate, uint256 newLandWateringRate);

}
