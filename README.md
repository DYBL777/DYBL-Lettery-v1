# DYBL - Decentralised Yield Bearing Legacy

## The Eternal Seed — A Self-Sustaining Compounding Primitive

### One Sentence

A percentage of every payment is retained forever. The pot floor only rises.

---

### The Problem

Traditional lotteries reset to zero after every jackpot. Start over. Wait months.

Subscription payments drain away. No compounding. No shared upside.

PoolTogether nearly died when yields dropped. No buffer. No floor.

### The Solution

**The Eternal Seed.**

$3 ticket: 65% to prize pot, 35% to treasury (ops + giveaways).
15.2% of every prize pot retained forever. Never paid out. Compounds via Aave.
84.8% maximum payout to winners. Enforced on-chain. The Seed cannot be emptied.

Jackpot won? Seed stays. Pot rebuilds from higher floor.

No winner? Rolls over. Seed grows.

User breaks streak? 50% of their yield feeds the pot.

Under normal conditions, the pot floor can only rise.

---

## Flagship Demo: Lettery

A lottery where every ticket earns yield.

| Feature | Description |
|---------|-------------|
| $3 ticket | Pick 6 characters from 42 (A-Z, 0-9, !@#$%&) |
| Weekly draw | Chainlink VRF V2.5 (provably fair) |
| 5 prize tiers | Match 2, 3, 4, 5, or 6 to win |
| Jackpot rolls over | No winner? It grows |
| Yield-bearing | All deposits earn proportional Aave yield |
| Streak rewards | Consistency pays, inconsistency forfeits |
| Anniversary claims | Cash out yield during your annual window |
| Gamble with yield | Convert accrued yield into free tickets anytime |

Lettery is the proof of concept. The Eternal Seed is the primitive.

---

## Seasons

| Season | What Ships | Status |
|--------|-----------|--------|
| Season 1 (Launch) | Lettery S1. Core seed, yield, streaks, draws. Prove the mechanism. | Audit-ready |
| Season 2 (~6 months) | Mulligan forgiveness, Pavlov yield toggle, Chainlink Automation | Designed |
| Season 3 (~18 months) | Legacy Mode (on-chain inheritance), CCIP cross-chain | Documented |

Each season is a new contract deployment. Old contracts remain immutable and functional.

---

## Key Innovations

| Innovation | What It Does |
|-----------|-------------|
| Eternal Seed | 15.2% of prize pot retained forever. Pot floor only rises. Enforced on-chain (max payout 84.8%). |
| Proportional Yield | Each capital bucket earns its fair share. Time-weighted. No sniping. |
| Streak Mechanics | Consistency rewarded. Broken streaks forfeit yield to pot and treasury. |
| One-Way Treasury | Treasury take can only decrease. Never increase. Enforced on-chain. |
| Anniversary Claims | Cash yield once per year. Gamble with yield anytime. |
| Pavlov Toggle (S2) | Savers earn more than gamblers |
| Legacy Mode (S3) | On-chain inheritance |

---

## Infrastructure

| Role | Provider |
|------|----------|
| Randomness | Chainlink VRF V2.5 |
| Yield Generation | Aave V3 |
| Automation (S2) | Chainlink Automation |
| Cross-chain (S3) | Chainlink CCIP |

---

## Documentation

| Document | Description |
|----------|-------------|
| [Whitepaper](docs/DYBL_WHITEPAPER.md) | Full mechanism specification (v1.6.6) |
| [Season 1 Spec](docs/Lettery_S1_Spec.md) | Audit-ready contract specification |
| [Builder's Journey](docs/Builders_Journey.md) | How this was built |
| [Known Issues](docs/Known_Issues.md) | Documented issues with proposed solutions |

---

## Contract

```
Lettery_S1.sol               — Season 1 (audit-ready, 838 code lines)

archive/
  Lettery_v1.6.6.sol         — Development build (full feature set)
```

---

## Deployed (Base Sepolia)

| Item | Value |
|------|-------|
| Contract | 0xfBd7D074519ce29CffA11C2990cf2DFd020d14d4 |
| Verified | Basescan (Standard JSON Input) |
| Full draw cycle | Passing |
| Input validation | Passing |
| Solvency checks | Passing |

---

## Tech Stack

- Solidity ^0.8.24
- Chainlink VRF V2.5 — Provably fair randomness
- Aave V3 — Yield generation
- OpenZeppelin — ReentrancyGuard, SafeERC20

---

## Risks

⚠️ **Experimental DeFi. Not yet professionally audited.**

- Smart contract vulnerabilities
- Aave protocol dependency
- USDC stablecoin risk
- Chainlink VRF dependency

See Whitepaper for full risk assessment.

---

## Status

| Milestone | Status |
|-----------|--------|
| Core contract | ✅ Complete |
| Season 1 contract (audit-ready) | ✅ Complete |
| AI code review | ✅ Complete (7 fixes applied) |
| Documentation | ✅ Complete |
| Base Sepolia deployment | ✅ Complete |
| Foundry test suite (S1) | 🔄 In progress |
| Professional audit | ⏳ Pending |
| Mainnet | ⏳ Post-audit |

---

## Protection

- **License:** BUSL-1.1 (MIT after May 2029)
- **Patent:** US pending (Nov 2025) — Eternal Seed, Pavlov Toggle, Legacy Mode, Lettery

---

## DYBL Repositories

| Repo | Description |
|------|-------------|
| **DYBL-Lettery-v1** | Flagship lottery (this repo) |
| **The-Eternal-Seed** | Primitive specification, 15 variants |
| **Protocol-Protection-Layer** | Insurance seed, v2.0 |

---

## Contact

**DYBL Foundation** 🌱

📧 [dybl7@proton.me](mailto:dybl7@proton.me)

🐦 [@DYBL77](https://x.com/DYBL77)

🟣 [@dybl](https://warpcast.com/dybl) (Farcaster)

---

*Not a fork. A new primitive. The Eternal Seed grows forever.*
