// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

import "./ILenderMaster.sol";

/// @dev Interface for LenderMasterEther
interface ILenderMasterEther is ILenderMaster{

    /*** Lender Functions ***/

    /**
     * @notice Doposit `msg.value` ETH and receive `mETHAmount` mETH.
     * @param markets The list of addresses of the NFT markets to enter
     * @return mETHAmount mETH amount lender received
     */
    function deposit(address[] calldata markets) external payable returns (uint256 mETHAmount);

    /**
     * @notice Withdraw `mETHAmount` mETH to get `actualAmount` ETH.
     * @param mETHAmount mETH amount to withdraw
     * @param markets The list of addresses of the NFT markets to exit
     * @return actualAmount Token amount lender received actually
     */
    function withdraw(uint256 mETHAmount, address[] calldata markets) external returns (uint256 actualAmount);
}
