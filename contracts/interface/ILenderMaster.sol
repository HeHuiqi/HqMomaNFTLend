// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

/// @dev Interface for LenderMaster
interface ILenderMaster {

    /// @dev Emitted when a `lender` allows some NFT `markets` to borrow their token.
    event MarketsEntered(address lender, address[] markets);

    /// @dev Emitted when a `lender` disallows some NFT `markets` to borrow their token.
    event MarketsExited(address lender, address[] markets);

    /// @dev Emitted when `lender` doposit `tokenAmount` token and receive `mTokenAmount` mToken.
    event Deposit(address indexed lender, uint256 tokenAmount, uint256 mTokenAmount);

    /// @dev Emitted when `lender` withdraw `mTokenAmount` to `tokenAmount` and receive `actualAmount` token actually.
    event Withdraw(address indexed lender, uint256 mTokenAmount, uint256 tokenAmount, uint256 actualAmount);

    /// @dev Emitted when an new NFT collections `newMarket` is listed.
    event NewMarket(address indexed newMarket, address lenderNFT, uint128 newCollateralFactor);

    /// @dev Emitted when a market's collateral factor is changed by admin.
    event NewCollateralFactor(address indexed market, uint128 oldCollateralFactor, uint128 newCollateralFactor);

    /// @dev Emitted when price oracle is changed by admin.
    event NewPriceOracle(address oldPriceOracle, address newPriceOracle);

    struct MarketState {
        /// @notice The contract address of lNFT, used to get lender orders
        address lenderNFT;

        /// @notice The market total unborrowed <mToken> amount, used to calculate utilization rate
        uint128 totalMCash;

        /**
         * @notice Multiplier representing the most one can borrow against their collateral in this market.
         *  For instance, 0.9 to allow borrowing 90% of collateral value.
         *  Must be between 0 and 1, scaled by 1e18.
         */
        uint128 collateralFactor;
    }

    // Early withdraw fee params
    struct WithdrawFeeStage {
        /// @notice Large than this seconds have no fee
        uint32 feeStageSeconds0;

        /// @notice Large than this seconds have feeStage1 fee
        uint32 feeStageSeconds1;

        /// @notice Large than this seconds have feeStage2 fee, else have feeStage3 fee
        uint32 feeStageSeconds2;

        /// @notice Scale by 100
        uint32 feeStage1;
        uint32 feeStage2;
        uint32 feeStage3;
    }


    /*** View Functions ***/

    /**
     * @notice Get the contract address of underlying token to deposit, address(0) means ETH.
     * @return The underlying token address
     */
    function underlying() external view returns (address);

    /**
     * @notice Get the oracle which gives the price of any given NFT collection market.
     * @return oracle contract address
     */
    function oracle() external view returns (address);

    /**
     * @notice Get the `market`'s state info.
     * @param market The address of the market to query
     * @return lenderNFT The contract address of lenderNFT, used to get lender orders
     * @return totalMCash The market total unborrowed <mToken> amount, used to calculate utilization rate
     * @return collateralFactor Collateral factor of this market
     */
    function marketStates(address market) external view returns (address, uint128, uint128);

    /**
     * @notice Get the `withdrawFeeStage`'s info.
     * @return See struct WithdrawFeeStage
     */
    function withdrawFeeStage() external view returns (WithdrawFeeStage memory);

    /**
     * @notice Get the `lender` in this `market`'s last mToken balance updated time.
     * @param lender The address of the lender to query
     * @param market The address of the market to query
     * @return The last balance updated time
     */
    function lenderMarketUpdatedTime(address lender, address market) external view returns (uint256);

    /**
     * @notice Get the `lender`'s total borrowed token amounts.
     * @param lender The address of the lender to query
     * @return The total borrowed token amounts
     */
    function lenderBorrowedTokenAmounts(address lender) external view returns (uint256);

    /**
     * @notice Indicator that this is a LenderMaster contract (for inspection).
     * @return Always be `true`
     */
    function isLenderMaster() external view returns (bool);
    
    /**
     * @return `GUARDIAN_ROLE`'s byte hash
     */
    function GUARDIAN_ROLE() external view returns (bytes32);

