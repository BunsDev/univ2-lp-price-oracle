// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import { AggregatorV3Interface } from "./AggregatorV3Interface.sol";
import { IDexPair } from "./IDexPair.sol";

/**
 *  @title IUniswapV3NebulaOracle Interface to interact with Cygnus' Chainlink oracle (UniV3)
 */
interface IUniswapV3NebulaOracle {
    /*  ═══════════════════════════════════════════════════════════════════════════════════════════════════════ 
            1. CUSTOM ERRORS
        ═══════════════════════════════════════════════════════════════════════════════════════════════════════  */

    /**
     *  @custom:error PairIsInitialized Reverts when attempting to initialize an already initialized LP Token
     */
    error ChainlinkNebulaOracle__PairAlreadyInitialized(address lpTokenPair);

    /**
     *  @custom:error PairNotInitialized Reverts when attempting to get the price of an LP Token that is not initialized
     */
    error ChainlinkNebulaOracle__PairNotInitialized(address lpTokenPair);

    /**
     *  @custom:error MsgSenderNotAdmin Reverts when attempting to access admin only methods
     */
    error ChainlinkNebulaOracle__MsgSenderNotAdmin(address msgSender);

    /**
     *  @custom:error AdminCantBeZero Reverts when attempting to set the admin if the pending admin is the zero address
     */
    error ChainlinkNebulaOracle__AdminCantBeZero(address pendingAdmin);

    /**
     *  @custom:error PendingAdminAlreadySet Reverts when attempting to set the same pending admin twice
     */
    error ChainlinkNebulaOracle__PendingAdminAlreadySet(address pendingAdmin);

    /*  ═══════════════════════════════════════════════════════════════════════════════════════════════════════ 
            2. CUSTOM EVENTS
        ═══════════════════════════════════════════════════════════════════════════════════════════════════════  */

    /**
     *  @param initialized Whether or not the LP Token is initialized
     *  @param oracleId The ID for this oracle
     *  @param lpTokenPair The address of the LP Token
     *  @param priceFeedA The address of the Chainlink's aggregator contract for this LP Token's token0
     *  @param priceFeedB The address of the Chainlink's aggregator contract for this LP Token's token1
     *  @custom:event InitializeChainlinkNebula Logs when an LP Token pair's price starts being tracked
     */
    event InitializeChainlinkNebula(
        bool initialized,
        uint24 oracleId,
        address lpTokenPair,
        uint32 token0Decimals,
        uint32 token1Decimals,
        AggregatorV3Interface priceFeedA,
        AggregatorV3Interface priceFeedB
    );

    /**
     *  @param oracleId The ID for this oracle
     *  @param lpTokenPair The contract address of the LP Token
     *  @param priceFeedA The contract address of Chainlink's aggregator contract for this LP Token's token0
     *  @param priceFeedB The contract address of the Chainlink's aggregator contract for this LP Token's token1
     *  @custom:event DeleteChainlinkNebula Logs when an LP Token pair is removed from this oracle
     */
    event DeleteChainlinkNebula(
        uint24 oracleId,
        address lpTokenPair,
        AggregatorV3Interface priceFeedA,
        AggregatorV3Interface priceFeedB,
        address msgSender
    );

    /**
     *  @param oracleCurrentAdmin The address of the current oracle admin
     *  @param oraclePendingAdmin The address of the pending oracle admin
     *  @custom:event NewNebulaPendingAdmin Logs when a new pending admin is set, to be accepted by admin
     */
    event NewOraclePendingAdmin(address oracleCurrentAdmin, address oraclePendingAdmin);

    /**
     *  @param oracleOldAdmin The address of the old oracle admin
     *  @param oracleNewAdmin The address of the new oracle admin
     *  @custom:event NewNebulaAdmin Logs when the pending admin is confirmed as the new oracle admin
     */
    event NewOracleAdmin(address oracleOldAdmin, address oracleNewAdmin);

    /*  ═══════════════════════════════════════════════════════════════════════════════════════════════════════ 
            3. CONSTANT FUNCTIONS
        ═══════════════════════════════════════════════════════════════════════════════════════════════════════  */

    /*  ─────────────────────────────────────────────── Public ────────────────────────────────────────────────  */

