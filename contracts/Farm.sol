pragma solidity ^0.8.4;

import "./Seed.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Token.sol";

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

    //收获代币
    TokenV2 harvestToken;

    //土地默认长度
    uint256 squareLength;

    uint256 farmerCnt;

    mapping(address => uint256) accountSquareLength;

    constructor (TokenV2 _token,uint256 _squareLength) {
        harvestToken = _token;
        squareLength = _squareLength;
    }


    //记录土地
    mapping(address => Square[]) fields;

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
        Square[] storage land = fields[msg.sender];
        Square memory empty = Square({
        fruit: Seed(address(0)),
        createdAt: 0,
        harvestAt: 0,
        status: 0
        });

        for (uint j=0; j < squareLength; j += 1) {
            land.push(empty);
        }
        accountSquareLength[msg.sender] = squareLength;
        farmerCnt += 1;
    }

    //种植方法
    function plant(Square[] memory squares) public {
        uint256 len = squares.length;
        require(len > 0 && len <= accountSquareLength[msg.sender],"plant seed is null");
        Square[] storage afterLand = new Square[](squares.length);
        for(uint i = 0;i<len;i++){
            Square memory accountSquare = squares[i];
            if(accountSquare.status == 1){
                afterLand[i]= accountSquare;
                continue;
            }
            require(seedValidityMapping[address(accountSquare.fruit)],"this fruit is invalid");
            accountSquare.createdAt = block.timestamp;
            accountSquare.harvestAt = block.timestamp + ISeed(accountSquare.fruit).harvestAt();
            accountSquare.status = 1;
            accountSquare.fruit.burn(msg.sender,1);
            afterLand[i]= accountSquare;
            emit plantFruit(msg.sender,address(accountSquare.fruit),block.timestamp);
        }
        fields[msg.sender] = afterLand;
    }

    //收获方法
    function harvest() public{
        Square[] storage beforeLand = fields[msg.sender];
        uint256 length = beforeLand.length;
        require(length > 0 && length <= squareLength,"plant seed is null");
        Square[] storage afterLand = new Square[](beforeLand.length);

        for(uint i = 0;i<length;i++){
            Square memory accountSquare = beforeLand[i];
            if(accountSquare.status == 0){
                afterLand[i] = accountSquare;
                continue;
            }
            require(seedValidityMapping[address(accountSquare.fruit)],"this fruit is invalid");
            if(accountSquare.harvestAt<=block.timestamp){
                accountSquare.createdAt = 0;
                accountSquare.harvestAt = 0;
                accountSquare.status = 0;

                harvestToken.mint(msg.sender,accountSquare.fruit.harvestAmount());
                emit harvestFruit(msg.sender,address(accountSquare.fruit),block.timestamp);
            }
            afterLand[i] = accountSquare;
        }
        fields[msg.sender] = afterLand;
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
