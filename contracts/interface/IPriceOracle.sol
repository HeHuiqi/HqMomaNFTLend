// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

/// @dev Interface for PriceOracle
interface IPriceOracle {
    /**
     * @notice Indicator that this is a oracle contract (for inspection).
     * @return Always be `true`
     */
    function isMomaOracle() external view returns (bool);

    /**
     * @notice Get the floor price of an NFT collections `market`.
     * @dev This function should never revert, unavailable price should return 0.
     * @param market The market contract address to get its related NFT floor price of
     * @return The floor price denominated in ETH, scaled by 1e18
     */
    function getFloorPriceByMarket(address market) external view returns (uint256);

    /**
     * @notice Get the floor price of some NFT collections `markets`.
     * @dev This function should never revert, unavailable price should return 0.
     * @param markets The list of market contract addresses to get their related NFT floor price of
     * @return The list of floor price denominated in ETH, scaled by 1e18
     */
    function getFloorPriceByMarkets(address[] calldata markets) external view returns (uint256[] memory);
}
