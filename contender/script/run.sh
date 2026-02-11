#!/bin/sh

export KEY_1=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
export KEY_2=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
export KEY_3=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6

export RPC_URL=http://op-geth.default:8545

echo "Running erc20 with 30 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 30 -d $1 -a 10 --op erc20

echo "Running erc20 with 90 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 90 -d $1 -a 20 --op erc20

echo "Running erc20 with 270 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_3 --tps 270 -d $1 -a 30 --op erc20

contender report -p 2
