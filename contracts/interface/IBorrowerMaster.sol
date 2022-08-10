// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

import "./IInterestRateModel.sol";

/// @dev Interface for BorrowerMaster
interface IBorrowerMaster is IInterestRateModel {

    /// @dev Emitted when `borrower` mortgage `tokenId` as collateral and borrow `lender`'s `borrowAmount` `token`.
    event Borrow(address borrower, uint256 tokenId, address lender, address token, uint256 borrowAmount);

    /// @dev Emitted when `borrower` repay `repayAmount` `token` to `lender` and receive its `tokenId` collateral.
    event RepayBorrow(address borrower, uint256 tokenId, address lender, address token, uint256 repayAmount);

    /// @dev Emitted when `lender` liquidate `borrower`'s order to get his `tokenId` with cost `borrowedAmount` `token`.
    event LiquidateBorrow(address borrower, uint256 tokenId, address lender, address token, uint256 borrowedAmount);

    /// @dev Emitted when distribute interest to `referral`, 'moma', 'pool' and 'lender'.
    event DistributeInterest(
        address referral, 
        uint256 referralInterest, 
        uint256 momaInterest, 
        uint256 poolInterest, 
        uint256 lenderInterest
    );

     /// @dev Emitted when `user` claimed `amount` `token` interest.
    event InterestClaimed(address token, address user, uint256 amount);

    /// @dev Emitted when an new `order` is created.
    event NewOrder(OrderState order);

    /// @dev Emitted when an new `token` is supported with `lenderMaster`.
    event NewToken(address token, address lenderMaster);

    /// @dev Emitted when an new `interestConfig` is set.
    event NewInterestConfig(InterestConfig oldConfig, InterestConfig newConfig);

    // Interest distribute config
    struct InterestConfig {
        /// @notice Moma address to receive interest fee
        address momaDev;

        /// @notice Interest fee percent to referral, scaled by TOTAL_PERCENT
        uint32 referralPercent;

        /// @notice Interest fee percent to pool, scaled by TOTAL_PERCENT
        uint32 poolPercent;

        /// @notice Interest fee percent to moma, scaled by TOTAL_PERCENT
        uint32 momaPercent;
    }

    /// @dev The OrderState only use 2 slot in storage
    struct OrderState {
        /// @notice The borrowed token
        address token;

        /// @notice The borrowed amount, uint96 support max amount to 79,228,162,514e18
        uint96 borrowedAmount;

        /// @notice The borrow rate per second at the time of borrowing, used to calculate final interest
        uint40 borrowRatePerSecond;
        
        /// @notice The penalty factor used to calculate extra interest for early repayment, scaled by 10000
        uint16 penaltyFactor;

        /// @notice The start time of this order, uint40 support max timestamp 1099511627775 to year 36812
        uint40 startTime;

        /// @notice The latest time to repay borrow, afterwards lender can liquidate borrower's collateral
        uint40 expireTime;
    }


    /*** View Functions ***/

    /**
     * @notice Get the contract address of the collateral NFT.
     * @return The collateral NFT contract address
     */
    function collateral() external view returns (address);

    /**
     * @notice Get the address of the wrapped borrowerNFT for borrowers.
     * @return The borrowerNFT contract address
     */
    function borrowerNFT() external view returns (address);

    /**
     * @notice Get the address of the wrapped lenderNFT for lenders
     * @return The lenderNFT contract address
     */
    function lenderNFT() external view returns (address);

    /**
     * @notice Get the signer who will sign message.
     * @return signer address
     */
    function signer() external view returns (address);

    /**
     * @notice Get the maximum loan period, afterwards lender can liquidate borrower's collateral.
     * @return The maximum borrow seconds
     */
    function maxBorrowSeconds() external view returns (uint40);

    /**
     * @notice Get the interest distribute config
     * @return momaDev Moma address to receive moma interest
     * @return referralPercent Interest fee percent to referral, scaled by 100
     * @return poolPercent Interest fee percent to pool, scaled by 100
     * @return momaPercent Interest fee percent to momaDev, scaled by 100
     */
    function interestConfig() external view returns (address, uint32, uint32, uint32);

    /**
     * @notice Get the total borrowed `token` amount.
     * @param token The address of the token to query
     * @return The total borrowed `token` of this market
     */
    function tokenTotalBorrows(address token) external view returns (uint256);

