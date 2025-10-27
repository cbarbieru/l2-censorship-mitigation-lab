sudo pkill -f "kubectl.*port-forward"
sudo /usr/local/bin/k3s kubectl -n test-1 port-forward svc/op-geth 8545:8545 & \
sudo /usr/local/bin/k3s kubectl -n test-1 port-forward svc/op-geth 6061:6061 &
