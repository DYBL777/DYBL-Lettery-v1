# DYBL Protocol - Decentralised Yield Bearing Legacy

> **V1 Audit-Ready** | Novel DeFi primitive for perpetual yield-generating payment flows

[![License: BUSL-1.1](https://img.shields.io/badge/License-BUSL--1.1-blue.svg)](https://github.com/DYBL-Foundation/DYBL-v1/blob/main/LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-e6e6e6?logo=solidity)](https://soliditylang.org/)
[![Chainlink](https://img.shields.io/badge/Chainlink-VRF%20%2B%20Automation-375BD2?logo=chainlink)](https://chain.link/)
[![Aave](https://img.shields.io/badge/Aave-V3-1C202F?logo=aave)](https://aave.com/)

---

## 🌟 What is DYBL?

DYBL (Decentralised Yield Bearing Legacy) is a **payment primitive** that transforms recurring payments into perpetual, yield-generating flows through the **Eternal Seed mechanism**.

### The Innovation: Eternal Seed

Unlike traditional systems where 100% of revenue is extracted, DYBL:
- **Routes 100% of payments into yield-bearing vaults** (Aave/Compound)
- **Retains a fixed percentage weekly** for perpetual compounding (45% retention)
- **Injects idle treasury liquidity** to accelerate early growth (rolling decreasing seed)
- **Creates self-sustaining growth** even at 0% external yield

**Result:** A positive-sum system where every payment grows shared value forever.

---

## 🎮 Lettery: Flagship Application

**Lettery** is a no-loss lottery demonstrating DYBL's potential:

- **$3 tickets** flow into Aave vault (USDC)
- **Weekly Chainlink VRF draws** from 42-character meme alphabet
- **55% of pot paid out** in tiered prizes (6/6, 5/6, 4/6, 3/6, 2/6 matches)
- **45% compounds forever** via Eternal Seed retention
- **Pavlovian toggle**: Savers get 100% yield, gamblers get 50%
- **Legacy Mode**: Set heir for generational wealth transfer after 10 years inactivity

### Key Differentiators

| Feature | Traditional Lottery | PoolTogether | DYBL Lettery |
|---------|-------------------|--------------|--------------|
| **Principal Risk** | Lost if you lose | Safe (yield-based) | Safe (yield-based) |
| **Pot Growth** | Fixed by ticket sales | Depends on yield | **Grows even at 0% yield** |
| **Sustainability** | Platform extracts value | Subsidies required | **Self-sustaining forever** |
| **Behavioral Incentives** | None | None | **Pavlovian toggle (100% vs 50% yield)** |
| **Generational Wealth** | None | None | **Legacy Mode (on-chain inheritance)** |

---

## 🏗️ Architecture
```
┌─────────────┐
│   Users     │
│ Buy Tickets │
└──────┬──────┘
       │ $3 USDC
       ▼
┌─────────────────────────────────────────┐
│         Lettery Smart Contract          │
│  ┌────────────────────────────────────┐ │
│  │   Revenue Split (~65% / ~35%)      │ │
│  └──────┬─────────────────────┬───────┘ │
│         │                     │          │
│    ┌────▼─────┐         ┌────▼────────┐ │
│    │Prize Pot │         │  Treasury   │ │
│    │ (to Aave)│         │  (to Aave)  │ │
│    └────┬─────┘         └─────┬───────┘ │
│         │                     │          │
│         │  Eternal Seed Injection        │
│         │◄────────────────────┘          │
│         │                                 │
│    ┌────▼─────────────────────────────┐  │
│    │  Aave V3 Vault (Earning Yield)   │  │
│    └──────────────┬───────────────────┘  │
│                   │                       │
│    ┌──────────────▼──────────────┐       │
│    │   Chainlink VRF (Weekly)    │       │
│    │  Random 6-char Meme Combo   │       │
│    └──────────────┬──────────────┘       │
│                   │                       │
│    ┌──────────────▼──────────────┐       │
│    │  Distribute 55% to Winners  │       │
│    │   Retain 45% (Compounds)    │       │
│    └─────────────────────────────┘       │
└─────────────────────────────────────────┘
```

### Smart Contract Components

- **Core Protocol**: `Lettery.sol` (1021 lines, fully NatSpec documented)
- **Yield Source**: Aave V3 Pool (USDC → aUSDC)
- **Randomness**: Chainlink VRF V2
- **Automation**: Manual trigger + future Chainlink Automation integration

---

## 🔐 Security Status

### Current Status: **Audit-Ready V1**

**This code is NOT production-ready.** It is prepared for professional security audit.

**Known Fixed Issues (from V0):**
- ✅ Cashback double-claim exploit (CRITICAL)
- ✅ Invalid character validation (HIGH)
- ✅ Match counting logic fix (HIGH)
- ✅ Yield calculation precision improvement (MEDIUM)
- ✅ Eternal Seed injection safety (MEDIUM)

**Next Steps:**
1. ✅ Code complete with full NatSpec documentation
2. 🔄 Comprehensive test suite (in progress)
3. 🔄 Testnet deployment (Base Sepolia)
4. ⏳ Professional security audit (Cyfrin/Chainlink - Q1 2026)
5. ⏳ Mainnet launch (Q2 2026 - post-audit only)

### Audit Scope

Seeking audit from:
- **Cyfrin** (code4rena, smart contract security specialists)
- **Chainlink Labs** (VRF integration, oracle security)
- **Aave Companies** (lending protocol integration)

**Estimated Audit Timeline:** 2-4 weeks  
**Estimated Cost:** $30K-$50K

---

## 🚀 Broader Applications

The DYBL primitive extends beyond lotteries to any recurring payment:

| Use Case | How DYBL Applies |
|----------|-----------------|
| **Insurance** | Premiums pool into vault, consistent payers get higher returns |
| **Pensions** | Contributions compound via Eternal Seed, guaranteed growth |
| **SaaS Subscriptions** | Netflix/Spotify users earn yield on subscription payments |
| **Utilities** | Monthly bills generate shared yield, reducing effective costs |
| **Remittances** | Cross-border payments earn yield for sender + receiver |
| **DAO Memberships** | Dues compound collectively, forfeits fund community initiatives |

**Market Opportunity:** $650B+ digital subscription economy + trillions in remittances/utilities

---

## 📦 Repository Structure
```
DYBL-v1/
├── contracts/
│   └── Lettery_AuditReady_v1.sol    # Main contract (audit-ready)
├── docs/
│   ├── CHANGELOG_BugFixes.md        # V0 → V1 bug fixes
│   ├── whitepaper.md                # Eternal Seed mechanism
│   └── architecture.md              # Technical deep-dive
├── test/
│   └── (coming soon)                # Foundry test suite
├── scripts/
│   └── (coming soon)                # Deployment scripts
├── README.md                        # This file
└── LICENSE                          # BUSL-1.1
```

---

## 🛠️ Development Setup

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js 16+ (for scripts)
- Git

### Installation
```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/DYBL-v1.git
cd DYBL-v1

# Install Foundry dependencies
forge install

# Run tests (when available)
forge test -vvv

# Deploy to testnet (when ready)
forge script scripts/Deploy.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast
```

---

## ⚠️ Important Disclaimers

### DO NOT DEPLOY TO MAINNET

This code is **audit-ready but NOT audited**. Deployment to mainnet before professional security review would be **extremely irresponsible**.

### Development Status

- ✅ Core mechanism implemented
- ✅ Full NatSpec documentation
- ✅ Known bugs fixed
- 🔄 Test suite in progress
- 🔄 Testnet deployment pending
- ⏳ Security audit pending
- ⏳ Mainnet launch TBD (post-audit only)

### License

BUSL-1.1 (Business Source License)
- Source code is publicly viewable
- Commercial use requires license until 2028
- After 2028, converts to GPL-3.0
- See [LICENSE](./LICENSE) for details

---

## 🤝 Contributing

**Current Phase:** Audit preparation - not accepting external contributions yet

**Future Phases:**
1. Post-audit: Bug reports welcome
2. Testnet phase: Community testing encouraged
3. Mainnet: Open to governance proposals (if implemented)

For security issues: Please email [security@dybl.foundation] (or your email)

---

## 📞 Contact & Community

- **Twitter/X:** [@DYBL777](https://twitter.com/DYBL777) (or your handle)
- **Discord:** Coming soon
- **Email:** contact@dybl.foundation (or your email)
- **Website:** Coming soon

**Founded by:** Independent creator/therapist with 8 years blockchain research  
**Collaborators:** Seeking Chainlink, Cyfrin, Aave partnerships

---

## 🎯 Roadmap

### Q1 2026 (Current)
- ✅ V1 audit-ready code complete
- 🔄 Comprehensive test suite
- 🔄 Interactive documentation/simulator
- 🔄 Testnet deployment (Base Sepolia)
- ⏳ Professional security audit (Cyfrin/Chainlink)

### Q2 2026
- ⏳ Audit completion + fixes
- ⏳ Mainnet deployment (Base/Ethereum)
- ⏳ Initial liquidity seeding
- ⏳ First weekly draw

### Q3-Q4 2026
- ⏳ Scale to other chains (Arbitrum, Optimism via CCIP)
- ⏳ Additional DYBL applications (insurance, pensions)
- ⏳ DAO formation (if governance needed)

---

## 📚 Resources

- **White Paper:** [Eternal Seed Mechanism](./docs/whitepaper.md)
- **Changelog:** [V0 → V1 Bug Fixes](./docs/CHANGELOG_BugFixes.md)
- **Architecture:** [Technical Deep-Dive](./docs/architecture.md)
- **Chainlink VRF:** [Documentation](https://docs.chain.link/vrf/v2/introduction)
- **Aave V3:** [Documentation](https://docs.aave.com/developers/getting-started/readme)

---

## 🌟 The Vision

**"What if every recurring payment earned you money?"**

DYBL reimagines payments as sources of shared, sustainable growth. By compounding retained inflows and recycling idle liquidity, it creates a future where every dollar works harder - for users, platforms, and society.

Lettery is just the beginning. The primitive works for insurance, pensions, SaaS, utilities, remittances - any recurring flow.

**As DeFi goes mainstream, the Eternal Seed could become a standard, unlocking trillions in untapped value.**

Let's build it. 🚀

---

**Status:** 🟡 Audit-Ready | 🔴 Not Production-Ready | ⏳ Seeking Professional Audit

**Last Updated:** January 1, 2026
```

---

## 📁 File Structure to Upload

1. **Lettery_AuditReady_v1.sol** → Put in `/contracts/` folder
2. **CHANGELOG_BugFixes.md** → Put in `/docs/` folder  
3. **whitepaper.md** → Your whitepaper → Put in `/docs/` folder
4. **README.md** → The one I just wrote above → Put in root

---

## 🎯 Next Steps (After You Upload):

**Step 1:** Create the folders
```
contracts/
docs/
test/
scripts/
