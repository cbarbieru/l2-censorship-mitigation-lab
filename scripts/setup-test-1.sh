sudo /usr/local/bin/k3s kubectl delete --ignore-not-found=true -f ../resources/01_opstack.yaml -n test-1 
sudo /usr/local/bin/k3s kubectl delete --ignore-not-found=true -f ../resources/01_opstack.yaml -f ../resources/rollup-boost.yaml -f ../resources/02_op-rbuilder_tdx.yaml -n test-2
sudo /usr/local/bin/k3s kubectl delete --ignore-not-found=true -f ../resources/01_opstack.yaml -f ../resources/rollup-boost.yaml -f ../resources/03_tx-order-guarantor_tdx.yaml -n test-3
sleep 3
sudo rm -rf /mnt/sceal/storage/
sudo cp -a ../storage/. /mnt/sceal/storage/
sudo /usr/local/bin/k3s kubectl apply -f ../resources/01_opstack.yaml -n test-1
sleep 3
echo "test-1 setup finished"