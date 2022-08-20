pragma solidity ^0.4.0;

contract FarmStorage {
    using SafeMath for uint256;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private seedBank;

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

    IERC20 cutaverse;

    uint256 public maxLandCount;
    uint256 public farmerCount;
    uint256 public createFarmPrice;
    uint256 public wateringPrice;
    uint256 public landUintPrice;

    uint256 public wateringRate;
    uint256 public weedingRate;

    address public feeTo;

    bool public allowAddLand;

    mapping(address => uint256) accountLandCount;
    mapping(address => mapping(uint256 => Land)) accountLandMapping;
}
