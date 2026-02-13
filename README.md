# DYBL - Decentralised Yield Bearing Legacy

## The Eternal Seed -- A Self-Sustaining Compounding Primitive

### One Sentence

A percentage of every payment is retained forever. The pot floor only rises.

---

## The Problem

Traditional lotteries reset to zero after every jackpot. Start over. Wait months.

Subscription payments drain away. No compounding. No shared upside.

PoolTogether nearly died when yields dropped. No buffer. No floor.

## The Solution

The Eternal Seed.

$3 ticket: 65% to prize pot, 35% to treasury (ops + giveaways). 15.2% of every prize pot retained forever. Never paid out. Compounds via Aave. 84.8% maximum payout to winners. Enforced on-chain. The Seed cannot be emptied.

Jackpot won? Seed stays. Pot rebuilds from higher floor.

No winner? Rolls over. Seed grows.

User breaks streak? 50% of their yield feeds the pot.

Under normal conditions, the pot floor can only rise.

---

## The Primitive is the Product

Lettery is Example 1. A lottery where every ticket earns yield.

The Eternal Seed works anywhere recurring payments flow: lotteries, insurance, pensions, subscriptions, DAO treasuries. One mechanism, many applications.

| Application | Repo | Status |
|---|---|---|
| **Lettery** (lottery) | This repo | S1 audit-ready |
| **PPL** (yield protection) | [Protocol-Protection-Layer](https://github.com/DYBL777/Protocol-Protection-Layer) | V2.1 complete |
| **TES** (primitive spec) | [The-Eternal-Seed](https://github.com/DYBL777/The-Eternal-Seed) | 16 variants documented |
| **Lettery 26** (casual) | [DYBL-Lettery-26](https://github.com/DYBL777/DYBL-Lettery-26) | In development |
| **Lettery 33** (mid-tier) | [DYBL-Lettery-33](https://github.com/DYBL777/DYBL-Lettery-33) | In development |

---

## Flagship Demo: Lettery

A lottery where every ticket earns yield.

| Feature | Description |
|---|---|
| $3 ticket | Pick 6 characters from 42 (A-Z, 0-9, !@#$%&) |
| Weekly draw | Chainlink VRF V2.5 (provably fair) |
| 5 prize tiers | Match 2, 3, 4, or 5, or 6 to win |
| Jackpot rolls over | No winner? It grows |
| Yield-bearing | All deposits earn proportional Aave yield |
| Streak rewards | Consistency pays, inconsistency forfeits |
| Anniversary claims | Cash out yield during your annual window |
| Gamble with yield | Convert accrued yield into free tickets anytime |

Lettery is the proof of concept. The Eternal Seed is the primitive.

---

## Seasons

| Season | What Ships | Status |
|---|---|---|
| **Season 1** (Launch) | Core seed, yield, streaks, draws. Prove the mechanism. | Audit-ready |
| **Season 2** | Pavlov Toggle, Legacy Mode, Mulligan forgiveness | Designed |
| **Season 3** | Treasury injection, Community Week, CCIP cross-chain | Documented |
| **Season 4** | Chainlink Automation, dynamic treasury management | Research |

Each season is a new contract deployment. Old contracts remain immutable and functional. See [Season Roadmap](docs/LETTERY_SEASON_ROADMAP.md) for full details.

---

## Key Innovations

| Innovation | What It Does |
|---|---|
| Eternal Seed | 15.2% of prize pot retained forever. Pot floor only rises. Enforced on-chain (max payout 84.8%). |
| Proportional Yield | Each capital bucket earns its fair share. Time-weighted via globalYieldIndex. No sniping. |
| Streak Mechanics | Consistency rewarded. Broken streaks forfeit yield to pot and treasury. |
| One-Way Treasury | Treasury take can only decrease. Never increase. Enforced on-chain. |
| Anniversary Claims | Cash yield once per year. Gamble with yield anytime. |
| Pavlov Toggle (S2) | Weekly saver/gambler choice. Savers earn more than gamblers. |
| Legacy Mode (S2) | On-chain inheritance. Set an heir. Generational wealth transfer. |

---

## Infrastructure

| Role | Provider |
|---|---|
| Randomness | Chainlink VRF V2.5 |
| Yield Generation | Aave V3 |
| Automation (S2+) | Chainlink Automation |
| Cross-chain (S3+) | Chainlink CCIP |

---

## Contract

```
Lettery_S1.sol               -- Season 1 (audit-ready)

archive/
  Lettery_v1.6.6.sol         -- Development build (full S2-S4 feature preview)
  Lettery_v1.3.sol            -- Earlier version
  Lettery_AuditReady_v1.sol   -- Earlier audit attempt
  Lettery_AuditReady_v1.2.sol -- Earlier audit attempt
  Lettery_v1.sol              -- Original
```

---

## Deployed (Base Sepolia)

| Item | Value |
|---|---|
| Contract | 0xfBd7D074519ce29CffA11C2990cf2DFd020d14d4 |
| Verified | Basescan (Standard JSON Input) |
| Full draw cycle | Passing |
| Input validation | Passing |
| Solvency checks | Passing |

---

## Documentation

| Document | Description |
|---|---|
| [Litepaper](DYBL%20WHITEPAPER.md) | Full mechanism specification |
| [The Overflow](THE_OVERFLOW.md) | Expansion mechanism |
| [Black Swan](BLACK%20SWAN%20RESILIANCE%20PAPER.md) | Failure scenario planning |
| [Builder's Journey](DYBL_BUILDERS_JOURNEY.md) | How this was built |
| [Changelog](docs/CHANGELOG_BugFixes.md) | Bug fixes and version history |

---

## Tech Stack

- Solidity ^0.8.24
- Chainlink VRF V2.5 -- Provably fair randomness
- Aave V3 -- Yield generation
- OpenZeppelin -- ReentrancyGuard, SafeERC20, Ownable2Step
- Base (Coinbase L2) -- Ethereum rollup

---

## Risks

**Experimental DeFi. Not yet professionally audited.**

- Smart contract vulnerabilities
- Aave protocol dependency
- USDC stablecoin risk
- Chainlink VRF dependency

See Litepaper for full risk assessment. No false promises.

---

## Status

| Milestone | Status |
|---|---|
| Core contract | Complete |
| Season 1 contract (audit-ready) | Complete |
| AI code review (14 fixes applied) | Complete |
| Documentation | Complete |
| Base Sepolia deployment | Complete |
| Foundry test suite (S1) | In progress |
| Professional audit | Pending |
| Mainnet | Post-audit |

---

## Protection

- **License:** BUSL-1.1 (MIT after May 2029)
- **Patent:** US pending (Nov 2025) -- Eternal Seed, Pavlov Toggle, Legacy Mode, Lettery

---

## Contact

**DYBL Foundation**

- Email: dybl7@proton.me
- X: [@DYBL77](https://x.com/DYBL77)
- Farcaster: @dybl
- Discord: dybl777

---

*Not a fork. A new primitive. The Eternal Seed grows forever.*
