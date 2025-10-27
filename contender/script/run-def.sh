#!/bin/sh

KEY_1=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
KEY_2=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
KEY_3=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
KEY_4=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6

RPC_URL=http://op-geth.test-1.svc.cluster.local:8545
# RPC_URL=http://op-rbuilder.test-2.svc.cluster.local:8545
# RPC_URL=http://tx-order-guarantor.test-3.svc.cluster.local:1545

echo "Running spam workload..."
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 4 -d 600 -a 1 --min-balance 10eth --op stress & \
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 6 -d 600 -a 1 --min-balance 10eth --op uniV2 & \
yes | contender spam -r $RPC_URL -p $KEY_3 --tps 1 -d 600 -a 1 --min-balance 10eth --op erc20 & \
yes | contender spam -r $RPC_URL -p $KEY_4 --tps 1 -d 600 -a 1 --min-balance 10eth --op transfers & \
wait

