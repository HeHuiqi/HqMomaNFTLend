
// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.15;

import "./interface/ILenderMasterEther.sol";
import "./interface/IBorrowerMaster.sol";
import "./interface/IMERC721.sol";
import "./interface/IPriceOracle.sol";
// 字段基本和页面保持一致
struct Market{
    string  name;
    address marketAddress;
    address cnftAddress;//抵押nft
    address lnftAddress;//债权nft
    address bnftAddress;//债务nft
    uint256 floorPrice;
    uint256 tokenAvailable; // 可借数量
    uint256 tokenTotalBorrows; //已借出数量
    uint256 minRequirement;
    uint256 collateralFactor; //抵押率 除以1e18
    uint256 baseRatePerSecond;// 每秒基础利率
    uint256 multiplierPerSecond;// 每秒利用率乘子
    uint256 borrowRatePerSecond;//每秒借款利率
    uint256 penaltyFactor; //惩罚系数 除以1e4
    uint256 utiliaztion; //利用率  除以1e18
    uint256 borrowApr; //借款利率
    uint256 activeCollterals;
    uint256 nfts;
    uint256 exchangeRate; //兑换率
    uint256 minBorrowSeconds; //最小借款周期
    uint256 maxBorrowSeconds; //最大借款周期

}

struct MarketSupplyOrder{
    string name;
    address marketAddress;
    address cnftAddress;//抵押nft
    address lnftAddress;//债权nft
    address bnftAddress;//债务nft
    uint256 floorPrice;
    address lender;
    uint256 supply;
    uint256 updateTime;//余额最后更新时间
}
// 借贷订单
struct Order{
    string name;
    string imageUrl;
    address marketAddress;
    uint256 floorPrice;
    address assetAddress;
    uint256 tokenId;
    address lender;
    address borrower;
    address cnftAddress;//抵押nft
    address lnftAddress;//债权nft
    address bnftAddress;//债务nft
    uint256 loanValue;
    uint256 startTime;
    uint256 expireTime; //结束时间
    uint256 minInterestRepayment;
    uint256 repayment;
    uint256 borrowRatePerSecond; //除以1e18
    uint256 penaltyFactor; //惩罚系数 除以1e4
    uint256 changeSeconds; //经历的秒数
    uint256 generatedInterest;// 利息
}
struct Liquidity{
    string name;
    
    address marketAddress;
    uint256 availableToLend; //总共可借出数量
    uint256 lent; //总共已借出数量
    uint256 availableInMarket; //在某个市场可借出多少
    uint256 lentInMarket;//在某个市场已借出多少
    uint256 updateTime; //最后一次存钱的时间
    uint256 minRequirement;//该市场最少可以借多少
    uint256 position; //在某个市场的位置
    uint256 supportMarkets; //当前支持几个市场
    uint256 borrowApr;
    uint256 minBorrowSeconds; //最小借款周期
    uint256 maxBorrowSeconds; //最大借款周期
    bool isLender;
}

struct UserAsset{
    string name;
    address nftAddress;
    uint256 tokenId;
    string imageUrl;
    uint256 assetType; // 资产类型 1:原始NFT 2:债务NFT 3:债券NFT 
    address marketAddress; //市场地址
    uint256 availableToBorrow;//可借多少钱
    uint256 floorPrice;
    uint256 borrowApr;//借款利率
    uint256 borrowRatePerSecond;//每秒借款利率
    uint256 penaltyFactor; //惩罚系数 除以1e4
    uint256 minBorrowSeconds; //最小借款周期
    uint256 maxBorrowSeconds; //最大借款周期
}



interface IMQuery{
    //市场详情
    function marketDetail(address marketAddress) external view returns(Market memory _market);
    //所有的市场
    function allMarket() external view returns(Market[] memory _makrets);

    //订单详情
    function orderDetail(address marketAddress,uint256 tokenId) external view returns(Order memory _order);
    //市场提供的订单
    function marketSupplyOrders(address marketAddress) external view returns(MarketSupplyOrder[]  memory _orders);

    //用户在某个市场的借贷订单
    function userOdersInMarket(address user, address marketAddress, bool isLender) external view returns(Order[] memory _orders);
    //用户借贷订单，注意这里在获取数据后遍历将其转为一维数组
    function userOrders(address user,bool isLender) external view  returns(Order[][] memory _orders);
    //用户在某个市场的LP
    function userLiquidityInMarket(address user, address marketAddress) external view returns(Liquidity memory _lp);
    //用户所有LP
    function userLiquidity(address user) external view  returns(Liquidity[] memory _lps);
    //用户在某个市场已经借出去的资产
    function userLentInMarket(address marketAddress,address lnftAddress,address user) external view returns (uint256 _lentInMarket);
    //用户在某个市场的资产
    function userAssetInMarket(address user,address marketAddress) external view returns (UserAsset[] memory _assets);
    //用户在所有市场的资产，注意这里在获取数据后遍历将其转为一维数组
    function userAllAsset(address user) external view  returns (UserAsset[][] memory _allAssets);
}
