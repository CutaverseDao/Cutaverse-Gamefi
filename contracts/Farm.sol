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
        uint plantTime;
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

    address public _feeTo;

    bool public allowAddLand;

    mapping(address => uint256) accountLandCount;
    mapping(address => mapping(uint256 => Land)) accountLandMapping;


    enum Action {
        Plant, Watering, Weeding, Harvest
    }

    constructor (CutaverseErc20 _harvest, uint256 _maxLandCount, uint256 _perLandPrice) {
        harvest = _harvest;
        maxLandCount = _maxLandCount;
        perLandPrice = _perLandPrice;
    }

    function addLand(uint256 _count) public payable{
        require(allowAddLand);
        require(accountLandCount[msg.sender].add(_count) <= maxLandCount);
        require(msg.value >= _count.mul(perLandPrice), "The ether value sent is not correct");

        payable(_feeTo).transfer(msg.value);

        accountLandCount[msg.sender] = accountLandCount[msg.sender].add(_count);
    }

    function createFarm(address _account) public payable{
        require(accountLandCount[msg.sender] = 0);
        require(msg.value >= _count.mul(perLandPrice), "The ether value sent is not correct");
        payable(_feeTo).transfer(msg.value);

        for (uint j=1; j <= initLandCount; j ++) {
            Land memory empty = Land({
                seed: Seed(address(0)),
                plantTime: 0,
                index: j
            });
            accountLandMapping[msg.sender][j] = empty;
        }
        accountLandCount[msg.sender] = initLandCount;
        farmerCnt += 1;
    }

    function plant(Event memory events) public {
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
            Land land = lands[i];

            Land storage land = accountLandMapping[msg.sender][land[i].index];
            require(land.seed == address(0));

            land.seed = land[i].seed;
            land.plantTime = block.timestamp;
            land.seed.burn(msg.sender,1);
        }
    }

    function watering(Land[] memory land) public{
        uint256 len = land.length;
        require(len > 0 && len <= accountLandCount[msg.sender],"plant seed is null");

    }

    function harvest() private{
        uint length = accountLandCount[msg.sender];
        require(length >0);

        for(uint i = 1;i <= length; i++){
            Land storage land = accountLandMapping[msg.sender][i];
            uint plantTime = land.plantTime;
            uint harvestTime = land.seed.harvestTime();

            if(block.timestamp < plantTime.add(harvestTime)){
                continue;
            }

            land.seed = address(0);
            land.plantTime = 0;

            harvest.mint(msg.sender,land.seed.yield);
        }
    }

    function buySeed(Seed seed,uint256 count) public {
        uint amount = seed.price().mul(count);
        require(harvest.balanceOf(msg.sender) >= seed.price().mul(count));
        harvest.transferFrom(msg.sender, _feeTo, amount);

        seed.mint(msg.sender, count);
    }
}
