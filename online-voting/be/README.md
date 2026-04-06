# Online Voting - Backend

## Intro
The backend is a Node.js/Express application that serves as the orchestration layer for the online voting system. It manages user authentication (JWT), MongoDB data persistence (elections, candidates, and votes), and integrates with Ethereum-compatible blockchains (OP Stack) via ethers.js. It handles the secure commit-reveal voting process, ensuring each vote is cryptographically verifiable on-chain.

## Deploy
To build and push the Docker image for the backend with a Linux architecture:

```bash
# Build the image for linux/amd64
docker build --platform linux/amd64 -t <your-registry>/online-voting-be:latest .

# Push the image to your registry
docker push <your-registry>/online-voting-be:latest
```

## Usage

### Generating Users (Voters)
The project includes a script to generate a large number of users and their corresponding cryptographic hashes for testing or production seeding.

To generate users:
1. Ensure your MongoDB instance is running and configured in `app/config/db.config.js`.
2. Run the script:
   ```bash
   node scripts/CreateUsers.js
   ```
This script will:
- Create user accounts in MongoDB with random identities (names, emails, regions).
- Generate a `.csv` file with `userElectionHash` and `candidateHash` values.
- Automatically create an admin account with preset credentials.

### Parallel Wallet Pool (Avoiding Nonce Exceptions)
To handle high volumes of concurrent voting transactions without encountering "nonce already used" exceptions or transaction queuing delays, the backend employs a **Parallel Wallet Pool** strategy found in `app/controllers/ethVote.interactions.js`.

- **Mechanism**: On startup, the backend initializes a pool of **30 random wallets**.
- **Prefinancing**: Each wallet is automatically checked for a minimum balance (e.g., 0.1 ETH) and funded by the `mainSigner` (configured via `PRIVATE_KEY`) if needed.
- **Round-Robin Execution**: When a vote is cast, the backend selects a wallet from the pool in a round-robin fashion to sign and send the transaction. This ensures that transactions are spread across multiple source accounts, allowing for parallel block inclusion and preventing bottlenecking on a single account's nonce.
