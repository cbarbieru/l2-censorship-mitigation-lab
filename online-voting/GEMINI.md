# Online Voting System with Ethereum Integration

This project is a full-stack online voting application that ensures vote integrity using a **Commit-Reveal scheme** on an Ethereum-compatible blockchain. It consists of a Node.js/Express backend (`be/`) and a React/Vite frontend (`fe/`).

## Project Overview

- **Blockchain Layer**: Uses a Solidity smart contract (`Vote.sol`) deployed on an OP Stack-based playground. Votes are first "committed" (as a hash of the candidate and a secret) and later "revealed" to be counted.
- **Backend**: An Express.js server that manages user authentication (JWT + Cookies), election data (MongoDB/Mongoose), and orchestrates blockchain interactions. It features a transaction parallelization strategy using a pool of 30 funded wallets to handle concurrent votes.
- **Frontend**: A modern React application built with Vite and Material UI (MUI), providing a dashboard for users to view elections, cast votes, and see results.

## Tech Stack

- **Frontend**: React, Vite, Material UI, ApexCharts, React Router, Axios.
- **Backend**: Node.js, Express, MongoDB (Mongoose), ethers.js, JWT, bcryptjs.
- **Blockchain**: Solidity, Hardhat, OpenZeppelin.
- **Infrastructure**: Docker support, Ethereum RPC (OP Stack).

## Getting Started

### Prerequisites

- Node.js > 20
- MongoDB instance
- Access to an Ethereum RPC node (or local Hardhat node)

### Backend (`be/`)

1.  **Install dependencies**:
    ```bash
    cd be
    npm install
    ```
2.  **Configuration**: Create a `.env` file in the `be/` directory based on the usage in `hardhat.config.js` and `ethVote.interactions.js`.
    - `PLAYGROUND_API_URL`: RPC URL for the blockchain.
    - `PRIVATE_KEY`: Main signer's private key.
    - `VOTECONTRACT_ADDRESS`: Address of the deployed `Vote.sol` contract.
    - `MONGODB_URI`: Connection string for MongoDB.
    - `COMMIT_REVEAL_SECRET`: Salt used for hashing votes.
3.  **Run Development Server**:
    ```bash
    npm run start-dev
    ```
4.  **Smart Contracts**:
    - Compile: `npx hardhat compile`
    - Deploy: `npm run deploy` (deploys to the 'playground' network)
    - Local Node: `npm run node`

### Frontend (`fe/`)

1.  **Install dependencies**:
    ```bash
    cd fe
    npm install
    ```
2.  **Run Development Server**:
    ```bash
    npm run dev
    ```
3.  **Build for Production**:
    ```bash
    npm run build
    ```
    The built files will be located in `fe/dist` and are served by the backend in production mode.

## Architecture & Key Components

- **Commit-Reveal Flow**: 
    1.  User votes -> Backend computes `keccak256(candidateId + salt)`.
    2.  `commit(userElHash, candidateHash)` is called on the smart contract.
    3.  Vote is recorded in MongoDB as "committed".
    4.  Admin triggers Reveal -> Backend calls `reveal(userElHash, candidateId, salt)` for all votes.
- **Parallel Wallet Pool**: `VoteInteraction.js` initializes 30 random wallets and funds them from the `mainSigner`. This allows the backend to send up to 30 transactions in parallel without hitting nonce issues or waiting for block confirmations sequentially.
- **Authentication**: Role-based access control (User, Admin, Moderator) implemented via `authJwt` middleware.

## Development Conventions

- **Surgical Updates**: When modifying the blockchain interaction layer, ensure the wallet pool logic remains intact.
- **Environment Variables**: Always check `be/.env` and `fe/` config before making changes to API endpoints or contract interactions.
- **Styling**: The frontend uses MUI (Material UI) with a custom theme located in `fe/src/theme/`.
- **API Routes**: Defined in `be/app/routes/`.
- **Database Models**: Defined in `be/app/models/`.
