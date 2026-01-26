sudo k3s kubectl delete --ignore-not-found=true -f ../resources/testing.yaml -n testing
sudo cp -a ../contender/. /tmp/builder-playground-opstack-k8s/contender/
sudo chmod +x /tmp/builder-playground-opstack-k8s/contender/script/run.sh
sleep 3
sudo k3s kubectl apply -f ../resources/testing.yaml -n testing
sleep 3
echo "contender setup finished"

