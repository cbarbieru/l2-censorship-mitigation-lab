#!/bin/sh

export KEY_1=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export KEY_2=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
# export KEY_3=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

export RPC_URL=http://op-geth-ext.default:8551

echo "Running erc20 with 30 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 30 -d $1 -a 10 --op erc20

# echo "Running erc20 with 90 TPS..."
# yes | contender spam -r $RPC_URL -p $KEY_2 --tps 90 -d $1 -a 20 --op erc20 

echo "Running erc20 with 270 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 270 -d $1 -a 30 --op erc20

contender report -p 1
