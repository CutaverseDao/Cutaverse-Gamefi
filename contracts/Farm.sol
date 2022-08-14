pragma solidity ^0.8.4;

import "./Seed.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TokenV2.sol";

contract Farm is Ownable{

    struct Square {
        Seed fruit;
        //创建时间
        uint createdAt;
        //收获时间，方便于浇水
        uint harvestAt;
        // 0表示空闲，1表示成长中
        uint status;
        //uint rate;
    }


    struct PlantSeed {
        Seed fruit;
        //创建时间
        uint index;

        //uint rate;
    }

    //收获代币
    TokenV2 harvestToken;

    //土地默认长度
    uint256 squareLength;

    uint256 farmerCnt;

    mapping(address => uint256) accountSquareLength;

    mapping(address => mapping(uint256 => Square)) accountSquareMapping;

    constructor (TokenV2 _token,uint256 _squareLength) {
        harvestToken = _token;
        squareLength = _squareLength;
    }


    //记录土地
    //mapping(address => Square[]) fields;

    mapping(address => bool) seedValidityMapping;

    event BuyFruit(address indexed _address,address fruit,uint256 amount);

    event plantFruit(address indexed _address,address fruit,uint256 time);

    event harvestFruit(address indexed _address,address fruit,uint256 time);

    function createFruit(string memory _name,string memory _symbol,uint256 _harvestAt,uint256 _harvestAmount,uint256 _price) public onlyOwner{
        Seed fruit = new Seed(_name,_symbol,_harvestAt,_harvestAmount,_price);
        seedValidityMapping[address(fruit)] = true;
        //TODO  添加事件
    }

    function setFruit(address fruit) public onlyOwner {
        if(seedValidityMapping[fruit]){
            seedValidityMapping[fruit] = false;
        }else{
            seedValidityMapping[fruit] = true;
        }
    }

    //初始创建农场
    function createFarm(address payable _account) public payable{
        Square memory empty = Square({
        fruit: Seed(address(0)),
        createdAt: 0,
        harvestAt: 0,
        status: 0
        });

        for (uint j=1; j <= squareLength; j ++) {
            accountSquareMapping[msg.sender][j] = empty;
        }
        accountSquareLength[msg.sender] = squareLength;
        farmerCnt += 1;
    }

    //种植方法
    function plant(PlantSeed[] memory plantSeed) public {
        uint256 len = plantSeed.length;
        require(len > 0 && len <= accountSquareLength[msg.sender],"plant seed is null");

        for(uint i =0 ;i < len;i++){
            Square memory accountIndexSquare = accountSquareMapping[msg.sender][plantSeed[i].index];
            accountIndexSquare.fruit = plantSeed[i].fruit;
            accountIndexSquare.createdAt = block.timestamp;
            accountIndexSquare.harvestAt = block.timestamp + ISeed(accountIndexSquare.fruit).harvestAt();
            accountIndexSquare.status = 1;
            accountIndexSquare.fruit.burn(msg.sender,1);
            emit plantFruit(msg.sender,address(accountIndexSquare.fruit),block.timestamp);
        }
    }

    //收获方法
    function harvest() public{
        uint length = accountSquareLength[msg.sender];

        for(uint i = 1;i <= length; i++){
            Square memory accountSquare = accountSquareMapping[msg.sender][i];
            if(accountSquare.status == 0){
                continue;
            }
            require(seedValidityMapping[address(accountSquare.fruit)],"this fruit is invalid");
            if(accountSquare.harvestAt<=block.timestamp){
                accountSquare.createdAt = 0;
                accountSquare.harvestAt = 0;
                accountSquare.status = 0;

                harvestToken.mint(msg.sender,accountSquare.fruit.harvestAmount());
                emit harvestFruit(msg.sender,address(accountSquare.fruit),block.timestamp);
                accountSquareMapping[msg.sender][i] = accountSquare;
            }
        }
    }

    //购买种子，需要授权
    function buyFruit(Seed fruit,uint256 amount) public {
        uint256 tokenAmount = fruit.price()*amount;
        uint256 balanceSender = harvestToken.balanceOf(msg.sender);
        require(balanceSender >= tokenAmount,"msg sender balance is not enough");
        harvestToken.transferFrom(msg.sender, address(this),tokenAmount);

        fruit.mint(msg.sender,amount);
        emit BuyFruit(msg.sender,address(fruit),amount);
    }


}
