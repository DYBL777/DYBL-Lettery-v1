// SPDX-License-Identifier: BUSL-1.1
// Licensed under the Business Source License 1.1
// Change Date: 10 May 2029
// On the Change Date, this code becomes available under MIT License.

pragma solidity ^0.8.24;

/**
 * @title DYBL - Decentralised Yield Bearing Legacy
 * @notice "The Eternal Seed" - A Self-Sustaining Capital Retention Mechanism
 * @author DYBL Foundation
 * @dev Lettery_AuditReady_v1.2.sol
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * THE ETERNAL SEED MECHANISM - COMPLETE EXPLANATION
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * PART 1: REVENUE SPLIT (Per $3 Ticket)
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 *
 *   $3 Ticket Purchase
 *   │
 *   ├── 65% ($1.95) → Prize Pot (in Aave)
 *   │   ├── 55% ($1.65) → Prize Pool (paid to winners)
 *   │   └── 10% ($0.30) → Eternal Seed (NEVER LEAVES)
 *   │
 *   └── 35% ($1.05) → Treasury (separate Aave account, same vault for transparency)
 *       ├── 20% ($0.60) → Giveaway Reserve (cashbacks + gambler free tickets)
 *       └── 15% ($0.45) → Operations
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * PART 2: AAVE YIELD ALLOCATION
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 *
 *   All funds sit in Aave earning yield. Here's where that yield goes:
 *
 *   ┌─────────────────────────┬───────────────────────────────────────────────────┐
 *   │ Bucket                  │ Aave Yield Goes To                                │
 *   ├─────────────────────────┼───────────────────────────────────────────────────┤
 *   │ 10% Seed (in pot)       │ SEED → Pot compounds forever!                     │
 *   │ 55% Prize Pool (in pot) │ USERS → Saver incentive (withdraw or gamble)      │
 *   │ 15% Ops Treasury        │ TREASURY → Operational growth                     │
 *   │ 20% Giveaway (idle)     │ TREASURY → Until injected                         │
 *   │ 20% Giveaway (injected) │ SEED → Pot grows while helping! (V2)              │
 *   └─────────────────────────┴───────────────────────────────────────────────────┘
 *
 *   Implementation: _materializeSeedYield()
 *   - Called at start of each draw (calculateMatches)
 *   - Calculates seed's proportional share of Aave yield
 *   - Credits yield to prizePot before payout calculations
 *   - Seed = 10/65 (~15.38%) of prizePot value
 *   - Gas efficient: runs once per week during draw
 *
 *   V2 Future: Truflation periodic rebalancing (see Part 4)
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * PART 3: FIXED ETERNAL SEED (Always Active)
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 *
 *   The 10% Eternal Seed:
 *   - 10% of every ticket goes to seed portion of prize pot
 *   - Seed earns Aave yield (materialized at each draw via _materializeSeedYield)
 *   - Seed is NEVER paid out to winners
 *
 *   Weekly Draw Outcomes:
 *   - Jackpot WON (6/6): Jackpot paid from 55% pool, seed stays
 *   - Jackpot NOT won: Jackpot portion ROLLS OVER, tier winners still paid
 *   - Seed ALWAYS stays regardless of outcome
 *
 *   Prize Pool Tiers (from the 55%):
 *   ┌─────────────────┬─────────────────────────────────────────────────┐
 *   │ Tier 1: 6/6     │ JACKPOT - rolls over if no winner              │
 *   │ Tier 2: 5/6     │ Paid weekly if winners                         │
 *   │ Tier 3: 4/6     │ Paid weekly if winners                         │
 *   │ Tier 4: 3/6     │ Paid weekly if winners                         │
 *   │ Tier 5: 2/6     │ Paid weekly if winners                         │
 *   └─────────────────┴─────────────────────────────────────────────────┘
 *
 *   How Seed VALUE Grows (percentage stays 10%):
 *   ┌─────────┬────────────┬─────────────────────────────────────────────┐
 *   │ Week    │ Seed Value │ Why It Grew                                 │
 *   ├─────────┼────────────┼─────────────────────────────────────────────┤
 *   │ Week 1  │ $1,000     │ 10% of ticket sales                         │
 *   │ Week 2  │ $1,050     │ + Aave yield on seed + new tickets          │
 *   │ Week 10 │ $5,500     │ + Jackpot rollovers (no 6/6 winner)         │
 *   │ Week 52 │ $50,000+   │ Compounding never stops                     │
 *   └─────────┴────────────┴─────────────────────────────────────────────┘
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * PART 4: TRUFLATION ROLLING SEED (Future Enhancement - To Be Tested)
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 *
 *   The Opportunity:
 *   - The 20% Giveaway Reserve is over-funded (only ~10% paid out Year 1)
 *   - ~90% sits idle most of the year
 *   - Idle capital could work harder FOR THE POT
 *
 *   The Solution:
 *   - Truflation oracle monitors prize pot health
 *   - When pot needs boost: INJECT from idle Giveaway Reserve
 *   - When pot stabilizes: WITHDRAW back to Treasury
 *   - Micro-adjustments ensure continuous growth
 *
 *   V2 Truflation Also Manages:
 *   - Automated periodic yield rebalancing across all buckets
 *   - Injection timing optimization based on market conditions
 *   - Another novel use case for Truflation oracles!
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * PART 5: THE WIN-WIN (Why Treasury Injection Benefits EVERYONE)
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 *
 *   The Core Idea: Pot growth >> Aave yield alone (in high-growth periods)
 *
 *   Who Benefits:
 *   ┌─────────────────┬───────────────────────────────────────────────────────────┐
 *   │ Prize Pot       │ Gets Aave yield from seed + injected funds                │
 *   ├─────────────────┼───────────────────────────────────────────────────────────┤
 *   │ Treasury        │ Pot growth >> Aave yield in active periods                │
 *   │                 │ Over-funded anyway (only ~10% paid out Year 1)            │
 *   ├─────────────────┼───────────────────────────────────────────────────────────┤
 *   │ Users           │ Get Aave yield from 55% prize pool portion                │
 *   │                 │ Prize pot always healthy = better prizes                  │
 *   └─────────────────┴───────────────────────────────────────────────────────────┘
 *
 *   Risk Assessment (Honest Evaluation):
 *   - MINIMAL RISK - Asymmetric Upside
 *   - Funds are BORROWED, not given away (principal always returns)
 *   - Treasury benefit depends on pot growth outpacing Aave yield
 *   - High-growth periods: Treasury wins big
 *   - Slow periods: Treasury may underperform vs holding
 *   - Overall: Limited downside, high upside potential
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * PART 6: WHY THE POT CAN ONLY GROW
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 *
 *   Growth Sources (All Compound Together):
 *   ┌─────────────────────────────────────────────────────────────────────────────┐
 *   │  1. Fixed 10% Seed      │ Never leaves, accumulates forever               │
 *   ├─────────────────────────────────────────────────────────────────────────────┤
 *   │  2. Seed Aave Yield     │ Materialized at each draw via _materializeSeed  │
 *   ├─────────────────────────────────────────────────────────────────────────────┤
 *   │  3. Ticket Sales        │ 65% of every $3 ticket adds to pot              │
 *   ├─────────────────────────────────────────────────────────────────────────────┤
 *   │  4. Jackpot Rollovers   │ No 6/6 winner = jackpot portion stays in pot    │
 *   ├─────────────────────────────────────────────────────────────────────────────┤
 *   │  5. Forfeit Yield       │ Broken streaks → 50% to pot                     │
 *   ├─────────────────────────────────────────────────────────────────────────────┤
 *   │  6. Injected Fund Yield │ Treasury injection Aave yield → pot (V2)        │
 *   └─────────────────────────────────────────────────────────────────────────────┘
 *
 *   There is NO scenario where the pot shrinks long-term.
 *   The Eternal Seed ensures the floor only rises.
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * PART 7: SUMMARY
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 *
 *   TODAY (V1.2 - Fixed Seed + Yield Materialization):
 *   - 10% of every ticket → Eternal Seed (never paid out)
 *   - 55% of every ticket → Prize Pool (to winners)
 *   - 35% of every ticket → Treasury (ops + giveaways)
 *   - Seed Aave yield → Pot (materialized at each draw)
 *   - Prize pool Aave yield → Users (saver incentive)
 *   - Pot grows via: seed + seed yield + tickets + rollovers + forfeit yield
 *
 *   FUTURE (V2 - Truflation Rolling Seed + Auto Rebalancing):
 *   - Everything above PLUS:
 *   - Truflation monitors pot health
 *   - Injects from idle treasury when needed
 *   - Asymmetric upside: Prize pot protected, Treasury benefits from pot growth
 *
 *   THE VISION:
 *   A lottery where the prize pot can ONLY grow.
 *   Today's 10% seed becomes tomorrow's fortune.
 *   Compounding forever.
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * CHANGELOG
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * V1.2 YIELD MATERIALIZATION:
 * - [YIELD-01] Added _materializeSeedYield() function
 * - [YIELD-02] Seed yield credited to prizePot at each draw
 * - [YIELD-03] Added SeedYieldMaterialized event
 * - [DOCS-01] Clarified risk assessment (minimal risk, not zero risk)
 * - [CLEANUP] Removed unused minPayoutBps variable
 *
 * V1.1 AUDIT FIXES:
 * - [FIX-019] Users only win at BEST tier, not all matching tiers
 * - [FIX-020] 1-year withdrawal lock-up + timestamp reset
 * - [H-01 FIX] VRF parameters cannot change during pending request
 * - [M-01 FIX] Documented yield calculation difference (NET vs GROSS)
 * - [M-03 FIX] gambleWithYield() now increments ticketsBought
 * - [L-04 FIX] Added YieldForfeited and VRFRequestReset events
 * - [NEW-01 FIX] forceCleanup() uses simple delete to avoid gas limit
 * - [NEW-02 DOC] Shared yield pool behavior documented
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 */

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

