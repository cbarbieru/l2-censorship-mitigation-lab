sudo /usr/local/bin/k3s kubectl delete --ignore-not-found=true -f ../resources/testing.yaml 
sudo cp -a ../contender/. /mnt/sceal/contender/
sudo chmod +x /mnt/sceal/contender/script/run.sh
sleep 3
sudo /usr/local/bin/k3s kubectl apply -f ../resources/testing.yaml
sleep 3
echo "contender setup finished"

