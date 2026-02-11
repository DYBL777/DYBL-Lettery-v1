// SPDX-License-Identifier: BUSL-1.1
// Licensed under the Business Source License 1.1
// Change Date: 10 May 2029
// On the Change Date, this code becomes available under MIT License.

pragma solidity ^0.8.24;

/**
 * @title DYBL - Decentralised Yield Bearing Legacy
 * @notice "The Eternal Seed" - A Self-Sustaining Capital Retention Mechanism
 * @author DYBL Foundation
 * @dev Lettery_S1.sol - Season 1: Core Eternal Seed Mechanism (42-Character Flagship)
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 * SEASON 1 - AUDIT-READY LAUNCH CONTRACT
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 *
 * WHAT THIS IS:
 *   Season 1 launch contract. Core Eternal Seed mechanism only.
 *   Proves the primitive works. Seasons 2 and 3 add features as separate deployments.
 *
 * DEFERRED TO LATER SEASONS (vs v1.6.6 development build):
 *   - Legacy Mode (setHeir, claimInheritance, expireUnclaimed) -> Season 3
 *   - Mulligan System (free missed week) -> Season 2
 *   - forceCleanup() -> edge case, handled by emergencyResetDraw
 *   - Auto-sunset timer (zeroRevenueTimestamp) -> treasury is one-way ratchet only
 *   - Constructor params: heirEligibilityYears, heirClaimYears, mulliganMonths, zeroRevenueYears
 *
 * WHAT WAS FIXED (vs v1.6.6):
 *   - [FIX-01] Solvency check now includes SOLVENCY_TOLERANCE (10000 units / 0.01 USDC)
 *              to handle Aave aUSDC micro-rounding (returns 2,999,999 for 3,000,000 supply)
 *   - [FIX-02] Constructor validation separated: payoutBps and treasuryTakeBps
 *              operate on different bases, no longer checked against each other
 *              payoutBps capped at 8480 (15.2% Eternal Seed minimum forever)
 *   - [FIX-07] Removed redundant per-ticket forceApprove. Constructor sets max
 *              approval once. Saves gas on every ticket purchase.
 *
 * CORE MECHANISM (UNCHANGED):
 *   - Proportional yield attribution (V1.6.6 globalYieldIndex)
 *   - Prize pot compounds (THE ETERNAL SEED)
 *   - Time-weighted fairness (no yield sniping)
 *   - Streak tracking with yield forfeit on break
 *   - Anniversary-only cash claims, anytime yield gambling
 *   - Chainlink VRF V2.5 provably fair draws
 *   - Aave V3 yield generation
 *
 * 42-CHARACTER LETTERY (FLAGSHIP):
 *   CHARACTER SET: A-Z (26) + 0-9 (10) + !@#$%& (6) = 42 characters
 *   PICK COUNT:    6 unique characters per ticket
 *   JACKPOT ODDS:  42C6 = 5,245,786 combinations (~1 in 5.2 million)
 *
 * REVENUE SPLIT (Per $3 Ticket):
 *   65% ($1.95) -> Prize Pot (ONE pot in Aave, seed is unpayable portion)
 *   35% ($1.05) -> Treasury
 *       ~20% ($0.60) -> Giveaway Reserve
 *       ~15% ($0.45) -> Operations
 *
 * ═══════════════════════════════════════════════════════════════════════════════════════════════
 */

// VRF V2.5 imports
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

