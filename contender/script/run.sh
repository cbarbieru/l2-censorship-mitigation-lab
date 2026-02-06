#!/bin/sh

export KEY_1=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export KEY_2=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
export KEY_3=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
export KEY_4=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
export KEY_5=0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a
export KEY_6=0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba

export RPC_URL=http://op-geth.default:8545
# export RPC_URL=http://tx-order-guarantor.default:1545

# sudo rm -rf /tmp/builder-playground-opstack-k8s/contender/reports

echo "Running univ2..."
contender setup -r $RPC_URL -p $KEY_1 --op --min-balance 10eth /data/scenarios/uniV2.toml
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 30 -d $1 --min-balance 10eth --op /data/scenarios/uniV2.toml

contender setup -r $RPC_URL -p $KEY_2 --op --min-balance 10eth /data/scenarios/uniV2.toml
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 90 -d $1 --min-balance 10eth --op /data/scenarios/uniV2.toml

contender setup -r $RPC_URL -p $KEY_3 --op --min-balance 10eth /data/scenarios/uniV2.toml
yes | contender spam -r $RPC_URL -p $KEY_3 --tps 270 -d $1 --min-balance 10eth --op /data/scenarios/uniV2.toml


echo "Running erc20..."
yes | contender spam -r $RPC_URL -p $KEY_4 --tps 30 -d $1 --min-balance 10eth --op erc20
yes | contender spam -r $RPC_URL -p $KEY_5 --tps 90 -d $1 --min-balance 10eth --op erc20
yes | contender spam -r $RPC_URL -p $KEY_6 --tps 270 -d $1 --min-balance 10eth --op erc20

contender report -p 5
