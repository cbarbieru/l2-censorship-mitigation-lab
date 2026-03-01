#!/bin/sh

export KEY_1=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export KEY_2=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

export RPC_URL=http://rollup-boost.default:8551

echo "Running erc20 with 30 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 30 -d 600 -a 10 --op erc20

echo "Running erc20 with 210 TPS..."
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 210 -d 600 -a 30 --op erc20

contender report -p 1
