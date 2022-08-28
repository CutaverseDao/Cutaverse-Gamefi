// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IShop.sol";
import "./interfaces/ISeed.sol";
import "./interfaces/ICutaverse.sol";

contract Shop is IShop,Ownable,Pausable,ReentrancyGuard{
    using SafeMath for uint256;

    struct Limit{
        uint256 timeline;
        uint256 times;
    }

    struct SeedContainer{
        ISeed seed;
        uint256 price;
        bool onSale;
    }

    address public feeTo;
    ICutaverse public cutaverse;

    uint256 public perSeedBuyLimit;
    uint256 public perUserBuyLimit;

    mapping(address => Limit) public seedBuyLimit;
    mapping(address => Limit) public userBuyLimit;

    mapping(address => SeedContainer) public seedContainer;
    mapping(address => uint256) public seedContainerPid;

    constructor (address _feeTo, ICutaverse _cutaverse,uint256 _perSeedBuyLimit, uint256 _perUserBuyLimit){
        require(_feeTo != address(0), "_feeTo is the zero address");
        require(address(_cutaverse) != address(0), "_cutaverse is the zero address");

        feeTo = _feeTo;
        cutaverse = _cutaverse;
        perSeedBuyLimit = _perSeedBuyLimit;
        perUserBuyLimit = _perUserBuyLimit;
    }

    function resetFeeTo(address payable _feeTo) external override onlyOwner{
        require(_feeTo != address(0), "_FeeTo is the zero address");
        address oldFeeTo = feeTo;
        feeTo = _feeTo;

        emit ResetFeeTo(oldFeeTo, _feeTo);
    }

    function addSeed(address seed, uint256 price) public override onlyOwner {
        require(seed != address(0), "Seed is the zero address");
        require(!isBankSeed(seed),"The seed is already there");

        SeedContainer storage _seedContainer = seedContainer[seed];
        _seedContainer.seed = ISeed(seed);
        _seedContainer.price = price;
        _seedContainer.onSale = true;

        seedContainerPid[seed] = seedContainerPid[seed].add(1);

        emit AddSeed(seed,price);
    }

    function isBankSeed(address seed) public view override returns (bool) {
        return seedContainerPid[seed] > 0 ;
    }

//    function getBankSeedCount() public view returns (uint256) {
//        return EnumerableSet.length(seedBank);
//    }
//
//    function getBankSeedAddress(uint256 pid) public view returns (address){
//        require(pid <= getBankSeedCount() - 1, "Not find this seed");
//        return EnumerableSet.at(seedBank, pid);
//    }
//
//    function allBankSeed() public view returns(address[] memory){
//        return EnumerableSet.values(seedBank);
//    }

    function buySeed(address _seed, uint256 _count) public override nonReentrant whenNotPaused{
        require(isBankSeed(_seed),"An invalid seed");
        require(_count >0, "Invalid quantity");

        (bool overrunSeed, bool overtimeSeed) = isOverrunSeed(_seed,_count);
        (bool overrunUser, bool overtimeUser) = isOverrunUser(_seed,_count);
        require(!overrunSeed && !overrunUser,"Exceeding the seed purchase limit");

        if(overtimeSeed){
            Limit storage seedLimit = seedBuyLimit[_seed];
            seedLimit.times = _count;
            seedLimit.timeline = block.timestamp;
        }

        if(overtimeUser){
            Limit storage userLimit = userBuyLimit[_seed];
            userLimit.times = _count;
            userLimit.timeline = block.timestamp;
        }

        SeedContainer storage _seedContainer = seedContainer[_seed];
        ISeed seed = ISeed(_seed);
        uint amount = _seedContainer.price.mul(_count.div(10**seed.decimals()));
        cutaverse.transferFrom(msg.sender, feeTo, amount);

        seed.mint(msg.sender, _count);

        emit BuySeed(msg.sender,_seed,_count);
    }

    function isOverrun(address _seed, uint256 _count) public view override returns(bool){
        (bool overrunSeed,) = isOverrunSeed(_seed,_count);
        (bool overrunUser,) = isOverrunUser(_seed,_count);

        return overrunSeed || overrunUser;
    }

    function isOverrunSeed(address _seed, uint256 _count) internal view returns(bool,bool){
        Limit storage limit = seedBuyLimit[_seed];
        uint256 timeline  = limit.timeline;
        uint256 times  = limit.times;

        bool isOverrun = times.add(_count) > perSeedBuyLimit;
        bool isOvertime = timeline.add(24*60*60) > block.timestamp;

        if(isOvertime && _count > perSeedBuyLimit){
            return (true,true);
        }

        if(!isOvertime && isOverrun){
            return (true,false);
        }

        return (false, isOvertime);
    }

    function isOverrunUser(address _seed, uint256 _count) internal view returns(bool,bool){
        Limit storage limit = userBuyLimit[_seed];
        uint256 timeline  = limit.timeline;
        uint256 times  = limit.times;

        bool isOverrun = times.add(_count) > perUserBuyLimit;
        bool isOvertime = timeline.add(24*60*60) > block.timestamp;

        if(isOvertime && _count > perUserBuyLimit){
            return (true,true);
        }

        if(!isOvertime && isOverrun){
            return (true,false);
        }

        return (false, overtime);
    }
}
