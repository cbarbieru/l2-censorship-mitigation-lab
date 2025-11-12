#!/bin/bash

# Parameters
SERVICE_NAME="$1"  # e.g., op-geth
NAMESPACE="$3"     # e.g., test-1

if [[ -z "$SERVICE_NAME" || -z "$NAMESPACE" ]]; then
    echo "Usage: $0 <service-name> <namespace>"
    exit 1
fi

# Kill existing port-forward processes
sudo pkill -f "kubectl.*port-forward"

# Start port-forwards
sudo /usr/local/bin/k3s kubectl -n "$NAMESPACE" port-forward svc/"$SERVICE_NAME" 8545:8545 &
sudo /usr/local/bin/k3s kubectl -n "$NAMESPACE" port-forward svc/"$SERVICE_NAME" 9091:9090 &

echo "Port-forwarding started for $SERVICE_NAME in namespace $NAMESPACE (8545 and 9090)"
