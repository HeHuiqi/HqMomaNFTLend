// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.15;

import "./IMQuery.sol";

contract MQuery is IMQuery {
    address public lenderMasterAddress;

    constructor(address _lenderMasterAddress){
        lenderMasterAddress = _lenderMasterAddress;
    }
    //市场详情
    function marketDetail(address marketAddress)
        public
        view
        override
        returns (Market memory _market)
    {
        ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
        IBorrowerMaster borrower = IBorrowerMaster(marketAddress);
        (
            address lenderNFT,
            uint256 totalMCash,
            uint256 collateralFactor
        ) = lender.marketStates(marketAddress);
        IMERC721 erc721 = IMERC721(borrower.collateral());
        _market.name = erc721.name();
        _market.marketAddress = marketAddress;
        _market.cnftAddress = borrower.collateral();
        _market.lnftAddress = lenderNFT;
        _market.bnftAddress = borrower.borrowerNFT();
        _market.floorPrice = IPriceOracle(lender.oracle()).getFloorPriceByMarket(marketAddress);
        _market.tokenAvailable = totalMCash;
        _market.tokenTotalBorrows =  borrower.tokenTotalBorrows(address(0));
        _market.collateralFactor = collateralFactor;
        _market.multiplierPerSecond = borrower.multiplierPerSecond();
        _market.baseRatePerSecond = borrower.baseRatePerSecond();
        _market.utiliaztion = borrower.utilizationRate(
            _market.tokenAvailable,
            _market.tokenTotalBorrows
        );
        _market.penaltyFactor = borrower.penaltyFactor();
        _market.minRequirement = _market.floorPrice * _market.collateralFactor / 1e18;
        _market.activeCollterals = erc721.balanceOf(marketAddress);
        _market.nfts = erc721.totalSupply();
        _market.maxBorrowSeconds = uint256(borrower.maxBorrowSeconds());

        // uint256 myBorrowRatePerSecond = _market.utiliaztion * _market.multiplierPerSecond() + _market.baseRatePerSecond();

        uint40 borrowRatePerSecond = borrower.getBorrowRatePerSecond(_market.tokenAvailable,_market.tokenTotalBorrows);
        _market.borrowRatePerSecond = uint256(borrowRatePerSecond);
        //计算时类型要一致，否则调用报错
        _market.borrowApr = _market.borrowRatePerSecond * uint256(borrower.secondsPerYear());
        /*
        uint256 threeDaysRate = uint256(3*24*3600) * uint256(borrowRatePerSecond);
        uint256 maxRate = _market.maxBorrowSeconds * uint256(borrowRatePerSecond);
        uint256[] memory _apr = new uint256[](2);
        _apr[0] = threeDaysRate;
        _apr[1] = maxRate;
        _market.apr = _apr;

        uint256[] memory _repayment = new uint256[](2);
        _repayment[0] = _market.tokenAvailable +   _market.tokenAvailable*threeDaysRate/1e18;
        _repayment[1] = _market.tokenAvailable + _market.tokenAvailable*maxRate/1e18;
        _market.repayment = _repayment;
        */

        _market.exchangeRate = lender.exchangeRate();

        return _market;
    }
    //所有的市场
    function allMarket()
        public
        view
        override
        returns (Market[] memory _markets)
    {
        ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
        address[] memory marketsAddress = lender.getAllMarkets();
        uint256 marketLen = marketsAddress.length;
        _markets = new Market[](marketLen);
        for (uint256 i = 0; i < marketLen; i++) {
            _markets[0] = marketDetail(marketsAddress[i]);
        }
        return _markets;
    }
    //市场提供的订单
    function marketSupplyOrders(address marketAddress)
        external
        view
        override
        returns (MarketSupplyOrder[] memory _orders)
    {
        ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
        IBorrowerMaster borrower = IBorrowerMaster(marketAddress);
        IPriceOracle oracle = IPriceOracle(lender.oracle());
        (
            address[] memory lenders,
            uint256[] memory times,
            uint256[] memory balances
        ) = lender.getMarketQueue(
                marketAddress,
                0,
                lender.getAllMarkets().length
            );
        _orders = new MarketSupplyOrder[](lenders.length);
        for (uint256 i = 0; i < lenders.length; i++) {
            MarketSupplyOrder memory _order = _makeDefaultSupplyOrder();
            _order.marketAddress = marketAddress;
            _order.cnftAddress = borrower.collateral();
            _order.lnftAddress = borrower.lenderNFT();
            _order.bnftAddress = borrower.borrowerNFT();
            _order.updateTime = times[i];
            _order.lender = lenders[i];
            _order.supply = balances[i];
            _order.marketAddress = marketAddress;
            _order.floorPrice = oracle.getFloorPriceByMarket(marketAddress);
            _order.name = IMERC721(borrower.collateral()).name();
            _orders[i] = _order;
        }

        return _orders;
    }
    //订单详情
    function orderDetail(address marketAddress, uint256 tokenId)
        public
        view
        override
        returns (Order memory _order)
    {
        ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
        IBorrowerMaster borrower = IBorrowerMaster(marketAddress);
        IMERC721 erc721 = IMERC721(borrower.collateral());
        (
            address tAdr,
            uint96 borrowedAmount,
            uint40 borrowRatePerSecond,
            uint16 penaltyFactor,
            uint40 startTime,
            uint40 expireTime
        ) = borrower.idOfOrderState(tokenId);
        _order = _makeDefaultOrder();
        _order.marketAddress = marketAddress;
        _order.name = erc721.name();
        _order.imageUrl = erc721.tokenURI(tokenId);
        _order.loanValue = borrowedAmount;
        _order.startTime = startTime;
        _order.expireTime = expireTime;
        _order.tokenId = tokenId;
        _order.cnftAddress = borrower.collateral();
        _order.lnftAddress = borrower.lenderNFT();
        _order.bnftAddress = borrower.borrowerNFT();
        _order.floorPrice = IPriceOracle(lender.oracle()).getFloorPriceByMarket(marketAddress);
        _order.lender = IERC721(borrower.lenderNFT()).ownerOf(tokenId);
        _order.borrower = IERC721(borrower.borrowerNFT()).ownerOf(tokenId);
        _order.assetAddress = tAdr;
        _order.borrowRatePerSecond = borrowRatePerSecond;
        _order.penaltyFactor = penaltyFactor;
        _order.changeSeconds = borrower.getChargeSeconds(startTime,block.timestamp,expireTime,penaltyFactor/1e4);
        _order.generatedInterest = _order.changeSeconds *(_order.borrowRatePerSecond);
        _order.repayment = borrowedAmount + _order.generatedInterest; 
        return _order;
    }
    //用户在某个市场的借贷订单
    function userOdersInMarket(address user, address marketAddress, bool isLender) public view override returns(Order[] memory _orders){
         IBorrowerMaster borrower = IBorrowerMaster(marketAddress);
            IMERC721 erc721 = isLender
                ? IMERC721(borrower.lenderNFT())
                : IMERC721(borrower.borrowerNFT());
            _orders = new Order[](erc721.balanceOf(user));
            for (uint256 j = 0; j < _orders.length; j++) {
                uint256 tokenId = erc721.tokenOfOwnerByIndex(user, j);
                Order memory _order = orderDetail(marketAddress, tokenId);
                _orders[j] = _order;
            }
        return _orders;
    }
    //用户借贷订单
    function userOrders(address user,bool isLender) public view override  returns(Order[][] memory _orders) {
        ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
        address[] memory marketsAddress = lender.getAllMarkets();
        _orders = new Order[][](marketsAddress.length);
        for (uint256 i = 0; i < marketsAddress.length; i++) {
            Order[] memory _ordersInMarket = userOdersInMarket(user, marketsAddress[i], isLender);
            _orders[i] = _ordersInMarket;
        }
        return _orders;
    }
    //用户在某个市场的LP
    function userLiquidityInMarket(address user, address marketAddress) public view returns(Liquidity memory _lp) {
            ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
            Market memory _market = marketDetail(marketAddress);
            _lp = _makeDefaultLiquidity();
            _lp.name = IMERC721(_market.cnftAddress).name();
            _lp.marketAddress = marketAddress;
            _lp.isLender = lender.isLender(user);
            _lp.availableToLend = lender.balanceOfUnderlying(user);
            _lp.lent = lender.totalTokenBalanceNow(user) - _lp.availableToLend;
            _lp.minRequirement = _market.minRequirement;
            _lp.supportMarkets = lender.getMarketsIn(user).length;
            _lp.borrowApr = _market.borrowApr;
            _lp.minBorrowSeconds = _market.minBorrowSeconds;
            _lp.maxBorrowSeconds = _market.maxBorrowSeconds;

            uint256 j = 0;
            (
                address[] memory lenders,
                uint256[] memory times,
                uint256[] memory balances
            ) = lender.getMarketQueue(
                    marketAddress,
                    0,
                    lender.getAllMarkets().length
                );
            for (j = 0; j < lenders.length; j++) {
                if (user == lenders[j]) {
                    _lp.availableInMarket = balances[j];
                    _lp.position = j + 1;
                    _lp.updateTime = times[j];
                    break;
                }
            }
            _lp.lentInMarket = userLentInMarket(
                _lp.marketAddress,
                _market.lnftAddress,
                user
            );
        return _lp;
    }
    // 用户所有的LP
    function userLiquidity(address user)
        external
        view
        override
        returns (Liquidity[] memory _lps)
    {
        ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
        address[] memory marketsAddress = lender.getMarketsIn(user);
        _lps = new Liquidity[](marketsAddress.length);
        for (uint256 i = 0; i < marketsAddress.length; i++) {
            Liquidity memory _lp = userLiquidityInMarket(user, marketsAddress[i]);
            _lps[i] = _lp;
        }
    }
    //用户在某个市场已经借出去的资产
    function userLentInMarket(
        address marketAddress,
        address lnftAddress,
        address user
    ) public view override returns (uint256 _lentInMarket) {
        IMERC721 _erc721 = IMERC721(lnftAddress);
        for (uint256 j = 0; j < _erc721.balanceOf(user); j++) {
            Order memory _order = orderDetail(
                marketAddress,
                _erc721.tokenOfOwnerByIndex(user, j)
            );
            _lentInMarket = _lentInMarket + _order.loanValue;
        }
        return _lentInMarket;
    }
    //获取用户NFT的所有tokenId
    function userNftTokenIds(address user,address nftAddres,bool canEnum) public view returns(uint256[] memory _tokenIds){
        IMERC721 _erc721 = IMERC721(nftAddres);
        uint256 balance = _erc721.balanceOf(user);
        _tokenIds = new uint256[](balance);
        if (canEnum) {
            for (uint256 i = 0; i < balance; i++) {
                _tokenIds[i] = _erc721.tokenOfOwnerByIndex(user, i);
            }
        } else {
            for (uint256 i = 0; i < _erc721.totalSupply(); i++) {
                if(user == _erc721.ownerOf(i)){
                    _tokenIds[i] = i;
                }
            }
        }
        return _tokenIds;
    }

    function userAsset(string memory name,uint256 tokenId, string memory uri,uint256 assetType,Market memory market) public pure returns(UserAsset memory _asset ) {
        
        _asset = _makeUserAsset();
        _asset.nftAddress = market.cnftAddress;
        _asset.name = name;
        _asset.tokenId =  tokenId;
        _asset.imageUrl = uri;
        _asset.marketAddress = market.marketAddress;
        _asset.availableToBorrow = market.floorPrice * 1e18 / market.collateralFactor;
        _asset.borrowApr = market.borrowApr;
        _asset.floorPrice = market.floorPrice;
        _asset.borrowRatePerSecond = market.borrowRatePerSecond;
        _asset.penaltyFactor = market.penaltyFactor;
        _asset.minBorrowSeconds = market.minBorrowSeconds;
        _asset.maxBorrowSeconds = market.maxBorrowSeconds;
        _asset.assetType = assetType;
            return _asset;
    }

    //用户在某个市场的资产
    function userAssetInMarket(address user,address marketAddress)
        public
        view override
        returns (UserAsset[] memory _assets)
    {
        Market memory _market = marketDetail(marketAddress);
        uint256 _nftBalance = 0;
        IMERC721 _cnft = IMERC721(_market.cnftAddress);
        IMERC721 _lnft = IMERC721(_market.lnftAddress);
        IMERC721 _bnft = IMERC721(_market.bnftAddress);
        _nftBalance = _cnft.balanceOf(user) + _lnft.balanceOf(user) +_bnft.balanceOf(user);
        _assets = new UserAsset[](_nftBalance);
        uint256 i = 0;
        for (i; i < _cnft.balanceOf(user); i++) {
            uint256 tokenId = _cnft.tokenOfOwnerByIndex(user, i);
            UserAsset memory _asset = userAsset(_cnft.name(),tokenId , _cnft.tokenURI(tokenId), 1,_market);
            _assets[i] = _asset;
        }
        for (i; (i-_cnft.balanceOf(user)) < _lnft.balanceOf(user); i++) {

            uint256 tokenId = _lnft.tokenOfOwnerByIndex(user, i-_cnft.balanceOf(user));
            UserAsset memory _asset = userAsset(_lnft.name(),tokenId , _lnft.tokenURI(tokenId), 2,_market);
            _assets[i] = _asset;
        }
        for (i; (i-_cnft.balanceOf(user) - _lnft.balanceOf(user)) < _bnft.balanceOf(user); i++) {

            uint256 tokenId = _bnft.tokenOfOwnerByIndex(user, (i-_cnft.balanceOf(user) - _lnft.balanceOf(user)));
            UserAsset memory _asset = userAsset(_bnft.name(),tokenId , _bnft.tokenURI(tokenId), 2,_market);
            _assets[i] = _asset;
        }
        return _assets;
    }

    //用户在所有市场的资产
    function userAllAsset(address user)
        public
        view override
        returns (UserAsset[][] memory _allAssets)
    {
        ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
        address[] memory _allMarkets = lender.getAllMarkets();
        _allAssets = new UserAsset[][](_allMarkets.length);
        for (uint256 i = 0; i < _allMarkets.length; i++) {
            UserAsset[] memory _assets = userAssetInMarket(user,_allMarkets[i]);
            _allAssets[i] = _assets;
        }

        return _allAssets;
    }
    /*
     function userAssets(address user)
        public
        view 
        returns (UserAsset[] memory _allAsset)
    {
        ILenderMasterEther lender = ILenderMasterEther(lenderMasterAddress);
        address[] memory _allMarkets = lender.getAllMarkets();
        UserAsset[][] memory _allAssets = new UserAsset[][](_allMarkets.length);
        uint256 len = 0;
        for (uint256 i = 0; i < _allMarkets.length; i++) {
            UserAsset[] memory _assets = userAssetInMarket(user,_allMarkets[i]);
            _allAssets[i] = _assets;
            len = len + _assets.length;
        }
        _allAsset = new UserAsset[](len);
        uint256 k = 0;
        for (uint256 index = 0; index <_allMarkets.length; index++) {
            UserAsset[] memory _assets = _allAssets[index];
            for (uint256 j = 0; j < _assets.length; j++) {
                _allAsset[k] = _assets[j];
                k++; 
            }
        }

        return _allAsset;
    }
    */

    // internal
    function _makeDefaultMarket() internal pure returns (Market memory) {
        // uint256[] memory _defaultNum = new uint256[](2);
        // _defaultNum[0] = 0;
        // _defaultNum[1] = 0;
        return
            Market(
                "unkonwn",
                address(0),
                address(0),
                address(0),
                address(0),
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0
            );
    }

    function _makeDefaultSupplyOrder()
        internal
        pure
        returns (MarketSupplyOrder memory)
    {
        return
            MarketSupplyOrder(
                "",
                address(0),
                address(0),
                address(0),
                address(0),
                0,
                address(0),
                0,
                0
            );
    }

    function _makeDefaultOrder() internal pure returns (Order memory) {
        return
            Order(
                "unkonwn",
                "",
                address(0),
                0,
                address(0),
                0,
                address(0),
                address(0),
                address(0),
                address(0),
                address(0),
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0
            );
    }

    function _makeDefaultLiquidity() internal pure returns (Liquidity memory) {
        return Liquidity("unknow", address(0), 0, 0, 0, 0, 0, 0, 0,0,0,0,0,false);
    }

    function _makeUserAsset() internal pure returns (UserAsset memory) {
        // uint256[] memory _defaultNum = new uint256[](2);
        // _defaultNum[0] = 0;
        // _defaultNum[1] = 0;
        return
            UserAsset(
                "",
                address(0),
                0,
                "",
                0,
                address(0),
                0,
                0,
                0,
                0,
                0,
                0,
                0
            );
    }
    //admin

}