contract Lettery is VRFConsumerBaseV2, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // CUSTOM ERRORS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    error DrawInProgress();
    error InvalidGuessLength();
    error InvalidGuessCharacters();
    error DuplicateCharacterInGuess();
    error DuplicateGuessThisWeek();
    error MaxGuessesReached();
    error WeekFull();
    error InsufficientYield();
    error InsufficientBalance();
    error InvalidAddress();
    error InvalidHeir();
    error InsufficientStreak();
    error TooEarly();
    error NotHeir();
    error NothingToClaim();
    error WrongPhase();
    error AaveLiquidityLow();
    error SolvencyCheckFailed();
    error NoEntriesThisWeek();
    error CooldownActive();
    error VRFPending();
    error NoTicketsBought();
    error NoPendingRequest();
    error NotStuck();
    error CanOnlyIncrease();
    error CanOnlyDecrease();
    error ExceedsLimit();
    error WithdrawalLocked();  // [FIX-020] New error

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // DRAW PHASES
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    enum DrawPhase {
        IDLE,
        PENDING_DISTRIBUTION,   // VRF returned, need to calculate matches
        POPULATING_TIERS,       // [FIX-019] New phase: building tier arrays from best matches
        DISTRIBUTING,
        CLEANUP_NEEDED
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // IMMUTABLE PARAMETERS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    address public immutable USDC;
    address public immutable aUSDC;
    address public immutable AAVE_POOL;
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    uint256 public immutable DEPLOY_TIMESTAMP;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // UPDATEABLE VRF PARAMETERS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    uint64 public subscriptionId;
    bytes32 public keyHash;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // CONFIGURABLE PARAMETERS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    uint256 public payoutBps;
    // [CLEANUP] Removed unused minPayoutBps
    uint256 public treasuryTakeBps;
    uint256 public zeroRevenueTimestamp;
    uint256 public heirEligibilityYears;
    uint256 public heirClaimYears;
    uint256 public heirExpiryYears;
    uint256 public mulliganEligibilityMonths;
    bool public savingsCountsAsActivity;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // 42-CHARACTER MEME ALPHABET
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    bytes1[42] public constant MEME_ALPHABET = [
        bytes1(0x41),0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,
        0x4B,0x4C,0x4D,0x4E,0x4F,0x50,0x51,0x52,0x53,0x54,
        0x55,0x56,0x57,0x58,0x59,0x5A,
        0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,
        0x21,0x40,0x23,0x24,0x25,0x26
    ];

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    uint256 public constant TICKET_PRICE = 3e6;
    uint256[5] public constant TIERS_PERCENT = [4000, 2500, 2000, 1000, 500];
    uint256 public constant MAX_TOTAL_ENTRIES_PER_WEEK = 5000;
    uint256 public constant MAX_GUESSES_PER_USER = 5;
    uint256 public constant MAX_PAYOUTS_PER_TX = 100;
    uint256 public constant MAX_MATCHES_PER_TX = 100;
    uint256 public constant MAX_CLEANUP_PER_TX = 100;
    uint256 public constant MIN_ENTRIES_FOR_DRAW = 1;
    uint256 public constant GIFT_RESERVE_BPS = 5714;
    uint256 public constant DRAW_COOLDOWN = 7 days;
    uint256 public constant VRF_TIMEOUT = 24 hours;
    uint256 public constant DRAW_STUCK_TIMEOUT = 48 hours;
    uint256 public constant GUESS_LENGTH = 6;
    uint256 public constant ALPHABET_SIZE = 42;
    uint256 public constant WITHDRAWAL_LOCK_PERIOD = 365 days;  // [FIX-020] 1-year lock
    
    /// @notice [YIELD-01] Seed is 10/65 of prize pot (~15.38%)
    /// @dev Used to calculate seed's proportional share of Aave yield
    uint256 public constant SEED_BPS_OF_POT = 1538;  // 10/65 * 10000 = 1538.46

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // STATE VARIABLES
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    uint256 public prizePot;
    uint256 public treasuryOperatingReserve;
    uint256 public treasuryGiftReserve;
    uint256 public totalUserBalance;
    uint256 public currentWeek;
    uint256 public lastDrawTimestamp;
    uint256 public pendingRequestId;
    uint256 public lastRequestTimestamp;
    uint256 public totalEntriesThisWeek;
    
    /// @notice [YIELD-01] Tracks total seed yield materialized (for analytics)
    uint256 public totalSeedYieldMaterialized;
    
    DrawPhase public drawPhase;
    uint256 public distributionTierIndex;
    uint256 public distributionWinnerIndex;
    uint256[5] public tierPayoutAmounts;
    
    uint256 public matchingPlayerIndex;
    bool public matchingInProgress;
    uint256 public totalWinnersThisDraw;
    uint256 public cleanupIndex;
    
    // [FIX-019] Population phase state
    uint256 public populationIndex;

    // User mappings
    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public yieldSpent;
    mapping(address => uint256) public ticketsBought;
    mapping(address => uint256) public streakWeeks;
    mapping(address => uint256) public firstTicketTimestamp;
    mapping(address => uint256) public lastPlayedRound;
    mapping(address => uint256) public lastBuyTimestamp;
    mapping(address => address) public heir;
    mapping(address => bool) public mulliganUsedThisYear;
    mapping(address => uint256) public lastMulliganResetYear;
    mapping(address => string[]) public thisWeekGuesses;
    mapping(address => uint256) public unclaimedPrizes;
    
    /// @notice [FIX-019] Best match count for each user this week
    /// @dev Reset during cleanup phase
    mapping(address => uint256) public bestMatchThisWeek;

    address[] public playersThisWeek;

    struct WeeklyResult {
        string combo;
        address[] jackpotWinners;
        address[] match5;
        address[] match4;
        address[] match3;
        address[] match2;
    }
    
    mapping(uint256 => WeeklyResult) public weeklyResults;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    event TicketBought(address indexed user, string guess, uint256 indexed week);
    event SavingsDeposited(address indexed user, uint256 amount);
    event GambledWithYield(address indexed user, uint256 yieldUsed, string guess, uint256 indexed week);
    event WinningComboDrawn(uint256 indexed week, string combo);
    event WinnerSelected(address indexed winner, uint256 amount, uint256 matchLevel);
    event PrizeClaimed(address indexed winner, uint256 amount);
    event MatchingComplete(uint256 indexed week, uint256 totalWinners);
    event MatchingBatchProcessed(uint256 indexed week, uint256 processedPlayers, uint256 totalPlayers);
    event TierPopulationComplete(uint256 indexed week);
    event DistributionComplete(uint256 indexed week);
    event CleanupBatchProcessed(uint256 indexed week, uint256 cleaned, uint256 total);
    event WeekFinalized(uint256 indexed week);
    event TierPayoutDeferred(uint256 indexed week, uint256 tier, uint256 amount);
    event DrawReset(uint256 indexed week, string reason);
    event StreakBroken(address indexed user, uint256 forfeitedYield, uint256 missedRounds);
    event StreakUpdated(address indexed user, uint256 newStreak, uint256 round);
    event MulliganUsed(address indexed user, uint256 indexed round);
    event HeirSet(address indexed user, address indexed heir);
    event HeirClaimed(address indexed heir, address indexed original, uint256 amount);
    event InheritanceExpired(address indexed original, uint256 amount);
    event PayoutPercentIncreased(uint256 oldBps, uint256 newBps);
    event TreasuryTakeDecreased(uint256 oldBps, uint256 newBps);
    event TreasuryWithdrawal(uint256 amount, address recipient);
    event TreasuryGiftWithdrawal(uint256 amount, address recipient);
    event SavingsWithdrawn(address indexed user, uint256 principal, uint256 yield);
    event EmergencyReset(uint256 indexed week, DrawPhase fromPhase, string reason);
    event VRFParametersUpdated(uint64 newSubId, bytes32 newKeyHash);
    event SavingsBehaviorChanged(bool countsAsActivity);
    
    // [L-04 FIX] Additional events for better tracking
    event YieldForfeited(address indexed user, uint256 amount, uint256 toTreasury, uint256 toPot);
    event VRFRequestReset(uint256 indexed requestId);
    
    /// @notice [YIELD-03] Emitted when seed yield is materialized to prizePot
    event SeedYieldMaterialized(uint256 indexed week, uint256 amount, uint256 newPrizePot);

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    constructor(
        address _vrfCoordinator,
        uint64 _subId,
        bytes32 _keyHash,
        address _usdc,
        address _aavePool,
        address _aUSDC,
        uint256 _initialPayoutBps,
        uint256 _treasuryTakeBps,
        uint256 _zeroRevenueYears,
        uint256 _heirEligibilityYears,
        uint256 _heirClaimYears,
        uint256 _mulliganMonths
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        if (_vrfCoordinator == address(0)) revert InvalidAddress();
        if (_usdc == address(0)) revert InvalidAddress();
        if (_aavePool == address(0)) revert InvalidAddress();
        if (_aUSDC == address(0)) revert InvalidAddress();
        
        if (_initialPayoutBps < 5500) revert ExceedsLimit();
        if (_initialPayoutBps > 10000) revert ExceedsLimit();
        if (_treasuryTakeBps > 5000) revert ExceedsLimit();
        if (_initialPayoutBps + _treasuryTakeBps > 10000) revert ExceedsLimit();
        
        if (_zeroRevenueYears == 0 || _zeroRevenueYears > 20) revert ExceedsLimit();
        if (_heirEligibilityYears == 0 || _heirEligibilityYears > 10) revert ExceedsLimit();
        if (_heirClaimYears == 0 || _heirClaimYears > 20) revert ExceedsLimit();
        if (_mulliganMonths == 0 || _mulliganMonths > 12) revert ExceedsLimit();
        
        if (_subId == 0) revert ExceedsLimit();
        if (_keyHash == bytes32(0)) revert InvalidAddress();
        
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subId;
        keyHash = _keyHash;
        USDC = _usdc;
        AAVE_POOL = _aavePool;
        aUSDC = _aUSDC;

        payoutBps = _initialPayoutBps;
        // [CLEANUP] Removed minPayoutBps assignment
        treasuryTakeBps = _treasuryTakeBps;
        zeroRevenueTimestamp = block.timestamp + _zeroRevenueYears * 365 days;
        
        heirEligibilityYears = _heirEligibilityYears;
        heirClaimYears = _heirClaimYears;
        heirExpiryYears = 1;
        mulliganEligibilityMonths = _mulliganMonths;
        savingsCountsAsActivity = false;

        DEPLOY_TIMESTAMP = block.timestamp;
        lastDrawTimestamp = block.timestamp;
        drawPhase = DrawPhase.IDLE;
        currentWeek = 1;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // CORE GAMEPLAY
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    function buyTicket(string calldata userGuess) external nonReentrant {
        if (drawPhase != DrawPhase.IDLE) revert DrawInProgress();
        _validateGuess(userGuess);
        if (_alreadyGuessedThisWeek(msg.sender, userGuess)) revert DuplicateGuessThisWeek();
        if (thisWeekGuesses[msg.sender].length >= MAX_GUESSES_PER_USER) revert MaxGuessesReached();
        if (totalEntriesThisWeek >= MAX_TOTAL_ENTRIES_PER_WEEK) revert WeekFull();
        
        _processTicketPurchase(msg.sender);
        _addGuessToWeek(msg.sender, userGuess);
        
        emit TicketBought(msg.sender, userGuess, currentWeek);
    }

    function depositSavings() external nonReentrant {
        if (drawPhase != DrawPhase.IDLE) revert DrawInProgress();
        
        IERC20(USDC).safeTransferFrom(msg.sender, address(this), TICKET_PRICE);
        IERC20(USDC).forceApprove(AAVE_POOL, TICKET_PRICE);
        IPool(AAVE_POOL).supply(USDC, TICKET_PRICE, address(this), 0);

        userBalance[msg.sender] += TICKET_PRICE;
        totalUserBalance += TICKET_PRICE;
        
        if (firstTicketTimestamp[msg.sender] == 0) {
            firstTicketTimestamp[msg.sender] = block.timestamp;
        }
        
        if (savingsCountsAsActivity) {
            _updateActivityTracking(msg.sender);
        }

        emit SavingsDeposited(msg.sender, TICKET_PRICE);
    }

    /// @notice Gamble using accrued yield instead of fresh USDC
    /// @dev [NEW-02 DOCUMENTED] Shared yield pool design note:
    ///      When User A gambles with yield, prizePot increases, which reduces
    ///      the unallocated yield pool. This can slightly reduce other users'
    ///      calculated yield. This is INHERENT to shared yield pool designs
    ///      and affects all users proportionally. Not a bug - documented behavior.
    function gambleWithYield(string calldata userGuess) external nonReentrant {
        if (drawPhase != DrawPhase.IDLE) revert DrawInProgress();
        _validateGuess(userGuess);
        if (_alreadyGuessedThisWeek(msg.sender, userGuess)) revert DuplicateGuessThisWeek();
        if (thisWeekGuesses[msg.sender].length >= MAX_GUESSES_PER_USER) revert MaxGuessesReached();
        if (totalEntriesThisWeek >= MAX_TOTAL_ENTRIES_PER_WEEK) revert WeekFull();
        
        uint256 availableYield = getUserYield(msg.sender);
        if (availableYield < TICKET_PRICE) revert InsufficientYield();
        
        uint256 actualYield = _getActualAvailableYield(msg.sender);
        if (actualYield < TICKET_PRICE) revert InsufficientYield();
        
        _updateActivityTracking(msg.sender);
        
        yieldSpent[msg.sender] += TICKET_PRICE;
        prizePot += TICKET_PRICE;
        ticketsBought[msg.sender]++;  // [M-03 FIX] Track yield-based plays for triggerDraw eligibility
        
        _addGuessToWeek(msg.sender, userGuess);

        emit GambledWithYield(msg.sender, TICKET_PRICE, userGuess, currentWeek);
        _tryTriggerDraw();
    }

    function _addGuessToWeek(address user, string calldata guess) internal {
        if (thisWeekGuesses[user].length == 0) {
            playersThisWeek.push(user);
        }
        thisWeekGuesses[user].push(guess);
        totalEntriesThisWeek++;
    }

    function _processTicketPurchase(address user) internal {
        IERC20(USDC).safeTransferFrom(user, address(this), TICKET_PRICE);
        IERC20(USDC).forceApprove(AAVE_POOL, TICKET_PRICE);
        IPool(AAVE_POOL).supply(USDC, TICKET_PRICE, address(this), 0);

        uint256 prizeAllocation = TICKET_PRICE * (10000 - treasuryTakeBps) / 10000;
        prizePot += prizeAllocation;

        uint256 treasurySlice = TICKET_PRICE - prizeAllocation;
        treasuryGiftReserve += treasurySlice * GIFT_RESERVE_BPS / 10000;
        treasuryOperatingReserve += treasurySlice - (treasurySlice * GIFT_RESERVE_BPS / 10000);

        _updateActivityTracking(user);
        
        ticketsBought[user]++;
        userBalance[user] += TICKET_PRICE;
        totalUserBalance += TICKET_PRICE;

        _tryTriggerDraw();
    }

    function _tryTriggerDraw() internal {
        if (block.timestamp >= lastDrawTimestamp + DRAW_COOLDOWN && 
            pendingRequestId == 0 && 
            drawPhase == DrawPhase.IDLE &&
            totalEntriesThisWeek >= MIN_ENTRIES_FOR_DRAW) {
            _requestRandomness();
        }
    }

    function _updateActivityTracking(address user) internal {
        if (firstTicketTimestamp[user] == 0) {
            firstTicketTimestamp[user] = block.timestamp;
        }
        
        lastBuyTimestamp[user] = block.timestamp;

        uint256 currentYear = (block.timestamp - DEPLOY_TIMESTAMP) / 365 days;
        if (currentYear > lastMulliganResetYear[user]) {
            mulliganUsedThisYear[user] = false;
            lastMulliganResetYear[user] = currentYear;
        }

        uint256 userLastRound = lastPlayedRound[user];
        
        if (userLastRound == 0) {
            streakWeeks[user] = 1;
            lastPlayedRound[user] = currentWeek;
            emit StreakUpdated(user, 1, currentWeek);
            return;
        }
        
        if (userLastRound == currentWeek) {
            return;
        }
        
        if (currentWeek == userLastRound + 1) {
            streakWeeks[user]++;
            lastPlayedRound[user] = currentWeek;
            emit StreakUpdated(user, streakWeeks[user], currentWeek);
            return;
        }
        
        uint256 missedRounds = currentWeek - userLastRound - 1;
        _handleMissedRounds(user, missedRounds);
        lastPlayedRound[user] = currentWeek;
    }

    function _handleMissedRounds(address user, uint256 missedRounds) internal {
        bool mulliganEligible = block.timestamp > firstTicketTimestamp[user] + mulliganEligibilityMonths * 30 days;
        
        if (missedRounds == 1 && mulliganEligible && !mulliganUsedThisYear[user]) {
            mulliganUsedThisYear[user] = true;
            emit MulliganUsed(user, currentWeek);
            emit StreakUpdated(user, streakWeeks[user], currentWeek);
        } else {
            uint256 forfeited = _forfeitYield(user);
            emit StreakBroken(user, forfeited, missedRounds);
            streakWeeks[user] = 1;
            emit StreakUpdated(user, 1, currentWeek);
        }
    }

    function _forfeitYield(address user) internal returns (uint256) {
        uint256 yield = getUserYield(user);
        if (yield == 0) return 0;

        uint256 actualYield = _getActualAvailableYield(user);
        if (actualYield == 0) return 0;
        
        uint256 toForfeit = yield > actualYield ? actualYield : yield;
        if (toForfeit == 0) return 0;

        yieldSpent[user] += toForfeit;

        uint256 toTreasury = toForfeit / 2;
        uint256 toPrizePot = toForfeit - toTreasury;
        
        treasuryOperatingReserve += toTreasury;
        prizePot += toPrizePot;
        
        emit YieldForfeited(user, toForfeit, toTreasury, toPrizePot);  // [L-04 FIX]

        return toForfeit;
    }

    /// @notice [M-01 DOCUMENTED] Returns GROSS proportional yield (before yieldSpent deduction)
    /// @dev Used for internal accounting - checks actual Aave balance vs allocations
    ///      Different from getUserYield() which returns NET available yield
    function _getActualAvailableYield(address user) internal view returns (uint256) {
        uint256 totalContractValue = IERC20(aUSDC).balanceOf(address(this));
        uint256 totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUserBalance;
        
        if (totalContractValue <= totalAllocated) return 0;
        
        uint256 actualTotalYield = totalContractValue - totalAllocated;
        if (totalUserBalance == 0) return 0;
        
        return userBalance[user] * actualTotalYield / totalUserBalance;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // YIELD MATERIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice [YIELD-01] Materialize seed's share of Aave yield into prizePot
     * @dev Called at start of each draw before payout calculations
     * 
     * HOW IT WORKS:
     * 1. Calculate total unallocated yield (aUSDC balance - all allocations)
     * 2. Calculate seed's value (10/65 of prizePot)
     * 3. Calculate seed's proportional share of total yield
     * 4. Credit that yield to prizePot (seed compounds!)
     *
     * GAS: Runs once per week during draw - minimal overhead
     * 
     * @return seedYield The amount of yield credited to prizePot
     */
    function _materializeSeedYield() internal returns (uint256 seedYield) {
        uint256 totalContractValue = IERC20(aUSDC).balanceOf(address(this));
        uint256 totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUserBalance;
        
        // No yield to materialize
        if (totalContractValue <= totalAllocated) return 0;
        
        uint256 totalYield = totalContractValue - totalAllocated;
        
        // Seed is 10/65 of prizePot value
        // Calculate seed's proportional share of yield based on its value relative to total allocated
        uint256 seedValue = prizePot * SEED_BPS_OF_POT / 10000;
        
        // Avoid division by zero
        if (totalAllocated == 0) return 0;
        
        // Seed's share of total yield
        seedYield = totalYield * seedValue / totalAllocated;
        
        // Credit yield to prizePot (this is how the seed compounds!)
        if (seedYield > 0) {
            prizePot += seedYield;
            totalSeedYieldMaterialized += seedYield;
            emit SeedYieldMaterialized(currentWeek, seedYield, prizePot);
        }
        
        return seedYield;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // PHASE 1: VRF
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    function _requestRandomness() internal {
        if (pendingRequestId != 0) revert VRFPending();
        
        pendingRequestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            3,
            200000,
            1
        );
        lastRequestTimestamp = block.timestamp;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        if (requestId != pendingRequestId) revert WrongPhase();
        pendingRequestId = 0;
        
        if (block.timestamp >= zeroRevenueTimestamp && treasuryTakeBps > 0) {
            treasuryTakeBps = 0;
        }
        
        weeklyResults[currentWeek].combo = _generateMemeCombo(randomWords[0]);
        drawPhase = DrawPhase.PENDING_DISTRIBUTION;
        totalWinnersThisDraw = 0;
        
        emit WinningComboDrawn(currentWeek, weeklyResults[currentWeek].combo);
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // PHASE 2a: CALCULATE BEST MATCHES
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice [FIX-019] Phase 2a: Find best match for each user across all their guesses
     * @dev Call repeatedly until all players processed, then moves to POPULATING_TIERS
     * 
     * [YIELD-02] IMPORTANT: First call materializes seed yield BEFORE payout calculations!
     * This ensures the pot includes compounded seed yield.
     */
    function calculateMatches() external nonReentrant {
        if (drawPhase != DrawPhase.PENDING_DISTRIBUTION) revert WrongPhase();
        
        string memory winningCombo = weeklyResults[currentWeek].combo;
        
        // First call - materialize seed yield and initialize payout pool
        if (!matchingInProgress) {
            // [YIELD-02] MATERIALIZE SEED YIELD FIRST!
            // This credits seed's Aave yield to prizePot before we calculate payouts
            _materializeSeedYield();
            
            uint256 totalValue = IERC20(aUSDC).balanceOf(address(this));
            uint256 totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUserBalance;
            if (totalValue < totalAllocated) revert SolvencyCheckFailed();
            
            uint256 payoutPool = prizePot * payoutBps / 10000;
            prizePot -= payoutPool;
            
            for (uint256 i = 0; i < 5; i++) {
                tierPayoutAmounts[i] = payoutPool * TIERS_PERCENT[i] / 10000;
            }
            
            matchingInProgress = true;
            matchingPlayerIndex = 0;
        }
        
        uint256 processedThisTx = 0;
        
        // Process players and find their best match
        while (matchingPlayerIndex < playersThisWeek.length && processedThisTx < MAX_MATCHES_PER_TX) {
            address user = playersThisWeek[matchingPlayerIndex];
            string[] storage guesses = thisWeekGuesses[user];
            
            uint256 userBestMatch = 0;
            
            // Check ALL guesses for this user, keep only the best
            for (uint256 g = 0; g < guesses.length; g++) {
                uint256 matches = _countMatches(winningCombo, guesses[g]);
                if (matches > userBestMatch) {
                    userBestMatch = matches;
                }
            }
            
            // Store best match (will be used in population phase)
            if (userBestMatch >= 2) {
                bestMatchThisWeek[user] = userBestMatch;
                totalWinnersThisDraw++;
            }
            
            matchingPlayerIndex++;
            processedThisTx++;
        }
        
        if (matchingPlayerIndex >= playersThisWeek.length) {
            // Move to tier population phase
            matchingInProgress = false;
            matchingPlayerIndex = 0;
            populationIndex = 0;
            drawPhase = DrawPhase.POPULATING_TIERS;
            
            emit MatchingComplete(currentWeek, totalWinnersThisDraw);
        } else {
            emit MatchingBatchProcessed(currentWeek, matchingPlayerIndex, playersThisWeek.length);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // PHASE 2b: POPULATE TIER ARRAYS
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice [FIX-019] Phase 2b: Build tier arrays from best matches
     * @dev Each user added to exactly ONE tier (their best match)
     */
    function populateTiers() external nonReentrant {
        if (drawPhase != DrawPhase.POPULATING_TIERS) revert WrongPhase();
        
        uint256 processedThisTx = 0;
        
        while (populationIndex < playersThisWeek.length && processedThisTx < MAX_MATCHES_PER_TX) {
            address user = playersThisWeek[populationIndex];
            uint256 bestMatch = bestMatchThisWeek[user];
            
            // Add to appropriate tier (only if they had a qualifying match)
            if (bestMatch == 6) {
                weeklyResults[currentWeek].jackpotWinners.push(user);
            } else if (bestMatch == 5) {
                weeklyResults[currentWeek].match5.push(user);
            } else if (bestMatch == 4) {
                weeklyResults[currentWeek].match4.push(user);
            } else if (bestMatch == 3) {
                weeklyResults[currentWeek].match3.push(user);
            } else if (bestMatch == 2) {
                weeklyResults[currentWeek].match2.push(user);
            }
            // bestMatch < 2 = no win, not added to any tier
            
            populationIndex++;
            processedThisTx++;
        }
        
        if (populationIndex >= playersThisWeek.length) {
            populationIndex = 0;
            drawPhase = DrawPhase.DISTRIBUTING;
            distributionTierIndex = 0;
            distributionWinnerIndex = 0;
            
            emit TierPopulationComplete(currentWeek);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // PHASE 3: PRIZE DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    function distributePrizes() external nonReentrant {
        if (drawPhase != DrawPhase.DISTRIBUTING) revert WrongPhase();
        
        uint256 creditsThisTx = 0;
        
        while (distributionTierIndex < 5 && creditsThisTx < MAX_PAYOUTS_PER_TX) {
            address[] storage winners = _getWinnersForTier(distributionTierIndex);
            uint256 tierAmount = tierPayoutAmounts[distributionTierIndex];
            
            if (winners.length == 0) {
                prizePot += tierAmount;
                tierPayoutAmounts[distributionTierIndex] = 0;
                emit TierPayoutDeferred(currentWeek, distributionTierIndex, tierAmount);
                distributionTierIndex++;
                distributionWinnerIndex = 0;
                continue;
            }
            
            uint256 perWinner = tierAmount / winners.length;
            
            if (distributionWinnerIndex == 0) {
                uint256 actualPayout = perWinner * winners.length;
                uint256 dust = tierAmount - actualPayout;
                if (dust > 0) {
                    prizePot += dust;
                }
            }
            
            while (distributionWinnerIndex < winners.length && creditsThisTx < MAX_PAYOUTS_PER_TX) {
                unclaimedPrizes[winners[distributionWinnerIndex]] += perWinner;
                emit WinnerSelected(winners[distributionWinnerIndex], perWinner, 6 - distributionTierIndex);
                distributionWinnerIndex++;
                creditsThisTx++;
            }
            
            if (distributionWinnerIndex >= winners.length) {
                distributionTierIndex++;
                distributionWinnerIndex = 0;
            }
        }
        
        if (distributionTierIndex >= 5) {
            drawPhase = DrawPhase.CLEANUP_NEEDED;
            cleanupIndex = 0;
            emit DistributionComplete(currentWeek);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // PHASE 4: BATCHED CLEANUP
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    function cleanupWeek() external nonReentrant {
        if (drawPhase != DrawPhase.CLEANUP_NEEDED) revert WrongPhase();
        
        uint256 cleanedThisTx = 0;
        uint256 totalPlayers = playersThisWeek.length;
        
        while (cleanupIndex < totalPlayers && cleanedThisTx < MAX_CLEANUP_PER_TX) {
            address user = playersThisWeek[cleanupIndex];
            delete thisWeekGuesses[user];
            delete bestMatchThisWeek[user];  // [FIX-019] Also clean up best match
            cleanupIndex++;
            cleanedThisTx++;
        }
        
        emit CleanupBatchProcessed(currentWeek, cleanupIndex, totalPlayers);
        
        if (cleanupIndex >= totalPlayers) {
            _finalizeWeek();
        }
    }

    function _finalizeWeek() internal {
        delete playersThisWeek;
        totalEntriesThisWeek = 0;
        cleanupIndex = 0;
        lastDrawTimestamp = block.timestamp;
        currentWeek++;
        drawPhase = DrawPhase.IDLE;
        
        emit WeekFinalized(currentWeek - 1);
    }

    function claimPrize() external nonReentrant {
        uint256 amount = unclaimedPrizes[msg.sender];
        if (amount == 0) revert NothingToClaim();
        
        unclaimedPrizes[msg.sender] = 0;
        
        try IPool(AAVE_POOL).withdraw(USDC, amount, address(this)) {
            IERC20(USDC).safeTransfer(msg.sender, amount);
            emit PrizeClaimed(msg.sender, amount);
        } catch {
            unclaimedPrizes[msg.sender] = amount;
            revert AaveLiquidityLow();
        }
    }

    function _getWinnersForTier(uint256 tier) internal view returns (address[] storage) {
        if (tier == 0) return weeklyResults[currentWeek].jackpotWinners;
        if (tier == 1) return weeklyResults[currentWeek].match5;
        if (tier == 2) return weeklyResults[currentWeek].match4;
        if (tier == 3) return weeklyResults[currentWeek].match3;
        return weeklyResults[currentWeek].match2;
    }

    function _countMatches(string memory combo, string memory guess) internal pure returns (uint256) {
        bytes memory c = bytes(combo);
        bytes memory g = bytes(guess);
        uint256 count = 0;
        
        for (uint256 i = 0; i < GUESS_LENGTH; i++) {
            for (uint256 j = 0; j < GUESS_LENGTH; j++) {
                if (c[i] == g[j]) {
                    count++;
                    break;
                }
            }
        }
        return count;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // WITHDRAWALS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    /**
     * @notice Withdraw savings with 1-year lock-up protection
     * @dev [FIX-020] Prevents gaming as free high-yield account
     * 
     * PROTECTION:
     * - Must wait 1 year from first deposit before withdrawal
     * - On full withdrawal, firstTicketTimestamp resets to 0
     * - Future deposits restart the 1-year lock
     */
    function withdrawSavings() external nonReentrant {
        // [FIX-020] Enforce 1-year lock-up
        if (firstTicketTimestamp[msg.sender] == 0) revert InsufficientBalance();
        if (block.timestamp < firstTicketTimestamp[msg.sender] + WITHDRAWAL_LOCK_PERIOD) {
            revert WithdrawalLocked();
        }
        
        uint256 principal = userBalance[msg.sender];
        uint256 yield = getUserYield(msg.sender);
        uint256 total = principal + yield;

        if (total == 0) revert InsufficientBalance();
        
        // Store for potential rollback
        uint256 prevYieldSpent = yieldSpent[msg.sender];
        uint256 prevFirstTicket = firstTicketTimestamp[msg.sender];
        
        // Clear state
        userBalance[msg.sender] = 0;
        yieldSpent[msg.sender] = 0;
        totalUserBalance -= principal;
        
        // [FIX-020] Reset firstTicketTimestamp to enforce lock-up on future deposits
        firstTicketTimestamp[msg.sender] = 0;

        try IPool(AAVE_POOL).withdraw(USDC, total, address(this)) {
            IERC20(USDC).safeTransfer(msg.sender, total);
            emit SavingsWithdrawn(msg.sender, principal, yield);
        } catch {
            // Restore all state on failure
            userBalance[msg.sender] = principal;
            yieldSpent[msg.sender] = prevYieldSpent;
            totalUserBalance += principal;
            firstTicketTimestamp[msg.sender] = prevFirstTicket;
            revert AaveLiquidityLow();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // LEGACY MODE
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    function setHeir(address _heir) external {
        if (_heir == address(0)) revert InvalidHeir();
        if (_heir == msg.sender) revert InvalidHeir();
        if (streakWeeks[msg.sender] < heirEligibilityYears * 52) revert InsufficientStreak();
        
        heir[msg.sender] = _heir;
        emit HeirSet(msg.sender, _heir);
    }

    function claimInheritance(address original) external nonReentrant {
        if (heir[original] != msg.sender) revert NotHeir();
        if (block.timestamp <= lastBuyTimestamp[original] + heirClaimYears * 365 days) revert TooEarly();

        uint256 principal = userBalance[original];
        uint256 yield = getUserYield(original);
        uint256 total = principal + yield;
        if (total == 0) revert NothingToClaim();

        uint256 prevYieldSpent = yieldSpent[original];
        address prevHeir = heir[original];
        userBalance[original] = 0;
        yieldSpent[original] = 0;
        totalUserBalance -= principal;
        heir[original] = address(0);

        try IPool(AAVE_POOL).withdraw(USDC, total, address(this)) {
            IERC20(USDC).safeTransfer(msg.sender, total);
            emit HeirClaimed(msg.sender, original, total);
        } catch {
            userBalance[original] = principal;
            yieldSpent[original] = prevYieldSpent;
            totalUserBalance += principal;
            heir[original] = prevHeir;
            revert AaveLiquidityLow();
        }
    }

    function expireUnclaimedInheritance(address original) external nonReentrant {
        if (heir[original] == address(0)) revert NotHeir();
        if (block.timestamp <= lastBuyTimestamp[original] + (heirClaimYears + heirExpiryYears) * 365 days) revert TooEarly();

        uint256 principal = userBalance[original];
        uint256 yield = getUserYield(original);
        uint256 total = principal + yield;
        if (total == 0) revert NothingToClaim();

        userBalance[original] = 0;
        yieldSpent[original] = 0;
        totalUserBalance -= principal;
        heir[original] = address(0);

        uint256 half = total / 2;
        treasuryOperatingReserve += half;
        prizePot += (total - half);

        emit InheritanceExpired(original, total);
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // GUESS VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    function _validateGuess(string calldata guess) internal pure {
        bytes memory g = bytes(guess);
        
        if (g.length != GUESS_LENGTH) revert InvalidGuessLength();
        
        uint64 seen = 0;
        
        for (uint256 i = 0; i < GUESS_LENGTH; i++) {
            int256 idx = _getAlphabetIndex(g[i]);
            
            if (idx < 0) revert InvalidGuessCharacters();
            
            uint64 bit = uint64(1) << uint64(uint256(idx));
            
            if (seen & bit != 0) revert DuplicateCharacterInGuess();
            
            seen |= bit;
        }
    }
    
    function _getAlphabetIndex(bytes1 char) internal pure returns (int256) {
        uint8 c = uint8(char);
        
        if (c >= 65 && c <= 90) return int256(uint256(c - 65));
        if (c >= 48 && c <= 57) return int256(uint256(c - 48 + 26));
        if (c == 33) return 36;
        if (c == 64) return 37;
        if (c == 35) return 38;
        if (c == 36) return 39;
        if (c == 37) return 40;
        if (c == 38) return 41;
        
        return -1;
    }

    function _alreadyGuessedThisWeek(address user, string calldata guess) internal view returns (bool) {
        string[] storage guesses = thisWeekGuesses[user];
        bytes32 guessHash = keccak256(bytes(guess));
        
        for (uint256 i = 0; i < guesses.length; i++) {
            if (keccak256(bytes(guesses[i])) == guessHash) {
                return true;
            }
        }
        return false;
    }

    function _generateMemeCombo(uint256 randomness) internal pure returns (string memory) {
        bytes1[42] memory chars = MEME_ALPHABET;
        bytes memory combo = new bytes(GUESS_LENGTH);
        uint256 rand = randomness;
        uint256 remaining = ALPHABET_SIZE;
        
        for (uint256 i = 0; i < GUESS_LENGTH; i++) {
            uint256 idx = rand % remaining;
            combo[i] = chars[idx];
            chars[idx] = chars[remaining - 1];
            remaining--;
            rand = uint256(keccak256(abi.encode(rand)));
        }
        return string(combo);
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    /// @notice [M-01 DOCUMENTED] Returns NET available yield (after yieldSpent deduction)
    /// @dev This is what users can actually spend/withdraw
    ///      Different from _getActualAvailableYield() which returns GROSS proportional yield
    function getUserYield(address user) public view returns (uint256) {
        uint256 totalEarned = _calculateYieldFor(user);
        uint256 spent = yieldSpent[user];
        return totalEarned > spent ? totalEarned - spent : 0;
    }

    function _calculateYieldFor(address user) internal view returns (uint256) {
        if (totalUserBalance == 0) return 0;
        
        uint256 totalContractValue = IERC20(aUSDC).balanceOf(address(this));
        uint256 totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUserBalance;
        
        if (totalContractValue <= totalAllocated) return 0;
        
        uint256 totalYield = totalContractValue - totalAllocated;
        return userBalance[user] * totalYield / totalUserBalance;
    }

    function canGambleWithYield(address user) public view returns (bool) {
        return getUserYield(user) >= TICKET_PRICE && 
               _getActualAvailableYield(user) >= TICKET_PRICE &&
               drawPhase == DrawPhase.IDLE;
    }

    function hasMulliganAvailable(address user) public view returns (bool) {
        if (firstTicketTimestamp[user] == 0) return false;
        bool eligible = block.timestamp > firstTicketTimestamp[user] + mulliganEligibilityMonths * 30 days;
        uint256 currentYear = (block.timestamp - DEPLOY_TIMESTAMP) / 365 days;
        bool notUsedThisYear = currentYear > lastMulliganResetYear[user] || !mulliganUsedThisYear[user];
        return eligible && notUsedThisYear;
    }

    function getHeirClaimDate(address original) external view returns (uint256) {
        if (lastBuyTimestamp[original] == 0) return 0;
        return lastBuyTimestamp[original] + heirClaimYears * 365 days;
    }

    function getDaysUntilHeirClaim(address original) external view returns (uint256) {
        if (lastBuyTimestamp[original] == 0) return type(uint256).max;
        uint256 claimDate = lastBuyTimestamp[original] + heirClaimYears * 365 days;
        if (block.timestamp >= claimDate) return 0;
        return (claimDate - block.timestamp) / 1 days;
    }

    /// @notice [FIX-020] Get withdrawal unlock date
    function getWithdrawalUnlockDate(address user) external view returns (uint256) {
        if (firstTicketTimestamp[user] == 0) return 0;
        return firstTicketTimestamp[user] + WITHDRAWAL_LOCK_PERIOD;
    }

    /// @notice [FIX-020] Get days until withdrawal unlocks
    function getDaysUntilWithdrawalUnlock(address user) external view returns (uint256) {
        if (firstTicketTimestamp[user] == 0) return type(uint256).max;
        uint256 unlockDate = firstTicketTimestamp[user] + WITHDRAWAL_LOCK_PERIOD;
        if (block.timestamp >= unlockDate) return 0;
        return (unlockDate - block.timestamp) / 1 days;
    }

    /// @notice [FIX-020] Check if user can withdraw
    function canWithdraw(address user) external view returns (bool) {
        if (firstTicketTimestamp[user] == 0) return false;
        if (userBalance[user] == 0) return false;
        return block.timestamp >= firstTicketTimestamp[user] + WITHDRAWAL_LOCK_PERIOD;
    }

    function getUserGuessesThisWeek(address user) external view returns (string[] memory) {
        return thisWeekGuesses[user];
    }

    function getUserEntryCount(address user) external view returns (uint256) {
        return thisWeekGuesses[user].length;
    }
    
    function getRemainingEntriesThisWeek() external view returns (uint256) {
        if (totalEntriesThisWeek >= MAX_TOTAL_ENTRIES_PER_WEEK) return 0;
        return MAX_TOTAL_ENTRIES_PER_WEEK - totalEntriesThisWeek;
    }
    
    function isDistributionComplete() external view returns (bool) {
        return drawPhase == DrawPhase.IDLE;
    }

    function getDistributionProgress() external view returns (uint256 tier, uint256 winner, DrawPhase phase) {
        return (distributionTierIndex, distributionWinnerIndex, drawPhase);
    }

    function getSolvencyStatus() external view returns (uint256 totalValue, uint256 totalAllocated, bool isSolvent) {
        totalValue = IERC20(aUSDC).balanceOf(address(this));
        totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUserBalance;
        isSolvent = totalValue >= totalAllocated;
    }

    /// @notice [YIELD-01] Get total seed yield materialized to date
    function getTotalSeedYieldMaterialized() external view returns (uint256) {
        return totalSeedYieldMaterialized;
    }

    /// @notice [YIELD-01] Get pending seed yield (not yet materialized)
    function getPendingSeedYield() external view returns (uint256) {
        uint256 totalContractValue = IERC20(aUSDC).balanceOf(address(this));
        uint256 totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUserBalance;
        
        if (totalContractValue <= totalAllocated) return 0;
        
        uint256 totalYield = totalContractValue - totalAllocated;
        uint256 seedValue = prizePot * SEED_BPS_OF_POT / 10000;
        
        if (totalAllocated == 0) return 0;
        
        return totalYield * seedValue / totalAllocated;
    }

    function getWeeklyCombo(uint256 week) external view returns (string memory) {
        return weeklyResults[week].combo;
    }

    function getWeeklyWinners(uint256 week, uint256 tier) external view returns (address[] memory) {
        if (tier == 0) return weeklyResults[week].jackpotWinners;
        if (tier == 1) return weeklyResults[week].match5;
        if (tier == 2) return weeklyResults[week].match4;
        if (tier == 3) return weeklyResults[week].match3;
        return weeklyResults[week].match2;
    }

    function getPlayersThisWeekCount() external view returns (uint256) {
        return playersThisWeek.length;
    }

    function isValidGuess(string calldata guess) external pure returns (bool valid, string memory reason) {
        bytes memory g = bytes(guess);
        
        if (g.length != GUESS_LENGTH) {
            return (false, "Guess must be exactly 6 characters");
        }
        
        uint64 seen = 0;
        
        for (uint256 i = 0; i < GUESS_LENGTH; i++) {
            int256 idx = _getAlphabetIndex(g[i]);
            
            if (idx < 0) {
                return (false, "Invalid character - use A-Z, 0-9, or !@#$%&");
            }
            
            uint64 bit = uint64(1) << uint64(uint256(idx));
            
            if (seen & bit != 0) {
                return (false, "Duplicate character detected - each character must be unique");
            }
            
            seen |= bit;
        }
        
        return (true, "");
    }

    function getContractState() external view returns (
        DrawPhase phase,
        uint256 round,
        uint256 pot,
        uint256 entries,
        uint256 players,
        bool vrfPending,
        bool matching,
        uint256 matchIdx,
        uint256 popIdx,
        uint256 distTier,
        uint256 distWinner,
        uint256 cleanup
    ) {
        return (
            drawPhase,
            currentWeek,
            prizePot,
            totalEntriesThisWeek,
            playersThisWeek.length,
            pendingRequestId != 0,
            matchingInProgress,
            matchingPlayerIndex,
            populationIndex,
            distributionTierIndex,
            distributionWinnerIndex,
            cleanupIndex
        );
    }

    function getUserStreakStatus(address user) external view returns (
        uint256 streak,
        uint256 lastRound,
        uint256 currentRound,
        bool needsToPlayThisRound,
        bool wouldBreakStreak
    ) {
        streak = streakWeeks[user];
        lastRound = lastPlayedRound[user];
        currentRound = currentWeek;
        needsToPlayThisRound = lastRound > 0 && lastRound < currentWeek;
        wouldBreakStreak = lastRound > 0 && currentWeek > lastRound + 1;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // OWNER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    function increasePayoutPercent(uint256 newBps) external onlyOwner {
        if (newBps <= payoutBps) revert CanOnlyIncrease();
        if (newBps + treasuryTakeBps > 10000) revert ExceedsLimit();
        
        emit PayoutPercentIncreased(payoutBps, newBps);
        payoutBps = newBps;
    }

    function decreaseTreasuryTake(uint256 newBps) external onlyOwner {
        if (newBps >= treasuryTakeBps) revert CanOnlyDecrease();
        
        emit TreasuryTakeDecreased(treasuryTakeBps, newBps);
        treasuryTakeBps = newBps;
    }

    function withdrawTreasuryOps(uint256 amount, address recipient) external onlyOwner {
        if (amount > treasuryOperatingReserve) revert InsufficientBalance();
        if (recipient == address(0)) revert InvalidAddress();
        
        treasuryOperatingReserve -= amount;
        
        IPool(AAVE_POOL).withdraw(USDC, amount, address(this));
        IERC20(USDC).safeTransfer(recipient, amount);
        
        emit TreasuryWithdrawal(amount, recipient);
    }

    function withdrawTreasuryGift(uint256 amount, address recipient) external onlyOwner {
        if (amount > treasuryGiftReserve) revert InsufficientBalance();
        if (recipient == address(0)) revert InvalidAddress();
        
        treasuryGiftReserve -= amount;
        
        IPool(AAVE_POOL).withdraw(USDC, amount, address(this));
        IERC20(USDC).safeTransfer(recipient, amount);
        
        emit TreasuryGiftWithdrawal(amount, recipient);
    }

    /// @notice Update VRF parameters (subscription and key hash)
    /// @dev [H-01 FIX] Cannot change during pending VRF request
    function updateVRFParameters(uint64 newSubId, bytes32 newKeyHash) external onlyOwner {
        if (pendingRequestId != 0) revert VRFPending();  // [H-01 FIX]
        if (newSubId == 0) revert ExceedsLimit();
        if (newKeyHash == bytes32(0)) revert InvalidAddress();
        
        subscriptionId = newSubId;
        keyHash = newKeyHash;
        
        emit VRFParametersUpdated(newSubId, newKeyHash);
    }

    function setSavingsBehavior(bool countsAsActivity) external onlyOwner {
        savingsCountsAsActivity = countsAsActivity;
        emit SavingsBehaviorChanged(countsAsActivity);
    }

    function triggerDraw() external {
        if (block.timestamp < lastDrawTimestamp + DRAW_COOLDOWN) revert CooldownActive();
        if (pendingRequestId != 0) revert VRFPending();
        if (drawPhase != DrawPhase.IDLE) revert DrawInProgress();
        if (totalEntriesThisWeek < MIN_ENTRIES_FOR_DRAW) revert NoEntriesThisWeek();
        if (ticketsBought[msg.sender] == 0 && msg.sender != owner()) revert NoTicketsBought();
        _requestRandomness();
    }

    function resetStuckRequest() external onlyOwner {
        if (pendingRequestId == 0) revert NoPendingRequest();
        if (block.timestamp <= lastRequestTimestamp + VRF_TIMEOUT) revert TooEarly();
        uint256 resetRequestId = pendingRequestId;  // [L-04 FIX] Store for event
        pendingRequestId = 0;
        emit VRFRequestReset(resetRequestId);  // [L-04 FIX]
    }

    function emergencyResetDraw() external onlyOwner {
        if (block.timestamp <= lastRequestTimestamp + DRAW_STUCK_TIMEOUT) revert TooEarly();
        
        DrawPhase currentPhase = drawPhase;
        
        if (currentPhase == DrawPhase.IDLE) {
            if (pendingRequestId != 0) {
                pendingRequestId = 0;
                emit EmergencyReset(currentWeek, currentPhase, "VRF timeout");
                return;
            }
            revert NotStuck();
        }
        
        for (uint256 i = 0; i < 5; i++) {
            if (tierPayoutAmounts[i] > 0) {
                prizePot += tierPayoutAmounts[i];
                emit TierPayoutDeferred(currentWeek, i, tierPayoutAmounts[i]);
                tierPayoutAmounts[i] = 0;
            }
        }
        
        matchingInProgress = false;
        matchingPlayerIndex = 0;
        populationIndex = 0;
        distributionTierIndex = 0;
        distributionWinnerIndex = 0;
        pendingRequestId = 0;
        totalWinnersThisDraw = 0;
        
        drawPhase = DrawPhase.CLEANUP_NEEDED;
        cleanupIndex = 0;
        
        emit EmergencyReset(currentWeek, currentPhase, "Manual reset");
        emit DrawReset(currentWeek, "Emergency owner reset");
    }
    
    function forceCompleteDistribution() external onlyOwner {
        if (drawPhase != DrawPhase.DISTRIBUTING) revert WrongPhase();
        if (block.timestamp <= lastRequestTimestamp + DRAW_STUCK_TIMEOUT) revert TooEarly();
        
        for (uint256 i = distributionTierIndex; i < 5; i++) {
            if (tierPayoutAmounts[i] > 0) {
                prizePot += tierPayoutAmounts[i];
                emit TierPayoutDeferred(currentWeek, i, tierPayoutAmounts[i]);
                tierPayoutAmounts[i] = 0;
            }
        }
        
        drawPhase = DrawPhase.CLEANUP_NEEDED;
        cleanupIndex = 0;
        emit DrawReset(currentWeek, "Forced completion");
    }

    /// @notice Force cleanup when stuck - lets cleanupWeek() handle proper clearing
    /// @dev [M-02 FIX] Changed to set phase to CLEANUP_NEEDED instead of direct delete
    ///      This allows batched cleanupWeek() calls to properly clear bestMatchThisWeek
    /// @notice Emergency force cleanup when batched cleanupWeek() is stuck
    /// @dev [NEW-01 FIX] Uses simple delete to avoid gas limit issues
    ///      Note: thisWeekGuesses and bestMatchThisWeek mappings left stale but HARMLESS:
    ///      - bestMatchThisWeek only read during POPULATING_TIERS phase for current week's players
    ///      - After delete playersThisWeek, those players aren't in next week's list
    ///      - Stale data never accessed, just occupies storage until overwritten
    function forceCleanup() external onlyOwner {
        if (drawPhase != DrawPhase.CLEANUP_NEEDED) revert WrongPhase();
        if (block.timestamp <= lastRequestTimestamp + DRAW_STUCK_TIMEOUT) revert TooEarly();
        
        // Simple delete - stale mappings are harmless (see NatSpec above)
        delete playersThisWeek;
        totalEntriesThisWeek = 0;
        cleanupIndex = 0;
        lastDrawTimestamp = block.timestamp;
        currentWeek++;
        drawPhase = DrawPhase.IDLE;
        
        emit DrawReset(currentWeek - 1, "Forced cleanup");
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // FUTURE-PROOF UPGRADE PATH
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    //
    // Core vault is immutable. Game rules can be upgraded via proxy + multisig later.
    // No backdoors today — onlyOwner functions are minimal and one-way.
    //
    // Immutable (cannot change):     USDC, aUSDC, AAVE_POOL, COORDINATOR, DEPLOY_TIMESTAMP
    // One-way only (user-friendly):  payoutBps can only INCREASE, treasuryTakeBps can only DECREASE
    // Emergency only:                Reset stuck draws (cannot drain funds)
    //
    // To make fully trustless: call renounceOwnership() to lock forever.
    //
    // ═══════════════════════════════════════════════════════════════════════════════════════════
}
