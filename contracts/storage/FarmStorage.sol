pragma solidity ^0.8.4;

import "../Cutaverse.sol";
import "../Seed.sol";

contract FarmStorage {

    struct Land {
        Seed seed;
        uint index;
        uint gain;
        uint harvestTime;
    }

    struct Event {
        Action action;
        Land[] lands;
    }

    enum Action {
        Plant, Watering, Weeding, Harvest
    }

    uint256 public constant initialLandCount = 4;
    uint256 public constant maxLandCount = 16;

    Cutaverse cutaverse;
    address public feeTo;

    uint256 public createFarmPrice;
    uint256 public wateringPrice;
    uint256 public landUintPrice;

    uint256 public wateringRate;
//    uint256 public weedingRate;
    bool public allowAddLand;

    uint256 public farmerCount;

    mapping(address => uint256) accountLandCount;
    mapping(address => mapping(uint256 => Land)) accountLandMapping;
}
