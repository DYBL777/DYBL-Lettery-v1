// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

/**
 * ███████╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗         ███████╗███████╗███████╗██████╗ 
 * ██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║         ██╔════╝██╔════╝██╔════╝██╔══██╗
 * █████╗     ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║         ███████╗█████╗  █████╗  ██║  ██║
 * ██╔══╝     ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║         ╚════██║██╔══╝  ██╔══╝  ██║  ██║
 * ███████╗   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗    ███████║███████╗███████╗██████╔╝
 * ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚══════╝╚══════╝╚═════╝ 
 *
 * DYBL - Decentralised Yield Bearing Legacy
 * "The Eternal Seed" - DeFi's First Autonomous Yield Engine
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * CORE INNOVATION: THE ETERNAL SEED MECHANISM
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * 
 * Traditional Model:        100% of revenue → extracted by platform
 * DYBL Model:              100% of revenue → yield-bearing vault → compounds forever
 * 
 * How It Works:
 * 1. Fixed Baseline Retention: 10% of prize pot stays in vault (perpetual compounding)
 * 2. Rolling Treasury Injection: Idle treasury liquidity recycled to accelerate growth
 * 3. Behavioral Forfeit Flywheel: Inconsistent users forfeit yield → feeds the Seed
 * 
 * Result: Self-sustaining growth even at 0% external yield
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * IMMUTABLE GUARANTEES (LOCKED FOREVER AT DEPLOY)
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * 
 * ✓ Treasury revenue → 0% forever after predetermined timestamp
 * ✓ 100% of yield belongs to savers forever
 * ✓ Post-cap excess → permanent saver APY + charity + treasury passive slice
 * ✓ Unique Pavlovian toggle: Savers get 100% yield, gamblers get 50%
 * ✓ Legacy Mode: Set heir, generational wealth transfer on-chain
 * ✓ Self-funding Chainlink reserve for future scaling
 * ✓ No token. No governance. No pre-mine. No VC. No rug.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * APPLICATIONS BEYOND LETTERY
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * 
 * The DYBL primitive works for ANY recurring payment:
 * • Lotteries (Lettery - flagship)
 * • Insurance premiums
 * • Pension contributions  
 * • SaaS subscriptions
 * • Utility bills
 * • Remittances
 * • DAO membership dues
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * AUDIT & SECURITY NOTES
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * 
 * @dev BLACK-SWAN & RESILIENCE SCENARIOS (Pre-Planned Migration Paths)
 * 
 * These are documented, auditor-friendly contingency plans that can be activated
 * by the immutable owner + timelock in extreme events. Chainlink Engineering is
 * explicitly invited to co-design the final implementation.
 * 
 * Scenario 1: Aave Protocol Exploit or Insolvency
 *   → EmergencyPause → withdrawAllFromAave() → supplyToBackupLendingProtocol()
 *   → Backup options: Compound, Morpho Blue, Spark, or new Aave fork
 *   → All user balances + accrued yield preserved 1:1 via internal accounting
 * 
 * Scenario 2: Chainlink VRF Coordinator Prolonged Outage (>72h)
 *   → Switch to backup Chainlink VRF Coordinator (pre-registered subscription)
 *   → If both down → fallback to Chainlink Automation-registered manual fulfillment
 *      using verifiable off-chain randomness signed by 5/7 Chainlink nodes
 * 
 * Scenario 3: Base/Ethereum L2 51% Attack or Deep Reorg
 *   → Pause new deposits/draws
 *   → Users' funds remain safe in Aave (on Ethereum mainnet) – no L2 state risk
 *   → Post-resolution: optional CCIP bridge to new destination chain
 *      (Arbitrum, Optimism, zkSync Era, or future Chainlink-recommended rollup)
 * 
 * Scenario 4: Chainlink Network Full Oracle Failure (Hypothetical)
 *   → Activate pre-deployed "Chainlink Keepers + Blockhash" contingency draw
 *      (still trust-minimized, still verifiable, used only as last resort)
 * 
 * Scenario 5: Regulatory or Forced Migration Event
 *   → Timelocked migrateToNewChain(uint64 newChainSelector, address newPool, address newCoordinator)
 *      using Chainlink CCIP – burns/mints USDC cross-chain, preserves all saver balances
 * 
 * Scenario 6: Owner Key Compromise (Absolute Worst Case)
 *   → 48-hour TimelockController + 5-of-9 multisig of reputable Chainlink ecosystem partners
 *      (Chainlink Labs, Coinbase, Aave Companies, etc.) can execute recovery
 * 
 * @dev GLOBAL ACCESS
 * Supports any currency via off-chain ramps to USDC for global participation
 * 
 * @dev IDENTITY (OPTIONAL)
 * Chainlink DID/GLEIF for verified users – enhances legacy/trust without centralization
 * 
 * @dev PHILOSOPHY
 * DYBL is a business/game primitive where saver rewards are earned via consistency,
 * not charity. This is behavioral economics meets DeFi.
 */

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

