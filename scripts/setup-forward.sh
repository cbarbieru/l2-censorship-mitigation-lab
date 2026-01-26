#!/bin/bash

# Parameters
SERVICE_NAME="$1"  # e.g., op-geth

if [[ -z "$SERVICE_NAME" ]]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

# Kill existing port-forward processes
sudo pkill -f "kubectl.*port-forward"

# Start port-forwards
sudo k3s kubectl port-forward svc/"$SERVICE_NAME" 8545:8545 &
sudo k3s kubectl port-forward svc/"$SERVICE_NAME" 9091:9090 &

echo "Port-forwarding started for $SERVICE_NAME (8545 and 9090)"
