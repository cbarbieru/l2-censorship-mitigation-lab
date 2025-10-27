sudo /usr/local/bin/k3s kubectl delete --ignore-not-found=true -f ../resources/testing.yaml 
sudo cp -a ../contender/. /mnt/sceal/contender/
sudo chmod +x /mnt/sceal/contender/script/run-cus.sh
sudo chmod +x /mnt/sceal/contender/script/run-def.sh
sleep 1
sudo /usr/local/bin/k3s kubectl apply -f ../resources/testing.yaml
sleep 1
echo "contender setup finished"

