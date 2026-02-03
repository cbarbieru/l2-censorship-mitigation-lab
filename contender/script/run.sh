#!/bin/sh

export KEY_1=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export KEY_2=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

# export RPC_URL=http://op-geth-ext.default:8545
export RPC_URL=http://op-rbuilder.default:8545
# export RPC_URL=http://tx-order-guarantor.default:1545

sudo rm -rf /tmp/builder-playground-opstack-k8s/contender/reports

echo "Running univ2..."
contender setup -r $RPC_URL -p $KEY_1 --op --min-balance 10eth /data/scenarios/uniV2.toml
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 30 -d $1 --min-balance 10eth --op /data/scenarios/uniV2.toml
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 90 -d $1 --min-balance 10eth --op /data/scenarios/uniV2.toml
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 270 -d $1 --min-balance 10eth --op /data/scenarios/uniV2.toml

echo "Running erc20..."
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 30 -d $1 --min-balance 10eth --op erc20
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 90 -d $1 --min-balance 10eth --op erc20
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 270 -d $1 --min-balance 10eth --op erc20