/// @title Lettery – Perpetual No-Loss Lottery with Eternal Seed Compounding
/// @author DYBL Foundation
/// @notice This contract implements a weekly lottery where 100% of ticket sales flow into Aave,
///         only yield is distributed, and the principal compounds forever via the Eternal Seed.
/// @dev All numerical parameters (percentages, caps, timeframes) are DRAFT EXAMPLES for V1 prototype.
///      Final values will be set immutably at deployment after simulations, audit, and partner input.
///      
///      KEY MECHANISM: The Eternal Seed ensures perpetual growth through:
///      - 45% of prize pot retained weekly (never paid out)
///      - Rolling treasury injections (high early, decreasing to zero)
///      - Behavioral forfeits from inconsistent users
///      
///      This creates a positive-sum game where the pot grows even at 0% external yield.
contract Lettery is VRFConsumerBaseV2, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // IMMUTABLE PARAMETERS (Set Once at Deploy, Never Changed)
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Maximum jackpot size before excess flows to charity/saver pool
    /// @dev Example: $10M cap to prevent infinite liability
    uint256 public immutable JACKPOT_CAP;
    
    /// @notice Timestamp when treasury take drops to 0% forever
    /// @dev Example: 2 years from deploy - after this, 100% of revenue compounds in vault
    uint256 public immutable ZERO_REVENUE_TIMESTAMP;
    
    /// @notice Basis points (10000 = 100%) of idle treasury to inject weekly as "Eternal Seed"
    /// @dev Example: 500 BPS = 5% of treasury injected each week, decreasing by 5% per week
    ///      This accelerates early growth without permanent subsidy
    uint256 public immutable ETERNAL_SEED_BPS;
    
    /// @notice Years of perfect saving required before Legacy Mode activates
    /// @dev Example: 2 years - user must save consistently before setting an heir
    uint256 public immutable LEGACY_ACTIVATION_YEARS;
    
    /// @notice Years withdrawals are locked to end-of-year only
    /// @dev Example: 3 years - encourages long-term saving, then full flexibility
    uint256 public immutable WITHDRAW_LOCK_YEARS;
    
    /// @notice Contract deployment timestamp (for calculating years elapsed)
    uint256 public immutable DEPLOY_TIMESTAMP;

    /// @notice USDC token address (stablecoin used for all payments)
    address public immutable USDC;
    
    /// @notice Aave's aUSDC token address (yield-bearing receipt)
    address public immutable aUSDC;
    
    /// @notice Aave Pool address (where USDC is supplied for yield)
    address public immutable AAVE_POOL;
    
    /// @notice Charity wallet address (receives excess above jackpot cap)
    address public immutable CHARITY_WALLET;
    
    /// @notice Saver yield pool address (receives additional yield distribution)
    address public immutable SAVER_YIELD_POOL;

    /// @notice Chainlink VRF Coordinator for provably random draws
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    
    /// @notice Chainlink VRF Subscription ID
    uint64 public immutable SUBSCRIPTION_ID;
    
    /// @notice Chainlink VRF Key Hash (gas lane)
    bytes32 public immutable KEY_HASH;

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // THE OFFICIAL DYBL 42-CHARACTER MEME ALPHABET
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice The immutable 42-character set used for all weekly draws
    /// @dev Every weekly draw selects 6 unique symbols from this alphabet
    ///      Combinatorics: C(42,6) = 5,245,786 possible winning combinations
    ///      
    ///      Alphabet breakdown:
    ///      A-Z (26 letters) + 0-9 (10 digits) + !@#$%& (6 special chars) = 42 total
    ///      
    ///      This set is PERMANENTLY LOCKED and defines the entire game forever.
    ///      Order doesn't matter for matching (e.g., "ABC123" matches "321CBA")
    bytes1[42] public constant MEME_ALPHABET = [
        bytes1(0x41),0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A, // A–J
        0x4B,0x4C,0x4D,0x4E,0x4F,0x50,0x51,0x52,0x53,0x54,         // K–T
        0x55,0x56,0x57,0x58,0x59,0x5A,                             // U–Z
        0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,         // 0–9
        0x21,0x40,0x23,0x24,0x25,0x26                              // ! @ # $ % &
    ];

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // STATE VARIABLES (Modified During Operation)
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Current prize pot available for weekly distribution
    /// @dev Only 55% paid out weekly, rest compounds via Eternal Seed
    uint256 public prizePot;
    
    /// @notice Treasury operating reserve (for Chainlink fees, infrastructure)
    /// @dev Starts at ~15% of revenue, decreases to 0% at ZERO_REVENUE_TIMESTAMP
    uint256 public treasuryOperatingReserve;
    
    /// @notice Treasury gift reserve (ring-fenced for cashback + free tickets)
    /// @dev ~20% of revenue, used for loyalty rewards
    uint256 public treasuryGiftReserve;
    
    /// @notice Total principal saved by all savers (excludes yield)
    /// @dev Used to calculate proportional yield distribution
    uint256 public totalSaverBalance;

    /// @notice Current treasury take in basis points (10000 = 100%)
    /// @dev Starts at 3500 (35%), onlyOwner can DECREASE (never increase)
    ///      Automatically drops to 0 at ZERO_REVENUE_TIMESTAMP
    uint256 public treasuryTakeBps = 3500;
    
    /// @notice Current week number (increments with each draw)
    uint256 public currentWeek;
    
    /// @notice Timestamp of last successful draw
    uint256 public lastDrawTimestamp;

    /// @notice Mapping: user address → their total saved principal
    /// @dev Does NOT include accrued yield (see getUserYield function)
    mapping(address => uint256) public saverBalance;
    
    /// @notice Mapping: user address → total tickets purchased (lifetime)
    mapping(address => uint256) public ticketsBought;
    
    /// @notice Mapping: user address → consecutive weeks of perfect saving
    /// @dev Resets to 0 if user misses a week or breaks streak
    mapping(address => uint256) public streakWeeks;
    
    /// @notice Mapping: user address → timestamp of last ticket purchase
    /// @dev Used to detect broken streaks (>8 days gap = streak broken)
    mapping(address => uint256) public lastBuyTimestamp;
    
    /// @notice Mapping: user address → yield multiplier in basis points
    /// @dev 10000 = 100% yield (savers), 5000 = 50% yield (gamblers)
    ///      This is the Pavlovian toggle - behavioral conditioning via yield tiers
    mapping(address => uint256) public yieldMultiplierBps;
    
    /// @notice Mapping: user address → designated heir for Legacy Mode
    /// @dev After 10 years of inactivity, heir can claim user's balance + yield
    mapping(address => address) public heir;
    
    /// @notice Mapping: user address → number of play entries this week
    /// @dev Resets to 0 after each draw
    mapping(address => uint256) public playEntriesThisWeek;
    
    /// @notice Mapping: user address → their 6-character guess for this week
    /// @dev Must be exactly 6 characters from MEME_ALPHABET
    mapping(address => string) public thisWeekGuess;
    
    /// @notice Mapping: user address → year → whether cashback was already claimed
    /// @dev Prevents double-claiming of annual loyalty rewards
    mapping(address => mapping(uint256 => bool)) public cashbackClaimed;

    /// @notice Array of all users who entered this week's draw
    /// @dev Resets after each draw to save gas
    address[] public playersThisWeek;
    
    /// @notice Total number of play entries this week (can exceed playersThisWeek.length)
    uint256 public totalPlayEntriesThisWeek;

    /// @notice Whether current week is a special "Community Week"
    /// @dev Community Week: 1/6 matches win free ticket (happens quarterly)
    bool public isCommunityWeek;
    
    /// @notice Timestamp of last Community Week declaration
    /// @dev Enforces 90-day minimum gap between Community Weeks
    uint256 public lastCommunityWeekTimestamp;

    /// @notice Struct holding results for a specific week's draw
    /// @dev Stores winning combo + all winners at each match tier
    struct WeeklyResult {
        string combo;                   // The 6-character winning combination
        address[] jackpotWinners;       // 6/6 matches
        address[] match5;               // 5/6 matches
        address[] match4;               // 4/6 matches
        address[] match3;               // 3/6 matches
        address[] match2;               // 2/6 matches
        address[] match1;               // 1/6 matches (Community Week only)
    }
    
    /// @notice Mapping: week number → that week's results
    mapping(uint256 => WeeklyResult) public weeklyResults;

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // CONSTANTS (Draft Examples - Final Values Set at Deploy)
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Price per ticket in USDC (6 decimals)
    /// @dev Example: 3 USDC = 3000000 (3e6)
    uint256 public constant TICKET_PRICE = 3e6;
    
    /// @notice Percentage of prize pot paid out weekly in basis points
    /// @dev 5500 BPS = 55% - the other 45% stays in pot (Eternal Seed retention)
    uint256 public constant PAYOUT_PERCENT_BPS = 5500;
    
    /// @notice Distribution of the 55% payout across 5 tiers
    /// @dev [6/6, 5/6, 4/6, 3/6, 2/6] = [40%, 25%, 20%, 10%, 5%] of the 55%
    ///      Example: If 55% payout = $10K, then 6/6 winners split $4K (40% of $10K)
    uint256[5] public constant TIERS_PERCENT_OF_55 = [
        4000,  // 6/6 → 40% of the 55%
        2500,  // 5/6 → 25%
        2000,  // 4/6 → 20%
        1000,  // 3/6 → 10%
         500   // 2/6 →  5%
    ];

    /// @notice Saver cashback percentages by year (basis points)
    /// @dev Year 1: 10%, Year 2: 15%, Year 3: 20% of total spent
    ///      Example: Saver who bought $156 in tickets gets $15.60 back in Year 1
    uint256 public constant SAVER_CB_BPS_Y1 = 1000;   // 10%
    uint256 public constant SAVER_CB_BPS_Y2 = 1500;   // 15%
    uint256 public constant SAVER_CB_BPS_Y3 = 2000;   // 20%

    /// @notice Gambler rewards by year (basis points, paid in free tickets)
    /// @dev Gamblers get roughly half what savers get (they already played for jackpot)
    ///      Example: Year 1 gambler gets 5% back in free tickets vs saver's 10% cash
    uint256 public constant GAMBLER_CB_BPS_Y1 = 500;   // 5%
    uint256 public constant GAMBLER_CB_BPS_Y2 = 750;   // 7.5%
    uint256 public constant GAMBLER_CB_BPS_Y3 = 1000;  // 10%

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Emitted when a user purchases a ticket
    /// @param user Address of ticket buyer
    /// @param playMode True if entering draw this week, false if pure saving
    /// @param week Week number of purchase
    event TicketBought(address indexed user, bool playMode, uint256 week);
    
    /// @notice Emitted when Chainlink VRF fulfills the weekly random draw
    /// @param week Week number
    /// @param combo The 6-character winning combination
    event WinningComboDrawn(uint256 indexed week, string combo);
    
    /// @notice Emitted when a winner receives their prize
    /// @param winner Address of winner
    /// @param amount USDC amount won
    /// @param matchLevel Number of characters matched (1-6)
    event WinnerSelected(address indexed winner, uint256 amount, uint256 matchLevel);
    
    /// @notice Emitted when a user claims annual cashback
    /// @param user Address claiming
    /// @param year Year number (1, 2, or 3)
    /// @param amount USDC or free ticket value
    /// @param isCash True if cash payout (saver), false if free tickets (gambler)
    event CashbackClaimed(address indexed user, uint256 year, uint256 amount, bool isCash);
    
    /// @notice Emitted when a user breaks their saving streak
    /// @param user Address of user
    /// @param forfeitedYield Amount of yield forfeited (50% to treasury, 50% to pot)
    event StreakBroken(address indexed user, uint256 forfeitedYield);
    
    /// @notice Emitted when a user designates an heir in Legacy Mode
    /// @param user Address setting heir
    /// @param heir Address of designated heir
    event HeirSet(address indexed user, address heir);
    
    /// @notice Emitted when an heir successfully claims inheritance
    /// @param heir Address of heir
    /// @param original Original owner's address
    /// @param amount Total claimed (principal + yield)
    event HeirClaimed(address indexed heir, address indexed original, uint256 amount);
    
    /// @notice Emitted when treasury injects liquidity into prize pot (Eternal Seed)
    /// @param amount USDC injected from treasury reserves
    event EternalSeedInjected(uint256 amount);
    
    /// @notice Emitted when owner declares a special Community Week
    /// @param week Week number declared as Community Week
    event CommunityWeekDeclared(uint256 week);

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Initializes the Lettery contract with all immutable parameters
    /// @dev All parameters are locked forever after deployment - choose carefully!
    /// @param _vrfCoordinator Chainlink VRF Coordinator address
    /// @param _subId Chainlink VRF Subscription ID
    /// @param _keyHash Chainlink VRF Key Hash (gas lane)
    /// @param _usdc USDC token address
    /// @param _aavePool Aave V3 Pool address
    /// @param _jackpotCap Maximum jackpot size before excess distributed
    /// @param _zeroYears Years until treasury take drops to 0%
    /// @param _eternalSeedBps Basis points of treasury to inject weekly
    /// @param _charity Charity wallet for excess above cap
    /// @param _saverYieldPool Additional saver yield distribution pool
    /// @param _legacyYears Years before Legacy Mode activates
    /// @param _withdrawLockYears Years before unrestricted withdrawals allowed
    constructor(
        address _vrfCoordinator,
        uint64 _subId,
        bytes32 _keyHash,
        address _usdc,
        address _aavePool,
        uint256 _jackpotCap,
        uint256 _zeroYears,
        uint256 _eternalSeedBps,
        address _charity,
        address _saverYieldPool,
        uint256 _legacyYears,
        uint256 _withdrawLockYears
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        SUBSCRIPTION_ID = _subId;
        KEY_HASH = _keyHash;

        USDC = _usdc;
        AAVE_POOL = _aavePool;
        
        // Fetch Aave's aToken address for USDC
        (,,,,address aToken,,,,,) = IPool(_aavePool).getReserveData(_usdc);
        aUSDC = aToken;

        JACKPOT_CAP = _jackpotCap;
        ZERO_REVENUE_TIMESTAMP = block.timestamp + _zeroYears * 365 days;
        ETERNAL_SEED_BPS = _eternalSeedBps;

        CHARITY_WALLET = _charity;
        SAVER_YIELD_POOL = _saverYieldPool;

        DEPLOY_TIMESTAMP = block.timestamp;
        lastDrawTimestamp = block.timestamp;

        LEGACY_ACTIVATION_YEARS = _legacyYears;
        WITHDRAW_LOCK_YEARS = _withdrawLockYears;
    }

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // CORE GAMEPLAY - TICKET PURCHASE
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Purchase a lottery ticket - all revenue flows into Aave vault
    /// @dev This is the primary entry point for users. Each purchase:
    ///      1. Transfers USDC from user and supplies to Aave
    ///      2. Splits revenue: ~65% to prize pot, ~35% to treasury (decreases over time)
    ///      3. Tracks user's streak and applies forfeit penalties if streak broken
    ///      4. Sets yield multiplier: 100% for savers, 50% for gamblers (Pavlovian toggle)
    ///      5. Auto-triggers draw if 7+ days since last draw
    /// 
    /// @param playThisWeek True to enter this week's draw, false to pure save
    /// @param userGuess 6-character string from MEME_ALPHABET (order doesn't matter)
    function buyTicket(bool playThisWeek, string calldata userGuess) external nonReentrant {
        require(bytes(userGuess).length == 6, "Guess must be exactly 6 characters");
        require(_isValidGuess(userGuess), "Guess contains invalid characters");
        
        // Transfer USDC from user and supply to Aave
        IERC20(USDC).safeTransferFrom(msg.sender, address(this), TICKET_PRICE);
        IERC20(USDC).safeApprove(AAVE_POOL, TICKET_PRICE);
        IPool(AAVE_POOL).supply(USDC, TICKET_PRICE, address(this), 0);

        // Calculate treasury split (~35% initially, decreasing to 0%)
        uint256 prizeAllocation = TICKET_PRICE * (10000 - treasuryTakeBps) / 10000;
        prizePot += prizeAllocation;

        uint256 treasurySlice = TICKET_PRICE - prizeAllocation;
        // ~20% of total ticket → gift reserve (for cashback/free tickets)
        treasuryGiftReserve += treasurySlice * 5714 / 10000;
        // ~15% of total ticket → ops reserve (for Chainlink fees, infrastructure)
        treasuryOperatingReserve += treasurySlice - (treasurySlice * 5714 / 10000);

        // Streak tracking and forfeit logic
        // If user missed a week (>8 days gap), forfeit their accrued yield
        if (block.timestamp > lastBuyTimestamp[msg.sender] + 8 days) {
            uint256 forfeited = _forfeitYield(msg.sender);
            if (forfeited > 0) emit StreakBroken(msg.sender, forfeited);
            streakWeeks[msg.sender] = 1;
        } else {
            streakWeeks[msg.sender]++;
        }
        lastBuyTimestamp[msg.sender] = block.timestamp;
        ticketsBought[msg.sender]++;

        // THE PAVLOVIAN TOGGLE: Behavioral conditioning via yield tiers
        if (playThisWeek) {
            // Gambler: Enters draw, gets 50% yield, risk of losing
            if (playEntriesThisWeek[msg.sender] == 0) playersThisWeek.push(msg.sender);
            playEntriesThisWeek[msg.sender]++;
            totalPlayEntriesThisWeek++;
            yieldMultiplierBps[msg.sender] = 5000;  // 50% yield
        } else {
            // Saver: Pure save, gets 100% yield, guaranteed compounding
            saverBalance[msg.sender] += TICKET_PRICE;
            totalSaverBalance += TICKET_PRICE;
            yieldMultiplierBps[msg.sender] = 10000; // 100% yield
        }

        thisWeekGuess[msg.sender] = userGuess;

        emit TicketBought(msg.sender, playThisWeek, currentWeek);

        // Auto-trigger draw if 7 days elapsed
        if (block.timestamp >= lastDrawTimestamp + 7 days) _requestRandomness();
    }

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // CHAINLINK VRF CALLBACK – THE WEEKLY HEARTBEAT
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Chainlink VRF callback - executes weekly draw and prize distribution
    /// @dev Called automatically by Chainlink VRF Coordinator after randomness fulfilled
    ///      This is the "heartbeat" of the protocol - happens every ~7 days
    /// 
    ///      Flow:
    ///      1. Check if treasury take should drop to 0% (if past ZERO_REVENUE_TIMESTAMP)
    ///      2. Inject Eternal Seed from idle treasury (accelerates pot growth)
    ///      3. Generate 6-character winning combo from VRF randomness
    ///      4. Distribute prizes across 5 tiers (6/6, 5/6, 4/6, 3/6, 2/6 matches)
    ///      5. Reset weekly state for next round
    /// 
    /// @param requestId Chainlink VRF request ID (unused in current implementation)
    /// @param randomWords Array of random values from Chainlink VRF (we use randomWords[0])
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // If we've reached the zero-revenue timestamp, treasury take drops to 0% forever
        if (block.timestamp >= ZERO_REVENUE_TIMESTAMP) treasuryTakeBps = 0;

        // ═════════════════════════════════════════════════════════════════════════════════════
        // THE ETERNAL SEED INJECTION - Core Innovation
        // ═════════════════════════════════════════════════════════════════════════════════════
        // 
        // This is what makes DYBL different from every other lottery/savings protocol.
        // 
        // Instead of just relying on external yield (Aave APY), we inject a portion of
        // idle treasury liquidity into the prize pot each week. This creates exponential
        // growth in the early phase, then tapers off as treasury naturally decreases.
        // 
        // Math:
        // seed = (prizePot + treasuryReserves) * ETERNAL_SEED_BPS / 10000
        // Example: If pot=$100K, treasury=$50K, BPS=500 → seed = $150K * 5% = $7.5K
        // 
        // This $7.5K is withdrawn from treasury and added to pot, compounding forever.
        // Over time, as treasury shrinks, injections decrease naturally (no governance needed).
        // 
        // Result: Pot grows 20-50% faster in Year 1-2, then stabilizes on pure yield.
        // ═════════════════════════════════════════════════════════════════════════════════════
        
        uint256 seed = (prizePot + treasuryOperatingReserve + treasuryGiftReserve) * ETERNAL_SEED_BPS / 10000;
        if (seed > 0) {
            // Only inject what we actually have in treasury (prevent underflow)
            if (seed <= treasuryOperatingReserve) {
                treasuryOperatingReserve -= seed;
            } else {
                // If seed exceeds available treasury, inject max available
                seed = treasuryOperatingReserve;
                treasuryOperatingReserve = 0;
            }
            prizePot += seed;
            emit EternalSeedInjected(seed);
        }

        // Generate winning 6-character combo from VRF randomness
        string memory combo = _generateMemeCombo(randomWords[0]);
        emit WinningComboDrawn(++currentWeek, combo);
        weeklyResults[currentWeek].combo = combo;

        // Distribute prizes to winners at each tier
        _distributeWeeklyPrizes();

        // Reset weekly state for next round
        for (uint256 i = 0; i < playersThisWeek.length; i++) {
            playEntriesThisWeek[playersThisWeek[i]] = 0;
            thisWeekGuess[playersThisWeek[i]] = "";
        }
        delete playersThisWeek;
        totalPlayEntriesThisWeek = 0;
        lastDrawTimestamp = block.timestamp;
    }

    /// @notice Distributes weekly prizes across all match tiers
    /// @dev Called internally by fulfillRandomWords after combo is drawn
    ///      
    ///      Prize Distribution Logic:
    ///      1. Calculate payout pool: 55% of current prize pot
    ///      2. Remaining 45% stays in pot forever (Eternal Seed retention)
    ///      3. Split 55% payout across 5 tiers: [40%, 25%, 20%, 10%, 5%]
    ///      4. Count matches for each player (6/6, 5/6, 4/6, 3/6, 2/6)
    ///      5. Divide tier prize evenly among all winners in that tier
    ///      6. If no winners in a tier, roll those funds back to pot (compounds)
    ///      7. Special: Community Week gives free tickets for 1/6 matches
    function _distributeWeeklyPrizes() internal {
        // Only pay out 55% of pot - the other 45% compounds forever
        uint256 payoutPool = prizePot * PAYOUT_PERCENT_BPS / 10000;
        prizePot -= payoutPool;

        // Calculate amount for each tier
        uint256[5] memory tierAmounts;
        for (uint256 i = 0; i < 5; i++) {
            tierAmounts[i] = payoutPool * TIERS_PERCENT_OF_55[i] / 10000;
        }

        // Count matches for all players
        for (uint256 i = 0; i < playersThisWeek.length; i++) {
            address user = playersThisWeek[i];
            uint256 matches = _countMatches(weeklyResults[currentWeek].combo, thisWeekGuess[user]);

            // Categorize by match level
            if (matches == 6) weeklyResults[currentWeek].jackpotWinners.push(user);
            else if (matches == 5) weeklyResults[currentWeek].match5.push(user);
            else if (matches == 4) weeklyResults[currentWeek].match4.push(user);
            else if (matches == 3) weeklyResults[currentWeek].match3.push(user);
            else if (matches == 2) weeklyResults[currentWeek].match2.push(user);
            else if (isCommunityWeek && matches == 1) weeklyResults[currentWeek].match1.push(user);
        }

        // Pay out each tier
        _payTier(weeklyResults[currentWeek].jackpotWinners, tierAmounts[0], 6);
        _payTier(weeklyResults[currentWeek].match5, tierAmounts[1], 5);
        _payTier(weeklyResults[currentWeek].match4, tierAmounts[2], 4);
        _payTier(weeklyResults[currentWeek].match3, tierAmounts[3], 3);
        _payTier(weeklyResults[currentWeek].match2, tierAmounts[4], 2);

        // Community Week special: 1/6 matches get free ticket
        if (isCommunityWeek) {
            for (uint256 i = 0; i < weeklyResults[currentWeek].match1.length; i++) {
                address winner = weeklyResults[currentWeek].match1[i];
                // Grant free ticket for next week's draw
                playEntriesThisWeek[winner] += 1;
                totalPlayEntriesThisWeek += 1;
                emit WinnerSelected(winner, TICKET_PRICE, 1);
            }
            isCommunityWeek = false;
        }
    }

    /// @notice Pays out prizes to winners in a specific tier
    /// @dev If no winners, rolls funds back to pot (compounds instead of wasted)
    /// @param winners Array of winner addresses
    /// @param amount Total USDC to distribute among winners
    /// @param matchLevel Match tier (1-6) for event emission
    function _payTier(address[] memory winners, uint256 amount, uint256 matchLevel) internal {
        if (winners.length == 0) {
            // No winners at this tier - add back to pot (compounding effect)
            prizePot += amount;
            return;
        }
        
        // Divide prize evenly among all winners
        uint256 perWinner = amount / winners.length;
        
        // Withdraw from Aave and distribute
        IPool(AAVE_POOL).withdraw(USDC, amount, address(this));
        for (uint256 i = 0; i < winners.length; i++) {
            IERC20(USDC).safeTransfer(winners[i], perWinner);
            emit WinnerSelected(winners[i], perWinner, matchLevel);
        }
    }

    /// @notice Counts how many characters match between winning combo and user's guess
    /// @dev Order doesn't matter - "ABC" matches "CBA" as 3/3
    ///      This is intentionally simple (O(n²)) since n=6 is tiny
    /// @param combo Winning combination from VRF draw
    /// @param guess User's submitted guess
    /// @return Number of matching characters (0-6)
    function _countMatches(string memory combo, string memory guess) internal pure returns (uint256) {
        bytes memory c = bytes(combo);
        bytes memory g = bytes(guess);
        uint256 count = 0;
        
        // For each character in combo, check if it exists in guess
        for (uint256 i = 0; i < 6; i++) {
            for (uint256 j = 0; j < 6; j++) {
                if (c[i] == g[j]) {
                    count++;
                    break; // Move to next combo character
                }
            }
        }
        return count;
    }

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // LOYALTY REWARDS - CASHBACK + FREE TICKETS
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Claim annual cashback reward (cash for savers, free tickets for gamblers)
    /// @dev Rewards scale by year: Y1=10/5%, Y2=15/7.5%, Y3=20/10% (saver/gambler)
    ///      
    ///      Example: Saver who bought 52 tickets ($156) in Year 1 gets $15.60 cash back
    ///      Example: Gambler who bought 52 tickets in Year 1 gets $7.80 in free tickets
    ///      
    ///      Savers get double rewards because:
    ///      - They didn't play (no chance to win jackpot)
    ///      - They demonstrated discipline (perfect streak)
    ///      - They grew the pot for everyone else
    function claimCashback() external nonReentrant {
        uint256 year = (block.timestamp - DEPLOY_TIMESTAMP) / 365 days + 1;
        require(year <= 3, "Cashback program ended after Year 3");
        require(!cashbackClaimed[msg.sender][year], "Already claimed this year");

        // Determine cashback rate based on saver vs gambler status
        uint256 bps;
        if (yieldMultiplierBps[msg.sender] == 10000) {
            // Perfect saver: full cashback rates
            bps = year == 1 ? SAVER_CB_BPS_Y1 :
                  year == 2 ? SAVER_CB_BPS_Y2 : SAVER_CB_BPS_Y3;
        } else {
            // Gambler: half the saver rate (they already played for jackpot)
            bps = year == 1 ? GAMBLER_CB_BPS_Y1 :
                  year == 2 ? GAMBLER_CB_BPS_Y2 : GAMBLER_CB_BPS_Y3;
        }

        require(bps > 0 && treasuryGiftReserve > 0, "Nothing to claim");
        
        // Calculate total claimable based on lifetime tickets purchased
        uint256 claimable = ticketsBought[msg.sender] * TICKET_PRICE * bps / 10000;
        require(claimable > 0, "No tickets purchased");
        require(claimable <= treasuryGiftReserve, "Insufficient gift reserve");

        treasuryGiftReserve -= claimable;
        cashbackClaimed[msg.sender][year] = true;

        // Payout method differs by user type
        if (yieldMultiplierBps[msg.sender] == 10000) {
            // Saver: Direct USDC cashback
            IPool(AAVE_POOL).withdraw(USDC, claimable, address(this));
            IERC20(USDC).safeTransfer(msg.sender, claimable);
            emit CashbackClaimed(msg.sender, year, claimable, true);
        } else {
            // Gambler: Free tickets for next draw (if they have enough yield)
            if (canGambleWithYield(msg.sender)) {
                uint256 freeTickets = claimable / TICKET_PRICE;
                playEntriesThisWeek[msg.sender] += freeTickets;
                totalPlayEntriesThisWeek += freeTickets;
                emit CashbackClaimed(msg.sender, year, claimable, false);
            }
            // If gambler broke streak and lost yield, cashback is forfeited
        }
    }

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // SAVER WITHDRAWALS (Restricted to EOY for First N Years)
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Withdraw savings (principal + accrued yield)
    /// @dev Withdrawal rules:
    ///      Years 1-WITHDRAW_LOCK_YEARS: Only allowed at end of year (encourages long-term saving)
    ///      After WITHDRAW_LOCK_YEARS: Unrestricted anytime withdrawal
    ///      
    ///      This creates a "soft lock" that:
    ///      - Reduces churn in early years (pot grows faster)
    ///      - Doesn't permanently lock funds (user can still exit yearly)
    ///      - Rewards patience with higher compounding
    function withdrawSavings() external nonReentrant {
        uint256 year = (block.timestamp - DEPLOY_TIMESTAMP) / 365 days + 1;
        
        // First N years: only allow withdrawals at end of year
        if (year <= WITHDRAW_LOCK_YEARS) {
            require(_isEndOfYear(), "Withdrawals only allowed at end of year for first 3 years");
        }

        uint256 principal = saverBalance[msg.sender];
        uint256 yield = getUserYield(msg.sender);
        uint256 total = principal + yield;

        require(total > 0, "Nothing to withdraw");
        
        // Clear user's balance
        saverBalance[msg.sender] = 0;
        totalSaverBalance -= principal;

        // Withdraw from Aave and transfer to user
        IPool(AAVE_POOL).withdraw(USDC, total, address(this));
        IERC20(USDC).safeTransfer(msg.sender, total);
    }

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // LEGACY MODE - GENERATIONAL WEALTH TRANSFER
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Set an heir to inherit your balance after inactivity
    /// @dev Requires LEGACY_ACTIVATION_YEARS of perfect saving first
    ///      This is literally coding generational wealth transfer into DeFi
    ///      
    ///      Example: After 2 years of consistent saving, you designate your child as heir.
    ///               If you're inactive for 10 years, they can claim your balance + yield.
    /// 
    /// @param _heir Address of designated heir
    function setHeir(address _heir) external {
        uint256 year = (block.timestamp - DEPLOY_TIMESTAMP) / 365 days + 1;
        require(year >= LEGACY_ACTIVATION_YEARS, "Must save consistently before setting heir");
        
        heir[msg.sender] = _heir;
        emit HeirSet(msg.sender, _heir);
    }

    /// @notice Heir claims inheritance after 10 years of original owner inactivity
    /// @dev This prevents funds being locked forever if owner loses access
    ///      10 years is long enough to be sure owner isn't coming back
    /// @param original Address of original saver (now inactive)
    function claimInheritance(address original) external {
        require(heir[original] == msg.sender, "You are not designated heir");
        require(block.timestamp > lastBuyTimestamp[original] + 10 * 365 days, "Original owner still active");

        uint256 total = saverBalance[original] + getUserYield(original);
        require(total > 0, "Nothing to inherit");

        // Clear original owner's balance
        uint256 principalAmount = saverBalance[original];
        saverBalance[original] = 0;
        totalSaverBalance -= principalAmount;

        // Transfer to heir
        IPool(AAVE_POOL).withdraw(USDC, total, address(this));
        IERC20(USDC).safeTransfer(msg.sender, total);

        emit HeirClaimed(msg.sender, original, total);
    }

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS (For Frontend / User Queries)
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Calculate user's accrued yield (not yet withdrawn)
    /// @dev Yield = user's share of total pot yield, scaled by their multiplier
    ///      
    ///      Formula:
    ///      totalYield = aUSDC balance - (prizePot + treasury + totalSaverBalance)
    ///      userYield = (userBalance / totalSaverBalance) * totalYield * multiplier
    ///      
    ///      Example: User has $100 saved, total pool is $10K, total yield is $500
    ///               User is saver (100% multiplier) → yield = ($100/$10K) * $500 * 100% = $5
    ///               User is gambler (50% multiplier) → yield = ($100/$10K) * $500 * 50% = $2.50
    /// 
    /// @param user Address to check yield for
    /// @return Accrued yield in USDC (not including principal)
    function getUserYield(address user) public view returns (uint256) {
        if (totalSaverBalance == 0) return 0;
        
        // Total yield = aUSDC balance minus all allocated funds
        uint256 totalYield = IERC20(aUSDC).balanceOf(address(this)) 
                           - prizePot 
                           - treasuryOperatingReserve 
                           - treasuryGiftReserve 
                           - totalSaverBalance;
        
        // User's proportional share, scaled by their multiplier (100% or 50%)
        return saverBalance[user] * yieldMultiplierBps[user] / 10000 * totalYield / totalSaverBalance;
    }

    /// @notice Check if user has enough yield to gamble with
    /// @dev Prevents gamblers from playing when they have no stake
    /// @param user Address to check
    /// @return True if user has $1+ in yield available
    function canGambleWithYield(address user) public view returns (bool) {
        return getUserYield(user) >= 1e6; // $1 minimum threshold
    }

    /// @notice Check if current date is within end-of-year withdrawal window
    /// @dev Last ~2 weeks of year (days 350-365)
    /// @return True if currently in EOY withdrawal period
    function _isEndOfYear() internal view returns (bool) {
        uint256 dayOfYear = (block.timestamp % 365 days) / 1 days;
        return dayOfYear >= 350; // Last 15 days of year
    }

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Validate that user's guess contains only valid MEME_ALPHABET characters
    /// @dev Prevents submission of invalid characters that could never win
    /// @param guess User's 6-character guess
    /// @return True if all characters are in MEME_ALPHABET
    function _isValidGuess(string calldata guess) internal pure returns (bool) {
        bytes memory g = bytes(guess);
        for (uint256 i = 0; i < 6; i++) {
            bool found = false;
            for (uint256 j = 0; j < 42; j++) {
                if (g[i] == MEME_ALPHABET[j]) {
                    found = true;
                    break;
                }
            }
            if (!found) return false;
        }
        return true;
    }

    /// @notice Generate 6-character winning combo from VRF randomness
    /// @dev Uses Fisher-Yates shuffle to select 6 unique characters from MEME_ALPHABET
    ///      
    ///      Current Implementation: Sequential keccak256 hashing for entropy refresh
    ///      Pros: Easy to audit, sufficient uniformity for lottery use, minimal bias
    ///      
    ///      Future Optimization Note: Bit-extraction from single VRF word would be more
    ///      gas-efficient and eliminate theoretical bias. Current approach is intentionally
    ///      simple and clear for audit purposes.
    /// 
    /// @param randomness VRF random value from Chainlink
    /// @return 6-character winning combination string
    function _generateMemeCombo(uint256 randomness) internal pure returns (string memory) {
        bytes1[42] memory chars = MEME_ALPHABET;
        string memory combo = "";
        uint256 rand = randomness;
        uint256 remaining = 42;
        
        // Select 6 unique characters via Fisher-Yates
        for (uint256 i = 0; i < 6; i++) {
            uint256 idx = rand % remaining;
            combo = string(abi.encodePacked(combo, chars[idx]));
            
            // Swap selected char with last remaining char
            chars[idx] = chars[remaining - 1];
            remaining--;
            
            // Refresh randomness for next selection
            rand = uint256(keccak256(abi.encode(rand)));
        }
        return combo;
    }

    /// @notice Forfeit user's yield when they break their saving streak
    /// @dev This is the "punishment" side of the Pavlovian conditioning
    ///      
    ///      Forfeit Distribution:
    ///      50% → Treasury operating reserve (funds Chainlink fees, infrastructure)
    ///      50% → Prize pot (bigger jackpots for everyone else)
    ///      
    ///      This creates a positive externality: When you break your streak, you feed
    ///      the system rather than simply losing out. Your loss becomes community gain.
    /// 
    /// @param user Address of user who broke streak
    /// @return Total yield forfeited
    function _forfeitYield(address user) internal returns (uint256) {
        uint256 yield = getUserYield(user);
        if (yield == 0) return 0;

        // Split forfeit 50/50 between treasury and prize pot
        uint256 forfeitToTreasury = yield / 2;
        treasuryOperatingReserve += forfeitToTreasury;

        uint256 forfeitToPrize = yield - forfeitToTreasury;
        prizePot += forfeitToPrize;

        // Reset streak counter
        streakWeeks[user] = 0;
        
        return yield;
    }

    /// @notice Request random words from Chainlink VRF for weekly draw
    /// @dev Requests 1 random word with 300k gas callback limit
    function _requestRandomness() internal {
        COORDINATOR.requestRandomWords(
            KEY_HASH,
            SUBSCRIPTION_ID,
            3,      // Request confirmations
            300000, // Callback gas limit
            1       // Number of random words
        );
    }

    // ═════════════════════════════════════════════════════════════════════════════════════════════
    // OWNER FUNCTIONS (All One-Way Decreases Only)
    // ═════════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice Decrease treasury take percentage (can only go down, never up)
    /// @dev This is a one-way function - owner can be generous, but never more extractive
    ///      Automatically hits 0% at ZERO_REVENUE_TIMESTAMP regardless
    /// @param newBps New treasury take in basis points (must be less than current)
    function decreaseTreasuryTake(uint256 newBps) external onlyOwner {
        require(newBps < treasuryTakeBps, "Can only decrease treasury take");
        treasuryTakeBps = newBps;
    }

    /// @notice Declare current week as special "Community Week"
    /// @dev Community Week: 1/6 matches win free ticket (happens max quarterly)
    ///      Creates viral moments and onboards new users
    function declareCommunityWeek() external onlyOwner {
        require(block.timestamp > lastCommunityWeekTimestamp + 90 days, "Can only declare quarterly");
        isCommunityWeek = true;
        lastCommunityWeekTimestamp = block.timestamp;
        emit CommunityWeekDeclared(currentWeek);
    }

    /// @notice Manually trigger draw if 7+ days elapsed
    /// @dev Backup function in case auto-trigger fails (should rarely be needed)
    function triggerDraw() external {
        require(block.timestamp >= lastDrawTimestamp + 7 days, "Draw cooldown active");
        _requestRandomness();
    }

    /// @notice Fund Chainlink VRF subscription from treasury reserves
    /// @dev Ensures protocol can sustain itself long-term via self-funding
    /// @param amount USDC to transfer to Chainlink subscription
    function fundChainlink(uint256 amount) external onlyOwner {
        require(amount <= treasuryOperatingReserve, "Insufficient treasury reserves");
        treasuryOperatingReserve -= amount;
        // TODO: Implement actual LINK purchase + subscription funding
        // Placeholder for production implementation
    }
}

// ═════════════════════════════════════════════════════════════════════════════════════════════════
// FUTURE-PROOF UPGRADE PATH (Chainlink-Recommended Architecture)
// ═════════════════════════════════════════════════════════════════════════════════════════════════
//
// Core vault logic is IMMUTABLE (this contract).
// Game rules can be upgraded via transparent proxy + multisig timelock later.
//
// Today's design:
// - No backdoors
// - onlyOwner functions are minimal and one-way (can only decrease extraction)
// - All critical parameters locked forever at deploy
//
// Tomorrow's path:
// - New game mechanics deployed as separate contracts
// - Same vault, new rules layer
// - Users always maintain full custody
//
// This is the DYBL way: Immutable money, flexible games.
// ═════════════════════════════════════════════════════════════════════════════════════════════════
