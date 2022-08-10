// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

/// @dev Interface for InterestRateModel
interface IInterestRateModel {

    /// @dev Emitted when the `baseRatePerSecond`, `multiplierPerSecond` and `penaltyFactor` params updated.
    event NewInterestParams(uint64 baseRatePerSecond, uint64 multiplierPerSecond, uint16 newPenaltyFactor);


    /*** View Functions ***/

    /**
     * @return The seconds per year
     */
    function secondsPerYear() external view returns (uint40);

     /**
     * @return The maximum apr used to limit params, scaled by 1e18, 10e18 means 1000% apr
     */
    function maxBorrowRatePerSecond() external view returns (uint40);

    /**
     * @return The multiplier of utilization rate that gives the slope of the interest rate, scaled by 1e18
     */
    function multiplierPerSecond() external view returns (uint64);

    /**
     * @return The base interest rate which is the y-intercept when utilization rate is 0, scaled by 1e18
     */
    function baseRatePerSecond() external view returns (uint64);

    /**
     * @return The penalty factor used to calculate extra interest for early repayment, scaled by 10000, must <= 10000
     */
    function penaltyFactor() external view returns (uint16);

    /**
     * @notice Calculates the utilization rate of the market: `borrows / (cash + borrows)`
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @return The utilization rate scaled by 1e18 between [0, 1e18]
     */
    function utilizationRate(uint256 cash, uint256 borrows) external pure returns (uint256);

    /**
     * @notice Calculates the current borrow rate per second.
     * @dev Capped by maxBorrowRatePerSecond.
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @return The borrow rate percentage per second, scaled by 1e18
     */
    function getBorrowRatePerSecond(uint256 cash, uint256 borrows) external view returns (uint40);

    /**
     * @notice Calculates the charge seconds based on current time, used to calculate total interest.
     * @dev Total interest = borrowRatePerSecond * chargeSeconds * borrowedAmount.
     * @param startTime The start time of this order
     * @param repayTime The repay time for this order
     * @param expireTime The latest time to repay borrow
     * @param penaltyFactor_ The penalty factor of this order
     * @return The charge seconds
     */
    function getChargeSeconds(
        uint256 startTime, 
        uint256 repayTime, 
        uint256 expireTime, 
        uint256 penaltyFactor_
    ) external pure returns (uint256);
}