    /**
     * @notice Get the `token`'s LenderMaster contract address.
     * @param token The address of the token to query, address(0) means ETH
     * @return The LenderMaster contract address of this token
     */
    function tokenLenderMaster(address token) external view returns (address);

    /**
     * @notice Get the `user`'s total cumulative interest of the `token`.
     * @param token The address of the token to query, address(0) means ETH
     * @param user The address of the user to query
     * @return User's total cumulative interest of `token`
     */
    function tokenUserInterest(address token, address user) external view returns (uint256);

    /**
     * @notice Returns a token address by `index`.
     * @param index The index of the allTokens set
     * @return The token address of this `index`
     */
    function allTokens(uint256 index) external view returns (address);

    /**
     * @notice Returns all of the supported tokens.
     * @dev The automatic getter may be used to access an individual token.
     * @return The list of all token addresses
     */
    function getAllTokens() external view returns (address[] memory);

    /**
     * @notice Get the `tokenId`'s borrow order state.
     * @param tokenId The collateral tokenId to query
     * @return token The borrowed token address
     * @return borrowedAmount The borrowed amount
     * @return borrowRatePerSecond The borrow rate per second at the time of borrowing, used to calculate final interest
     * @return penaltyFactor The penalty factor to calculate final interest
     * @return startTime The start time of this order
     * @return expireTime The latest time to repay borrow, afterwards lender can liquidate borrower's collateral
     */
    function idOfOrderState(uint256 tokenId) external view returns (address, uint96, uint40, uint16, uint40, uint40);

    /**
     * @notice Indicator that this is a BorrowerMaster contract (for inspection).
     * @return Always be `true`
     */
    function isMomaMarket() external view returns (bool);

    /**
     * @notice Calculate the order of `collateralId`'s total repay amount include interest if repay now.
     * @param collateralId The id of the NFT as collateral
     * @return repayAmount Total token amount to repay include interest
     * @return interest Interest amount to repay
     */
    function getTotalRepayAmount(uint256 collateralId) external view returns (uint256 repayAmount, uint256 interest);


    /*** Borrower Functions ***/

    /**
     * @notice Borrow at least `minBorrowAmount` `token` from `lender` by using `collateralId` as collateral.
     * @param collateralId The id of the NFT collateral
     * @param token The token address to borrow
     * @param minBorrowAmount The minimum amount of `token` to borrow
     * @param lender The lender address to borrow his `token`
     * @param expiration The signature signature time 
     * @param signature The signature of signed message
     * @return borrowAmount The borrowed amount
     */
    function borrow(
        uint256 collateralId, 
        address token, 
        uint256 minBorrowAmount, 
        address lender, 
        uint256 expiration, 
        bytes memory signature
    ) external returns (uint256 borrowAmount);

    /**
     * @notice Repay borrowed token plus interest to get `collateralId` back.
     * @param collateralId The id of the NFT as collateral
     * @param amountIn The repay amount transfer in for non-Ether token in case of fee, extra amount will refund
     * @param referral The referral address to recive extra interest
     * @return repayAmount Repayed token amount
     */
    function repayBorrow(uint256 collateralId, uint256 amountIn, address referral) external payable returns (uint256 repayAmount);

    /**
     * @notice Liquidate `borrower`'s `collateralId` order after expire.
     * @param collateralId The id of the NFT as collateral to liquidate
     */
    function liquidateBorrow(uint256 collateralId) external;

    /**
     * @notice User claims its cumulative interest of `tokens`.
     * @param tokens The list of token to claim interest
     */
    function claimInterest(address[] calldata tokens) external;


    /*** Admin Functions ***/

    /**
     * @notice Admin function to add support for the `token`.
     * @param token The address of the token to list
     * @param lenderMaster The address of the token LenderMaster
     */
    function adminSupportToken(address token, address lenderMaster) external;

    /**
     * @notice Admin function to set interest config.
     * @param newConfig The new interest config to set
     */
    function adminSetInterestConfig(InterestConfig calldata newConfig) external;

    /**
     * @notice Admin function to set interest rate model params.
     * @param baseRatePerYear The approximate target base APR, scaled by 1e18
     * @param multiplierPerYear The rate of increase in interest rate wrt utilization, scaled by 1e18
     * @param newPenaltyFactor The penalty factor used to calculate extra interest for early repayment, scaled by 10000, must <= 10000
     */
    function adminSetInterestRateModelParams(
        uint64 baseRatePerYear, 
        uint64 multiplierPerYear, 
        uint16 newPenaltyFactor
    ) external;
}
