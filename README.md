# DYBL - Decentralised Yield Bearing Legacy

**"The Eternal Seed"** — A Self-Sustaining Compounding Primitive

**Designed for Web2, with Web3 under the hood.**

---

## The Problem

Traditional lotteries reset to zero after every jackpot. Start over. 

Subscription payments drain away — no compounding, no shared upside.

## The Solution

**The Eternal Seed** — a percentage of every payment is retained forever.

Under normal operating conditions, the pot floor only rises.

---

## How The Eternal Seed Works

| Step | What Happens |
|------|--------------|
| 1. User buys ticket | 10% ($0.30 of $3) goes to Seed |
| 2. Seed stays in pot | NEVER paid out to winners |
| 3. Seed earns yield | Compounded weekly via Aave |
| 4. No jackpot winner? | Rolls over — Seed base grows |
| 5. User breaks streak? | 50% of their yield → pot |

**Result:** Pot floor can only rise (under normal conditions).

*Note: Not immune to smart contract risk, protocol exploits, or stablecoin depegs.*

---

## Flagship Demo: Lettery

A no-loss lottery with a meme twist.

- **$3 ticket** → Pick 6 characters from 42 (A-Z, 0-9, !@#$%&)
- **Weekly draw** → Chainlink VRF (provably fair)
- **5 prize tiers** → Match 2, 3, 4, 5, or 6 to win
- **Jackpot rolls over** → No winner? It grows.
- **Earn while you play** → All deposits earn Aave yield

---

## Key Features

- **Eternal Seed** — Pot floor only rises
- **Yield-bearing** — Users earn while they play
- **Pavlov Toggle (V2)** — Savers get more rewards than gamblers
- **Legacy Mode** — Set an heir, pass on your balance
- **1-Year Lock** — Prevents gaming as free yield account
- **Mulligan** — One free missed week per year

---

## Tech Stack

- **Solidity** ^0.8.24
- **Chainlink VRF** — Provably fair draws
- **Aave V3** — Yield generation
- **V2 Roadmap:** Truflation / Chainlink Automation

---

## Contract

📄 **Lettery_AuditReady_v1.3.sol** — Audit-ready

📄 **archive/** — Previous versions

---

## Documentation

📄 [Whitepaper](./DYBL%20WHITEPAPER.md) — Full mechanism details

📄 [Changelog](./docs/CHANGELOG_BugFixes.md)

---

## Risks

⚠️ **Experimental DeFi.** Not yet professionally audited.

- Smart contract vulnerabilities
- Aave protocol dependency
- USDC stablecoin risk
- Chainlink VRF dependency

**Status:** Audit-ready. Seeking review from Cyfrin / Chainlink ecosystem.

---

## License

**BUSL 1.1** → MIT after 10 May 2029

---

## Contact

**DYBL Foundation** 🇬🇧

📧 dybl7@proton.me

---

*Not a fork. A new DeFi primitive.*
