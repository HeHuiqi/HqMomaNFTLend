// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/// @dev Interface for IMERC721
interface IMERC721 is IERC721, IERC721Enumerable, IERC721Metadata {
    /**
     * @dev Returns the contract address of the underlying NFT.
     */
    function underlying() external view returns (address);

    /**
     * @dev Returns the contract address of BorrowerMarket.
     */
    function market() external view returns (address);
}


interface IMERC721Borrower is IMERC721 {

    /*** Market Functions ***/

    /**
     * @notice Mints `tokenId` and transfers it to `to`.
     * @dev The caller must be `market` and `tokenId` must not exist.
     * @param to The recipient address  
     * @param tokenId The tokenId to mint
     */
    function mint(address to, uint256 tokenId) external;

    /**
     * @notice Burns `tokenId` from `owner`.
     * @dev The caller must be `market` and `tokenId` must exist.
     * @param tokenId The tokenId to burn
     * @param owner The owner address before
     */
    function burn(uint256 tokenId) external returns (address owner);
}


interface IMERC721Lender is IMERC721 {

    /*** Market Functions ***/

    /**
     * @notice Mints `tokenId` and transfers it to `to`.
     * @dev The caller must be `market` and `tokenId` must not exist.
     * @param to The recipient address
     * @param tokenId The tokenId to mint
     * @param lenderMaster The address of LenderMaster when borrow
     * @param borrowAmount The token borrowed amount
     */
    function mint(address to, uint256 tokenId, address lenderMaster, uint256 borrowAmount) external;

    /**
     * @notice Burns `tokenId` from `owner`.
     * @dev The caller must be `market` and `tokenId` must exist.
     * @param tokenId The tokenId to burn
     * @param owner The owner address before
     */
    function burn(uint256 tokenId) external returns (address owner);
}
