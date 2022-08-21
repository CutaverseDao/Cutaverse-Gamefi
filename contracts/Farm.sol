pragma solidity ^0.8.4;

import "./Seed.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./CutaverseErc20.sol";

contract Farm is Ownable{
    using SafeMath for uint256;

    struct Land {
        Seed seed;
        uint harvestTime;
        uint index;
    }

    struct Event {
        Action action;
        Land[] lands;
    }

    IERC20 harvest;

    uint256 public initLandCount;
    uint256 public maxLandCount;
    uint256 public farmerCnt;
    uint256 public createFarmPrice;
    uint256 public perLandPrice;

    uint256 public wateringRate;
    uint256 public weedingRate;


    address public _feeTo;

    bool public allowAddLand;

    mapping(address => uint256) accountLandCount;
    mapping(address => mapping(uint256 => Land)) accountLandMapping;
    mapping(address => bool) seedValidityMapping;

    event CreatedFarm(address indexed user, uint256 indexed blockTime);
    event CreatedFruit(address indexed fruit, uint256 indexed blockTime);
    event ExpansionLand(address indexed user, uint256 indexed count);

    enum Action {
        Plant, Watering, Weeding, Harvest
    }

    constructor (CutaverseErc20 _harvest, uint256 _maxLandCount, uint256 _perLandPrice) {
        harvest = _harvest;
        maxLandCount = _maxLandCount;
        perLandPrice = _perLandPrice;
    }

    function createFruit(string memory _name,string memory _symbol,uint256 _harvestTime,uint256 _yield,uint256 _price) public onlyOwner{
        Seed fruit = new Seed(_name,_symbol,_harvestTime,_yield,_price);
        seedValidityMapping[address(fruit)] = true;
        emit CreatedFruit(address(fruit),block.timestamp);
    }

    function addLand(uint256 _count) public payable{
        require(allowAddLand);
        require(accountLandCount[msg.sender].add(_count) <= maxLandCount);
        require(msg.value >= _count.mul(perLandPrice), "The ether value sent is not correct");

        payable(_feeTo).transfer(msg.value);

        accountLandCount[msg.sender] = accountLandCount[msg.sender].add(_count);
        emit ExpansionLand(msg.sender,_count);
    }

    function createFarm() public payable{
        require(accountLandCount[msg.sender] = 0);
        require(msg.value >= createFarmPrice, "The ether value sent is not correct");
        payable(_feeTo).transfer(msg.value);

        for (uint j= 1; j <= initLandCount; j ++) {
            Land memory empty = Land({
                seed: Seed(address(0)),
                harvestTime: 0,
                index: j
            });
            accountLandMapping[msg.sender][j] = empty;
        }
        accountLandCount[msg.sender] = initLandCount;
        farmerCnt += 1;

        emit CreatedFarm(msg.sender,block.timestamp);
    }

    function operate(Event memory events) public {
        Action action = events.action;
        Land[] lands = events.lands;
        uint256 len = lands.length;
        require(len > 0 && len <= accountLandCount[msg.sender],"plant seed is null");

        if(action == Action.Plant){
            plant(lands);
        }else if(action == Action.Watering){
            //TODO 减少harvestTime
        }else if(action == Action.Weeding){
            //TODO 减少harvestTime
        }else if(action == Action.Harvest){
            harvest();
        }
    }

    function plant(Land[] lands) private {
        for(uint i =0 ;i < lands.length;i++){
            require(land.seed == address(0));
            Land _land = lands[i];
            Land storage land = accountLandMapping[msg.sender][_land[i].index];

            //TODO 合法种子判断
            require(_land[i].seed.seed != address(0));
            land.seed = _land[i].seed;

            land.harvestTime = block.timestamp.add(land.seed.harvestTime);
            land.seed.burn(msg.sender,1);
        }
    }

    function watering(Land[] memory land) public{
        uint256 len = land.length;
        require(len > 0 && len <= accountLandCount[msg.sender],"plant seed is null");

        Land _land = accountLandMapping[msg.sender][land[0].index];
        Seed seed = _land.seed;
        _land.harvestTime = _land.harvestTime.mul(1-wateringRate);
    }

    function weeding(Land[] memory land) public{
        uint256 len = land.length;
        require(len > 0 && len <= accountLandCount[msg.sender],"plant seed is null");

        Land _land = accountLandMapping[msg.sender][land[0].index];
        Seed seed = _land.seed;
        seed.harvestTime = seed.harvestTime.mul(1-weedingRate);
    }

    //10,80
    function steal(address account, Land land) public{
        //花费价值20%,偷菜80%
        //20%*10%
        //概率30%，失败70%，成功，收成归偷菜者，失败花费的90%归菜农，10% 归Feeto
    }

    function harvest() private{
        uint length = accountLandCount[msg.sender];
        require(length >0);

        for(uint i = 1;i <= length; i++){
            Land storage land = accountLandMapping[msg.sender][i];
            if(block.timestamp < land.harvestTime){
                continue;
            }

            land.seed = address(0);
            land.harvestTime = 0;

            harvest.mint(msg.sender,land.seed.yield);
        }
    }

    function buySeed(Seed seed,uint256 count) public {
        uint amount = seed.price().mul(count);
        require(harvest.balanceOf(msg.sender) >= seed.price().mul(count));


        harvest.transferFrom(msg.sender, _feeTo, amount);

        seed.mint(msg.sender, count);
    }


    //减半周期
}