    /**
     * @return `DEPOSIT_PAUSED`'s byte hash
     */
    function DEPOSIT_PAUSED() external view returns (bytes32);

    /**
     * @return `MARKET_BORROW_PAUSED`'s byte hash
     */
    function MARKET_BORROW_PAUSED() external view returns (bytes32);


    /**
     * @notice Calculate the actual withdraw amount based on balance update time of `account`.
     * @dev If lender withdraw in short time after deposit, may receive less amounts.
     * @param account The account to withdraw
     * @param amount The token amount to withdraw
     * @return The actual token amount will receive if withdraw now
     */
    function getWithdrawAmount(address account, uint256 amount) external view returns (uint256);

    /**
     * @notice Returns whether the given `market` was listed.
     * @param market The `market` to check
     * @return True if the market was listed, otherwise false
     */
    function isMarketListed(address market) external view returns (bool);

    /**
     * @notice Returns a market address by `index`.
     * @param index The index of the _allMarkets set
     * @return The market address of this `index`
     */
    function getMarketByIndex(uint256 index) external view returns (address);

    /**
     * @notice Returns all of the markets.
     * @return The list of all market addresses
     */
    function getAllMarkets() external view returns (address[] memory);

    /**
     * @notice Get the total cash for the `market` denominated in underlying token.
     * @param market The market to query
     * @return cash The amount of cash in the market
     */
    function getMarketTotalCash(address market) external view returns (uint256 cash);

    /**
     * @notice Returns the balance updated time of target lenders in this `market`.
     * @dev WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     * @param market The address of the `market` to pull for
     * @param startIndex The start index of _allLenders to iterate
     * @param num The number of lender to iterate
     * @param market The address of the `market` to pull for
     * @return lenders A dynamic list of all lenders of this market
     * @return times A dynamic list of the balance updated time of all lenders
     * @return balances A dynamic list of the token balance of all lenders
     */
    function getMarketQueue(
        address market, 
        uint256 startIndex, 
        uint256 num
    ) external view returns (address[] memory lenders, uint256[] memory times, uint256[] memory balances);

    /**
     * @notice Returns whether the given address is lender.
     * @param lender The `lender` to check
     * @return True if it is lender, otherwise false
     */
    function isLender(address lender) external view returns (bool);

    /**
     * @notice Returns the number of all lenders.
     * @return The number of lenders
     */
    function getLendersNum() external view returns (uint256);

    /**
     * @notice Returns a lender address by `index`.
     * @param index The index of the _allLenders set
     * @return The lender address of this `index`
     */
    function getLenderByIndex(uint256 index) external view returns (address);

    /**
     * @notice Returns all of the lenders.
     * @return The list of all lender addresses
     */
    function getAllLenders() external view returns (address[] memory);

    /**
     * @notice Returns whether the given `lender` is entered in the given `market`.
     * @param lender The address of the `lender` to check
     * @param market The `market` to check
     * @return True if the lender is in the market, otherwise false
     */
    function isMarketMembership(address lender, address market) external view returns (bool);

    /**
     * @notice Returns the number of markets `lender` entered
     * @param lender The address of the lender to get
     * @return The length of _lenderMarkets for lender
     */
    function getLenderMarketsNum(address lender) external view returns (uint256);

    /**
     * @notice Returns a market address of a `lender` by `index`.
     * @param lender The address of the `lender` to get
     * @param index The index of the lender markets set
     * @return The market address of this `index` for this `lender`
     */
    function getLenderMarketByIndex(address lender, uint256 index) external view returns (address);

    /**
     * @notice Returns all the markets a `lender` has entered.
     * @param lender The address of the `lender` to pull markets for
     * @return A dynamic list with the markets the lender has entered
     */
    function getMarketsIn(address lender) external view returns (address[] memory);

    /**
     * @notice Get the price of mToken denominated in underlying token.
     * @return rate The exchange rate of token / mToken, scaled by 1e18
     */
    function exchangeRate() external view returns (uint256 rate);

    /**
     * @notice Get the underlying balance of the `lender`.
     * @param lender The address of the account to query
     * @return tokenAmount The amount of underlying owned by `lender`
     */
    function balanceOfUnderlying(address lender) external view returns (uint256 tokenAmount);

