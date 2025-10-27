#!/bin/sh

KEY_1=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
KEY_2=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

RPC_URL=http://op-geth.test-1.svc.cluster.local:8545
# RPC_URL=http://op-rbuilder.test-2.svc.cluster.local:8545
# RPC_URL=http://tx-order-guarantor.test-3.svc.cluster.local:1545

echo "Running contender setup..."
contender setup -r $RPC_URL -p $KEY_1 --min-balance 10eth --op /data/scenarios/stress.toml & \
contender setup -r $RPC_URL -p $KEY_2 --min-balance 10eth --op /data/scenarios/uniV2.toml &
wait

echo "Running spam workload..."
yes | contender spam -r $RPC_URL -p $KEY_1 --tps 4 -d 600 -a 1 --min-balance 10eth --op /data/scenarios/stress.toml & \
yes | contender spam -r $RPC_URL -p $KEY_2 --tps 6 -d 600 -a 1 --min-balance 10eth --op /data/scenarios/uniV2.toml & \
wait
