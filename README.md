MicroFund Smart Contract

A Decentralized Micro-Financing Platform on Stacks

The **MicroFund Smart Contract** enables small-scale investors and fundraisers to collaborate through transparent, secure, and trustless funding pools built on the **Stacks blockchain**, anchored to Bitcoin.  
It is designed to support **micro-investments**, **community projects**, and **peer-to-peer funding** without intermediaries.

---

Features

- **Create Funding Pools** — Launch micro-fund campaigns with clear funding goals.  
- **Contributors Join Freely** — Allow investors to pool STX into decentralized funding pools.  
- **Conditional Withdrawals** — Only allow withdrawals when funding goals are achieved.  
- **On-Chain Transparency** — All fund activities and balances are publicly visible and auditable.  
- **Modular and Extendable** — Easy to integrate with DAO, NFT, or token reward mechanisms.

---

Smart Contract Overview

- **Contract Name:** `microfund.clar`  
- **Language:** [Clarity](https://docs.stacks.co/docs/write-smart-contracts/clarity-overview)  
- **Network:** [Stacks Blockchain](https://stacks.co) (secured by Bitcoin)  
- **Framework:** [Clarinet](https://github.com/hirosystems/clarinet)

---

Core Functions

| Function | Description |
|-----------|--------------|
| `create-fund (goal uint)` | Initialize a new funding pool with a target goal. |
| `contribute (fund-id uint) (amount uint)` | Allow contributors to fund a specific pool. |
| `withdraw (fund-id uint)` | Enables withdrawal of funds when the goal is met. |
| `get-fund (id uint)` | Retrieve details of a specific fund. |

---

Testing

You can test and simulate contract logic using **Clarinet**:

```bash
# Clone the repository
git clone https://github.com/<your-username>/microfund.git
cd microfund

# Run Clarinet tests
clarinet test

# Check contract syntax and semantics
clarinet check