    /**
     * @notice Calculate the loan value of the NFT collections `market`.
     * @param market The market contract addresses to find
     * @return loanValue The loan value denominated in underlying token decimals
     */
    function getMarketLoanValue(address market) external view returns (uint256 loanValue);

    /**
     * @notice Find the max loan value from some NFT collections `markets`.
     * @param markets The list of market contract addresses to find
     * @return maxLoanValue The max loan value denominated in underlying token decimals
     */
    function getMaxLoanValue(address[] memory markets) external view returns (uint256 maxLoanValue);

    /**
     * @notice Get the total token balance of `lender` both borrowed and unborrowed.
     * @param lender The address of the account to query
     * @return The total amount of underlying owned by `lender`
     */
    function totalTokenBalanceNow(address lender) external view returns (uint256);


    /*** Lender Functions ***/

    /**
     * @notice Enter to allow some NFT `markets` to borrow their token.
     * @param markets The list of addresses of the NFT markets to enter
     */
    function enterMarkets(address[] calldata markets) external;

    /**
     * @notice Exit to disallow some NFT `markets` to borrow their token.
     * @param markets The list of addresses of the NFT markets to exit
     */
    function exitMarkets(address[] calldata markets) external;


    /*** Market Functions ***/

    /**
     * @notice Market borrow `lender`'s token on behalf of `borrower`.
     * @param borrower The address to borrow
     * @param lender The address who's token to be borrowed
     * @return borrowAmount The actual borrowed amount
     * @return totalCash The cash of this market denominated in underlying token
     */
    function onMarketBorrow(address borrower, address lender) external returns (uint256 borrowAmount, uint256 totalCash);

    /**
     * @notice Market repay `lender`'s borrowed token on behalf of `borrower`.
     * @param lender The address who's token being repaid
     * @param borrowAmount The token borrowed amount
     * @param lenderAmount Sum of lender interest and borrowAmount to lender
     * @param poolAmount Sum of pool interest and lenderAmount to pool
     */
    function onMarketRepayBorrow(address lender, uint256 borrowAmount, uint256 lenderAmount, uint256 poolAmount) external payable;

    /**
     * @notice Market liquidate `borrower`'s collateral on behalf of `lender`.
     * @param lender The address who's token being borrowed
     * @param borrowAmount The token borrowed amount
     */
    function onMarketLiquidateBorrow(address lender, uint256 borrowAmount) external;


    /*** NFT Functions ***/

    /**
     * @notice When `lenderNFT` do transfer, we must update `from` and `to`'s total borrowed `token` amounts.
     * @param from The address who transfer
     * @param to The recipient address
     * @param market Which market the lenderNFT belongs to
     * @param borrowAmount The token borrowed amount
     */
    function onNFTransfer(address from, address to, address market, uint256 borrowAmount) external;


    /*** Admin Functions ***/

    /**
     * @notice Admin function to add support for the `market`.
     * @param market The address of the market to list
     * @param collateralFactor The collateralFactor for the market
     */
    function adminSupportMarket(address market, uint128 collateralFactor) external;

    /**
     * @notice Admin function to set a `newCollateralFactor` for `market`.
     * @param market The address of the market to set new collateral factor
     * @param newCollateralFactor The new collateral factor
     */
    function adminSetCollateralFactor(address market, uint128 newCollateralFactor) external;

    /**
     * @notice Admin function to set a new price oracle.
     * @param newOracle The new oracle to set
     */
    function adminSetPriceOracle(address newOracle) external;

    /**
     * @notice Admin function to set a new withdraw fee stage.
     * @dev Modify the `withdrawFeeStage`.
     * @param newWithdrawFeeStage The new withdrawFeeStage to set
     */
    function adminSetWithdrawFeeStage(WithdrawFeeStage calldata newWithdrawFeeStage) external;

    /**
     * @notice Admin function to set `markets` borrow paused state.
     * @dev Modify the `_roles[MARKET_BORROW_PAUSED].members[market]`.
     * @param markets The address list of market to set
     * @param pause Pause or unpause
     */
    function adminSetMarketsBorrowPaused(address[] calldata markets, bool pause) external;
}
