#!/bin/sh

export KEY_1=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

export RPC_URL=http://op-geth.default:8545

echo "Running erc20 with 30 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 30 -d $1 -a 50 --op erc20

echo "Running erc20 with 90 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 90 -d $1 -a 50 --op erc20

echo "Running erc20 with 270 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 270 -d $1 -a 50 --op erc20

contender report -p 2
