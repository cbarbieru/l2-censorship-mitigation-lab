#!/bin/sh

# Deploy contract - this will update the local .env file
echo "Deploying contract to playground..."
npx hardhat run ./scripts/ContractDeploy.js --network playground

# Start the server
echo "Starting backend server..."
exec node server.js
