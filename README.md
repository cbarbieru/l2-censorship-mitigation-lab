# Install K3s
```bash
sudo /usr/local/bin/k3s-uninstall.sh
curl -sfL https://get.k3s.io | sh -
echo "alias k='sudo /usr/local/bin/k3s kubectl'" >> ~/.bashrc
source ~/.bashrc
```

# Install Kata
Use instruction from [here](https://github.com/kata-containers/kata-containers/blob/main/tools/packaging/kata-deploy/helm-chart/README.md) making sure to preliminary set [k8sDistribution: "k3s"](https://github.com/kata-containers/kata-containers/blob/main/tools/packaging/kata-deploy/helm-chart/kata-deploy/values.yaml#L7).
```bash
cd kata-containers/tools/packaging/kata-deploy/helm-chart/kata-deploy
sudo helm install kata-deploy . --kubeconfig /etc/rancher/k3s/k3s.yaml --namespace kube-system
```

# Install CC Operator
Operator introduces `enclave-cc` class runtime to allow running a container using more lightweight libOS over kata VM.
```bash
cd ~/
git clone https://github.com/cbarbieru/operator.git
k label node rosablanche-1 node.kubernetes.io/worker=
k apply -k operator/config/release
k apply -k operator/config/samples/ccruntime/default/
k apply -k operator/config/samples/enclave-cc/hw/
``` 

# Add devmapper plugin
Use instructions from [here](https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/how-to-use-kata-containers-with-firecracker.md#configure-devmapper), then edit `/opt/kata/containerd/config.d/kata-deploy.toml` to contain the below
<pre>
[plugins]
  [plugins.devmapper]
    pool_name = "devpool"
    root_path = "/var/lib/containerd/devmapper"
    base_image_size = "10GB"
    discard_blocks = true
# ...
[plugins."io.containerd.cri.v1.runtime".containerd.runtimes.kata-qemu-tdx]
runtime_type = "io.containerd.kata-qemu-tdx.v2"
runtime_path = "/opt/kata/bin/containerd-shim-kata-v2"
privileged_without_host_devices = true
pod_annotations = ["io.katacontainers.*"]
snapshotter = "devmapper"
</pre>
Restart k3s (containerd) with `sudo systemctl restart k3s`.

# K8 Deployment
```bash
cd ~/
git clone https://github.com/cbarbieru/builder-playground-opstack-k8s.git
cd builder-playground-opstack-k8s
sudo mkdir -p /mnt/sceal/storage
sudo cp -a storage/. /mnt/sceal/storage/
cd resources
k apply -f testing.yaml

# scenario 2
k create namespace test-2
k apply -f 00_opstack_rollup_boost.yaml -f 02_op-rbuilder_tdx.yaml -n test-2
k delete -f ...

# scenario 3
k create namespace test-3
k apply -f 00_opstack_rollup_boost.yaml -f 03_tx-order-guarantor_tdx.yaml -n test-3
k delete -f ...
```

# Contender
```bash
# on contender pod
k exec -it contender-78775dcc8f-5bnqx -- /bin/sh
cd /script
# scenario 2
./run.sh http://op-rbuilder.test-2.svc.cluster.local:8545 10 120 1 1
# scenario 3
./run.sh http://tx-order-guarantor.test-3.svc.cluster.local:1545 10 120 1 1

unset DEBUG_USEFILE
contender report

# extract to host
k cp contender-78775dcc8f-5bnqx:/root/.contender .contender -c contender

# extract to local
scp -r user@rosablanche-1.maas:~/.contender/ ~/Projects/SCEAL
```

# Misc
```bash
ssh -L 8545:localhost:8545 user@rosablanche-1.maas
k -n test-3 port-forward svc/op-geth 8545:8545
docker run -p 80:80 -e APP_NODE_URL="http://localhost:8545" alethio/ethereum-lite-explorer
```