    /**
     *  @notice Returns the struct record of each oracle used by Cygnus
     *  @param lpTokenPair The address of the LP Token
     *  @return initialized Whether an LP Token is being tracked or not
     *  @return oracleId The ID of the LP Token tracked by the oracle
     *  @return underlying The address of the LP Token
     *  @return token0Decimals Decimals for token0 from the LP
     *  @return token1Decimals Decimals for token1 from the LP
     *  @return priceFeedA The address of the Chainlink aggregator used for this LP Token's Token0
     *  @return priceFeedB The address of the Chainlink aggregator used for this LP Token's Token1
     */
    function getNebula(
        address lpTokenPair
    )
        external
        view
        returns (
            bool initialized,
            uint24 oracleId,
            address underlying,
            uint32 token0Decimals,
            uint32 token1Decimals,
            AggregatorV3Interface priceFeedA,
            AggregatorV3Interface priceFeedB
        );

    /**
     *  @notice Gets the address of the LP Token that (if) is being tracked by this oracle
     *  @param id The ID of each LP Token that is being tracked by this oracle
     *  @return The address of the LP Token if it is being tracked by this oracle, else returns address zero
     */
    function allNebulas(uint256 id) external view returns (address);

    /**
     *  @return The name for this Cygnus-Chainlink Nebula oracle
     */
    function name() external view returns (string memory);

    /**
     *  @return The decimals for this Cygnus-Chainlink Nebula oracle
     */
    function decimals() external view returns (uint8);

    /**
     *  @return The symbol for this Cygnus-Chainlink Nebula oracle
     */
    function symbol() external view returns (string memory);

    /**
     *  @return The address of Chainlink's USDC oracle
     */
    function usdc() external view returns (AggregatorV3Interface);

    /**
     *  @return The address of the Cygnus admin
     */
    function admin() external view returns (address);

    /**
     *  @return The address of the new requested admin
     */
    function pendingAdmin() external view returns (address);

    /**
     *  @return The version of this oracle
     */
    function version() external view returns (uint8);

    /**
     *  @return How many LP Token pairs' prices are being tracked by this oracle
     */
    function nebulaSize() external view returns (uint24);

    /*  ────────────────────────────────────────────── External ───────────────────────────────────────────────  */

    /**
     *  @return The price of USDC with 18 decimals
     */
    function usdcPrice() external view returns (uint256);

    /**
     *  @notice Gets the latest price of the LP Token denominated in USDC
     *  @notice LP Token pair must be initialized, else reverts with custom error
     *  @param lpTokenPair The address of the LP Token
     *  @return lpTokenPrice The price of the LP Token denominated in USDC
     */
    function lpTokenPriceUsdc(address lpTokenPair) external view returns (uint256 lpTokenPrice);

    /**
     *  @notice Gets the latest price of the LP Token's token0 and token1 denominated in USDC
     *  @notice Used by Cygnus Altair contract to calculate optimal amount of leverage
     *  @param lpTokenPair The address of the LP Token
     *  @return tokenPriceA The price of the LP Token's token0 denominated in USDC
     *  @return tokenPriceB The price of the LP Token's token1 denominated in USDC
     */
    function assetPricesUsdc(address lpTokenPair) external view returns (uint256 tokenPriceA, uint256 tokenPriceB);

    /*  ═══════════════════════════════════════════════════════════════════════════════════════════════════════ 
            4. NON-CONSTANT FUNCTIONS
        ═══════════════════════════════════════════════════════════════════════════════════════════════════════  */

    /*  ────────────────────────────────────────────── External ───────────────────────────────────────────────  */

    /**
     *  @notice Initialize an LP Token pair, only admin
     *  @param lpTokenPair The contract address of the LP Token
     *  @param priceFeedA The contract address of the Chainlink's aggregator contract for this LP Token's token0
     *  @param priceFeedB The contract address of the Chainlink's aggregator contract for this LP Token's token1
     *  @custom:security non-reentrant
     */
    function initializeNebula(
        address lpTokenPair,
        AggregatorV3Interface priceFeedA,
        AggregatorV3Interface priceFeedB
    ) external;

    /**
     *  @notice Deletes an LP token pair from the oracle
     *  @notice After deleting, any call from a shuttle deployed that is using this pair will revert
     *  @param lpTokenPair The contract address of the LP Token to remove from the oracle
     *  @custom:security non-reentrant
     */
    function deleteNebula(address lpTokenPair) external;

    /**
     *  @notice Sets a new pending admin for the Oracle
     *  @param newOraclePendingAdmin Address of the requested Oracle Admin
     */
    function setOraclePendingAdmin(address newOraclePendingAdmin) external;

    /**
     *  @notice Sets a new admin for the Oracle
     */
    function setOracleAdmin() external;
}