contract Lettery is VRFConsumerBaseV2Plus, ReentrancyGuard {
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
    error TooEarly();
    error NothingToClaim();
    error WrongPhase();
    error AaveLiquidityLow();
    error SolvencyCheckFailed();
    error NoEntriesThisWeek();
    error CooldownActive();
    error VRFPending();
    error NoPendingRequest();
    error NotStuck();
    error CanOnlyIncrease();
    error CanOnlyDecrease();
    error ExceedsLimit();
    error NoTicketsBought();
    error NotAnniversary();

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // DRAW PHASES
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    enum DrawPhase {
        IDLE,
        PENDING_DISTRIBUTION,
        POPULATING_TIERS,
        DISTRIBUTING,
        CLEANUP_NEEDED
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // IMMUTABLE PARAMETERS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    address public immutable USDC;
    address public immutable aUSDC;
    address public immutable AAVE_POOL;
    uint256 public immutable DEPLOY_TIMESTAMP;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // UPDATEABLE VRF PARAMETERS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    uint256 public subscriptionId;
    bytes32 public keyHash;
    bool public useNativePayment;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // CONFIGURABLE PARAMETERS (ONE-WAY)
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    uint256 public payoutBps;
    uint256 public treasuryTakeBps;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // 42-CHARACTER MEME ALPHABET: A-Z + 0-9 + !@#$%&
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    bytes1[42] public MEME_ALPHABET = [
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
    uint256[5] public TIERS_PERCENT = [4000, 2500, 2000, 1000, 500];
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
    uint256 public constant ANNIVERSARY_WINDOW = 7 days;
    uint256 public constant YIELD_PRECISION = 1e18;
    uint256 public constant SOLVENCY_TOLERANCE = 10000;  // [FIX-01] Aave rounding buffer (10000 units = 0.01 USDC)

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // STATE VARIABLES
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    uint256 public prizePot;
    uint256 public treasuryOperatingReserve;
    uint256 public treasuryGiftReserve;
    uint256 public totalUserBalance;
    uint256 public totalUnclaimedPrizes;
    uint256 public currentWeek;
    uint256 public lastDrawTimestamp;
    uint256 public pendingRequestId;
    uint256 public lastRequestTimestamp;
    uint256 public totalEntriesThisWeek;
    
    // Epoch-based yield tracking
    uint256 public globalYieldIndex;
    uint256 public lastSnapshotAUSDC;
    
    DrawPhase public drawPhase;
    uint256 public distributionTierIndex;
    uint256 public distributionWinnerIndex;
    uint256[5] public tierPayoutAmounts;
    
    uint256 public matchingPlayerIndex;
    bool public matchingInProgress;
    uint256 public totalWinnersThisDraw;
    uint256 public cleanupIndex;
    uint256 public populationIndex;

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // USER MAPPINGS
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public ticketsBought;
    mapping(address => uint256) public streakWeeks;
    mapping(address => uint256) public firstTicketTimestamp;
    mapping(address => uint256) public lastPlayedRound;
    mapping(address => uint256) public lastBuyTimestamp;
    mapping(address => string[]) public thisWeekGuesses;
    mapping(address => uint256) public unclaimedPrizes;
    mapping(address => uint256) public bestMatchThisWeek;
    
    // Time-weighted yield tracking per user
    mapping(address => uint256) public userYieldIndex;
    mapping(address => uint256) public accumulatedYield;
    mapping(address => uint256) public yieldSpent;
    
    // Lifetime prize tracking
    mapping(address => uint256) public totalPrizesWon;

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
    event GambledWithYield(address indexed user, uint256 yieldUsed, string guess, uint256 indexed week);
    event WinningComboDrawn(uint256 indexed week, string combo);
    event WinnerSelected(address indexed winner, uint256 amount, uint256 matchLevel);
    event PrizeClaimed(address indexed winner, uint256 amount);
    event YieldClaimed(address indexed user, uint256 amount);
    event YieldSettled(address indexed user, uint256 earned, uint256 newTotal);
    event GlobalYieldIndexUpdated(uint256 indexed week, uint256 userYield, uint256 potYield, uint256 newIndex);
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
    event PayoutPercentIncreased(uint256 oldBps, uint256 newBps);
    event TreasuryTakeDecreased(uint256 oldBps, uint256 newBps);
    event TreasuryWithdrawal(uint256 amount, address recipient);
    event TreasuryGiftWithdrawal(uint256 amount, address recipient);
    event EmergencyReset(uint256 indexed week, DrawPhase fromPhase, string reason);
    event VRFParametersUpdated(uint256 newSubId, bytes32 newKeyHash);
    event YieldForfeited(address indexed user, uint256 amount, uint256 toTreasury, uint256 toPot);
    event VRFRequestReset(uint256 indexed requestId);
    event NativePaymentUpdated(bool useNative);

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR (8 parameters)
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    constructor(
        address _vrfCoordinator,
        uint256 _subId,
        bytes32 _keyHash,
        address _usdc,
        address _aavePool,
        address _aUSDC,
        uint256 _initialPayoutBps,
        uint256 _treasuryTakeBps
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        // Address validation
        if (_vrfCoordinator == address(0)) revert InvalidAddress();
        if (_usdc == address(0)) revert InvalidAddress();
        if (_aavePool == address(0)) revert InvalidAddress();
        if (_aUSDC == address(0)) revert InvalidAddress();
        
        // [FIX-02] Separate validation: these operate on different bases
        // payoutBps = % of prize pot paid to winners (applied to pot, not ticket)
        // Max 8480 = 84.8% payout, guarantees 15.2% Eternal Seed retention forever
        // treasuryTakeBps = % of ticket taken as treasury (applied to ticket price)
        if (_initialPayoutBps < 5000) revert ExceedsLimit();
        if (_initialPayoutBps > 8480) revert ExceedsLimit();
        if (_treasuryTakeBps > 5000) revert ExceedsLimit();
        
        // VRF validation
        if (_subId == 0) revert ExceedsLimit();
        if (_keyHash == bytes32(0)) revert InvalidAddress();
        
        // Set immutables
        USDC = _usdc;
        AAVE_POOL = _aavePool;
        aUSDC = _aUSDC;
        DEPLOY_TIMESTAMP = block.timestamp;

        // Set configurables
        subscriptionId = _subId;
        keyHash = _keyHash;
        payoutBps = _initialPayoutBps;
        treasuryTakeBps = _treasuryTakeBps;

        // Initialize state
        lastDrawTimestamp = block.timestamp;
        drawPhase = DrawPhase.IDLE;
        currentWeek = 1;
        useNativePayment = false;
        globalYieldIndex = 0;
        lastSnapshotAUSDC = 0;
        
        // Approve Aave to spend USDC
        IERC20(_usdc).approve(_aavePool, type(uint256).max);
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // EPOCH-BASED YIELD SYSTEM WITH PROPORTIONAL ATTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Update global yield index with proportional attribution
     * @dev Each bucket (pot, treasury ops, treasury gift, users) earns yield proportional to its size.
     *      This ensures the Eternal Seed compounds and users only get their fair share.
     */
    function _updateGlobalYieldIndex() internal {
        uint256 currentAUSDC = IERC20(aUSDC).balanceOf(address(this));
        
        if (lastSnapshotAUSDC == 0) {
            lastSnapshotAUSDC = currentAUSDC;
            return;
        }
        
        if (currentAUSDC <= lastSnapshotAUSDC) {
            lastSnapshotAUSDC = currentAUSDC;
            return;
        }
        
        uint256 totalYield = currentAUSDC - lastSnapshotAUSDC;
        uint256 totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUnclaimedPrizes + totalUserBalance;
        
        if (totalAllocated == 0) {
            lastSnapshotAUSDC = currentAUSDC;
            return;
        }
        
        // Each bucket earns yield proportional to its size
        uint256 potYield = totalYield * prizePot / totalAllocated;
        uint256 opsYield = totalYield * treasuryOperatingReserve / totalAllocated;
        uint256 giftYield = totalYield * treasuryGiftReserve / totalAllocated;
        uint256 userYield = totalYield * totalUserBalance / totalAllocated;
        
        // Pot compounds (THE ETERNAL SEED)
        prizePot += potYield;
        
        // Treasury compounds
        treasuryOperatingReserve += opsYield;
        treasuryGiftReserve += giftYield;
        
        // Users get their proportional share via index
        if (totalUserBalance > 0 && userYield > 0) {
            uint256 indexIncrease = userYield * YIELD_PRECISION / totalUserBalance;
            globalYieldIndex += indexIncrease;
            
            emit GlobalYieldIndexUpdated(currentWeek, userYield, potYield, globalYieldIndex);
        }
        
        lastSnapshotAUSDC = currentAUSDC;
    }

    /**
     * @notice Settle a user's yield up to current global index
     * @dev Must be called BEFORE any balance change (deposit, withdrawal, forfeit)
     */
    function _settleYield(address user) internal {
        if (userBalance[user] == 0) {
            userYieldIndex[user] = globalYieldIndex;
            return;
        }
        
        uint256 indexDelta = globalYieldIndex - userYieldIndex[user];
        if (indexDelta > 0) {
            uint256 earned = userBalance[user] * indexDelta / YIELD_PRECISION;
            accumulatedYield[user] += earned;
            
            emit YieldSettled(user, earned, accumulatedYield[user]);
        }
        
        userYieldIndex[user] = globalYieldIndex;
    }

    /**
     * @notice Get user's total available yield (accumulated + pending - spent)
     */
    function getUserYield(address user) public view returns (uint256) {
        uint256 accumulated = accumulatedYield[user];
        
        if (userBalance[user] > 0 && globalYieldIndex > userYieldIndex[user]) {
            uint256 indexDelta = globalYieldIndex - userYieldIndex[user];
            uint256 pending = userBalance[user] * indexDelta / YIELD_PRECISION;
            accumulated += pending;
        }
        
        uint256 spent = yieldSpent[user];
        return accumulated > spent ? accumulated - spent : 0;
    }

    /**
     * @notice Check if user is within their anniversary claim window
     */
    function isAnniversary(address user) public view returns (bool) {
        if (firstTicketTimestamp[user] == 0) return false;
        
        uint256 timeSinceFirst = block.timestamp - firstTicketTimestamp[user];
        uint256 yearsSinceFirst = timeSinceFirst / 365 days;
        
        if (yearsSinceFirst == 0) return false;
        
        uint256 anniversaryDate = firstTicketTimestamp[user] + (yearsSinceFirst * 365 days);
        uint256 windowStart = anniversaryDate > ANNIVERSARY_WINDOW ? anniversaryDate - ANNIVERSARY_WINDOW : 0;
        uint256 windowEnd = anniversaryDate + ANNIVERSARY_WINDOW;
        
        return block.timestamp >= windowStart && block.timestamp <= windowEnd;
    }

    /**
     * @notice Get user's next anniversary date
     */
    function getNextAnniversary(address user) public view returns (uint256) {
        if (firstTicketTimestamp[user] == 0) return 0;
        
        uint256 timeSinceFirst = block.timestamp - firstTicketTimestamp[user];
        uint256 yearsSinceFirst = timeSinceFirst / 365 days;
        
        return firstTicketTimestamp[user] + ((yearsSinceFirst + 1) * 365 days);
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

    /**
     * @notice Gamble using accrued yield. Only when yield >= TICKET_PRICE ($3)
     */
    function gambleWithYield(string calldata userGuess) external nonReentrant {
        if (drawPhase != DrawPhase.IDLE) revert DrawInProgress();
        _validateGuess(userGuess);
        if (_alreadyGuessedThisWeek(msg.sender, userGuess)) revert DuplicateGuessThisWeek();
        if (thisWeekGuesses[msg.sender].length >= MAX_GUESSES_PER_USER) revert MaxGuessesReached();
        if (totalEntriesThisWeek >= MAX_TOTAL_ENTRIES_PER_WEEK) revert WeekFull();
        
        _settleYield(msg.sender);
        
        uint256 availableYield = getUserYield(msg.sender);
        if (availableYield < TICKET_PRICE) revert InsufficientYield();
        
        _updateActivityTracking(msg.sender);
        
        yieldSpent[msg.sender] += TICKET_PRICE;
        prizePot += TICKET_PRICE;
        ticketsBought[msg.sender]++;
        
        _addGuessToWeek(msg.sender, userGuess);

        emit GambledWithYield(msg.sender, TICKET_PRICE, userGuess, currentWeek);
    }

    function _addGuessToWeek(address user, string calldata guess) internal {
        if (thisWeekGuesses[user].length == 0) {
            playersThisWeek.push(user);
        }
        thisWeekGuesses[user].push(guess);
        totalEntriesThisWeek++;
    }

    function _processTicketPurchase(address user) internal {
        _settleYield(user);
        
        // Note: USDC is assumed to be a standard ERC20 with no fee-on-transfer.
        // Constructor sets max approval for Aave Pool, no per-ticket approval needed.
        IERC20(USDC).safeTransferFrom(user, address(this), TICKET_PRICE);
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
    }

    function _updateActivityTracking(address user) internal {
        if (firstTicketTimestamp[user] == 0) {
            firstTicketTimestamp[user] = block.timestamp;
            userYieldIndex[user] = globalYieldIndex;
        }
        
        lastBuyTimestamp[user] = block.timestamp;

        uint256 userLastRound = lastPlayedRound[user];
        
        // First ever ticket
        if (userLastRound == 0) {
            streakWeeks[user] = 1;
            lastPlayedRound[user] = currentWeek;
            emit StreakUpdated(user, 1, currentWeek);
            return;
        }
        
        // Already played this week
        if (userLastRound == currentWeek) {
            return;
        }
        
        // Consecutive week (streak continues)
        if (currentWeek == userLastRound + 1) {
            streakWeeks[user]++;
            lastPlayedRound[user] = currentWeek;
            emit StreakUpdated(user, streakWeeks[user], currentWeek);
            return;
        }
        
        // Missed one or more weeks (streak breaks, yield forfeited)
        uint256 missedRounds = currentWeek - userLastRound - 1;
        uint256 forfeited = _forfeitYield(user);
        emit StreakBroken(user, forfeited, missedRounds);
        streakWeeks[user] = 1;
        lastPlayedRound[user] = currentWeek;
        emit StreakUpdated(user, 1, currentWeek);
    }

    /**
     * @notice Forfeit yield on broken streak. 50% to treasury, 50% to pot.
     */
    function _forfeitYield(address user) internal returns (uint256) {
        _settleYield(user);
        
        uint256 yield = getUserYield(user);
        if (yield == 0) return 0;

        yieldSpent[user] += yield;

        uint256 toTreasury = yield / 2;
        uint256 toPrizePot = yield - toTreasury;
        
        treasuryOperatingReserve += toTreasury;
        prizePot += toPrizePot;
        
        emit YieldForfeited(user, yield, toTreasury, toPrizePot);

        return yield;
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // PHASE 1: VRF REQUEST
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    function _requestRandomness() internal {
        if (pendingRequestId != 0) revert VRFPending();
        
        pendingRequestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: 3,
                callbackGasLimit: 200000,
                numWords: 1,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: useNativePayment})
                )
            })
        );
        lastRequestTimestamp = block.timestamp;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        if (requestId != pendingRequestId) revert WrongPhase();
        pendingRequestId = 0;
        
        weeklyResults[currentWeek].combo = _generateMemeCombo(randomWords[0]);
        drawPhase = DrawPhase.PENDING_DISTRIBUTION;
        totalWinnersThisDraw = 0;
        
        emit WinningComboDrawn(currentWeek, weeklyResults[currentWeek].combo);
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // PHASE 2a: CALCULATE BEST MATCHES
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    function calculateMatches() external nonReentrant {
        if (drawPhase != DrawPhase.PENDING_DISTRIBUTION) revert WrongPhase();
        
        string memory winningCombo = weeklyResults[currentWeek].combo;
        
        if (!matchingInProgress) {
            _updateGlobalYieldIndex();
            
            // [FIX-01] Solvency check with tolerance for Aave rounding
            uint256 totalValue = IERC20(aUSDC).balanceOf(address(this));
            uint256 totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUnclaimedPrizes;
            if (totalValue + SOLVENCY_TOLERANCE < totalAllocated) revert SolvencyCheckFailed();
            
            uint256 payoutPool = prizePot * payoutBps / 10000;
            prizePot -= payoutPool;
            
            for (uint256 i = 0; i < 5; i++) {
                tierPayoutAmounts[i] = payoutPool * TIERS_PERCENT[i] / 10000;
            }
            
            matchingInProgress = true;
            matchingPlayerIndex = 0;
        }
        
        uint256 processedThisTx = 0;
        
        while (matchingPlayerIndex < playersThisWeek.length && processedThisTx < MAX_MATCHES_PER_TX) {
            address user = playersThisWeek[matchingPlayerIndex];
            string[] storage guesses = thisWeekGuesses[user];
            
            uint256 userBestMatch = 0;
            
            for (uint256 g = 0; g < guesses.length; g++) {
                uint256 matches = _countMatches(winningCombo, guesses[g]);
                if (matches > userBestMatch) {
                    userBestMatch = matches;
                }
            }
            
            if (userBestMatch >= 2) {
                bestMatchThisWeek[user] = userBestMatch;
                totalWinnersThisDraw++;
            }
            
            matchingPlayerIndex++;
            processedThisTx++;
        }
        
        if (matchingPlayerIndex >= playersThisWeek.length) {
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

    function populateTiers() external nonReentrant {
        if (drawPhase != DrawPhase.POPULATING_TIERS) revert WrongPhase();
        
        uint256 processedThisTx = 0;
        
        while (populationIndex < playersThisWeek.length && processedThisTx < MAX_MATCHES_PER_TX) {
            address user = playersThisWeek[populationIndex];
            uint256 bestMatch = bestMatchThisWeek[user];
            
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
                totalUnclaimedPrizes += perWinner;
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
            delete bestMatchThisWeek[user];
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

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // PRIZE CLAIMS
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    function claimPrize() external nonReentrant {
        uint256 amount = unclaimedPrizes[msg.sender];
        if (amount == 0) revert NothingToClaim();
        
        unclaimedPrizes[msg.sender] = 0;
        totalUnclaimedPrizes -= amount;
        
        try IPool(AAVE_POOL).withdraw(USDC, amount, address(this)) {
            IERC20(USDC).safeTransfer(msg.sender, amount);
            totalPrizesWon[msg.sender] += amount;
            emit PrizeClaimed(msg.sender, amount);
        } catch {
            unclaimedPrizes[msg.sender] = amount;
            totalUnclaimedPrizes += amount;
            revert AaveLiquidityLow();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // YIELD CLAIMS
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    /**
     * @notice Claim yield as USDC. Only on anniversary (7-day window around yearly date).
     */
    function claimYieldAsCash() external nonReentrant {
        if (!isAnniversary(msg.sender)) revert NotAnniversary();
        
        _settleYield(msg.sender);
        
        uint256 yield = getUserYield(msg.sender);
        if (yield == 0) revert NothingToClaim();
        
        yieldSpent[msg.sender] += yield;
        
        try IPool(AAVE_POOL).withdraw(USDC, yield, address(this)) {
            IERC20(USDC).safeTransfer(msg.sender, yield);
            emit YieldClaimed(msg.sender, yield);
        } catch {
            yieldSpent[msg.sender] -= yield;
            revert AaveLiquidityLow();
        }
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
        
        if (c >= 65 && c <= 90) return int256(uint256(c - 65));       // A-Z (indices 0-25)
        if (c >= 48 && c <= 57) return int256(uint256(c - 48 + 26));  // 0-9 (indices 26-35)
        if (c == 33) return 36;   // !
        if (c == 64) return 37;   // @
        if (c == 35) return 38;   // #
        if (c == 36) return 39;   // $
        if (c == 37) return 40;   // %
        if (c == 38) return 41;   // &
        
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

    function _generateMemeCombo(uint256 randomness) internal view returns (string memory) {
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
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════════════════════

    function canGambleWithYield(address user) public view returns (bool) {
        return getUserYield(user) >= TICKET_PRICE && drawPhase == DrawPhase.IDLE;
    }

    function canClaimYield(address user) public view returns (bool) {
        return getUserYield(user) > 0 && isAnniversary(user);
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
        totalAllocated = prizePot + treasuryOperatingReserve + treasuryGiftReserve + totalUnclaimedPrizes;
        isSolvent = totalValue + SOLVENCY_TOLERANCE >= totalAllocated;
    }

    function getSeedValue() external view returns (uint256) {
        return prizePot * (10000 - payoutBps) / 10000;
    }

    function getMaxPayout() external view returns (uint256) {
        return prizePot * payoutBps / 10000;
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

    function getUserYieldStatus(address user) external view returns (
        uint256 availableYield,
        uint256 accumulated,
        uint256 spent,
        uint256 userIndex,
        uint256 globalIndex,
        bool canGamble,
        bool canClaim,
        uint256 nextAnniversary
    ) {
        availableYield = getUserYield(user);
        accumulated = accumulatedYield[user];
        spent = yieldSpent[user];
        userIndex = userYieldIndex[user];
        globalIndex = globalYieldIndex;
        canGamble = canGambleWithYield(user);
        canClaim = canClaimYield(user);
        nextAnniversary = getNextAnniversary(user);
    }

    // ═══════════════════════════════════════════════════════════════════════════════════════════
    // OWNER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════════════════════
    
    function increasePayoutPercent(uint256 newBps) external onlyOwner {
        if (newBps <= payoutBps) revert CanOnlyIncrease();
        if (newBps > 8480) revert ExceedsLimit();  // 15.2% Eternal Seed minimum
        
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

    function updateVRFParameters(uint256 newSubId, bytes32 newKeyHash) external onlyOwner {
        if (pendingRequestId != 0) revert VRFPending();
        if (newSubId == 0) revert ExceedsLimit();
        if (newKeyHash == bytes32(0)) revert InvalidAddress();
        
        subscriptionId = newSubId;
        keyHash = newKeyHash;
        
        emit VRFParametersUpdated(newSubId, newKeyHash);
    }

    function setNativePayment(bool _useNative) external onlyOwner {
        useNativePayment = _useNative;
        emit NativePaymentUpdated(_useNative);
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
        uint256 resetRequestId = pendingRequestId;
        pendingRequestId = 0;
        emit VRFRequestReset(resetRequestId);
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
        
        // Return undistributed tier payouts to pot
        for (uint256 i = 0; i < 5; i++) {
            if (tierPayoutAmounts[i] > 0) {
                prizePot += tierPayoutAmounts[i];
                emit TierPayoutDeferred(currentWeek, i, tierPayoutAmounts[i]);
                tierPayoutAmounts[i] = 0;
            }
        }
        
        // Reset all draw state
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
}
