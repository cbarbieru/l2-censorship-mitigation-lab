#!/bin/bash

# First argument is the mode you want to run
MODE="$1"

# Delete existing resources
sudo k3s kubectl delete --ignore-not-found=true -f ../resources/

sleep 3

# Reset storage
sudo rm -rf /tmp/builder-playground-opstack-k8s/storage/
sudo cp -a ../storage/. /tmp/builder-playground-opstack-k8s/storage/

# Apply resources depending on the parameter
case "$MODE" in
    "1")
        sudo k3s kubectl apply -f ../resources/01_opstack.yaml
        ;;
    "2")
        sudo k3s kubectl apply -f ../resources/01_opstack.yaml -f ../resources/rollup-boost.yaml -f ../resources/02_op-rbuilder_tdx.yaml
        # sudo k3s kubectl apply -f ../resources/01_opstack.yaml -f ../resources/rollup-boost.yaml -f ../resources/02_op-geth_tdx.yaml
        ;;
    "3")
        sudo k3s kubectl apply -f ../resources/01_opstack.yaml -f ../resources/rollup-boost.yaml -f ../resources/03_tx-order-guarantor_tdx.yaml
        ;;
    *)
        echo "Unknown mode: $MODE. Please use 1, 2, or 3."
        exit 1
        ;;
esac

sleep 3
echo "test-$MODE setup finished"
