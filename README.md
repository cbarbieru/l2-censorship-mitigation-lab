# L2 Censorship Mitigation Lab (L2CML)

This repository provides a comprehensive environment for deploying, orchestrating, and testing Ethereum L2 (Optimism-based) stacks with a focus on exploring different architectural solutions for censorship resistance and decentralization.

## Table of Contents
1. [Repository Overview](#1-repository-overview)
   - 1.1 [L2 Optimism Test Bed](#11-l2-optimism-test-bed)
   - 1.2 [Key Components](#12-key-components)
2. [Research Aim & Objectives](#2-research-aim--objectives)
3. [Deployment & Usage Instructions](#3-deployment--usage-instructions)
   - 3.1 [VM and Cluster Setup](#31-vm-and-cluster-setup-2-node-k3s)
   - 3.2 [Kubernetes Resource Deployment](#32-kubernetes-resource-deployment)
   - 3.3 [Port Forwarding](#33-port-forwarding)
   - 3.4 [Block Explorer](#34-block-explorer)
   - 3.5 [Running Tests & Load Injection](#35-running-tests--load-injection)
4. [Credits](#4-credits)

---

## 1. Repository Overview

The project is structured to support a complete research and development lifecycle for L2 infrastructure.

### 1.1 L2 Optimism Test Bed
The core of this repository is an L2 Optimism-compatible test bed, originally based on `builder-playground` and adapted for Kubernetes deployment using Kompose. It supports three distinct deployment variants orchestrated via K8s resources:

1.  **Monolithic Sequencer:** A standard Optimism setup where the sequencer handles block production and ordering.
2.  **PBS (Proposer-Builder Separation):** A variant facilitated by Flashbots' `rollup-boost`, allowing the use of an external builder to decouple block proposal from block construction.
3.  **PBS + Tx-Order-Guarantor:** An advanced configuration introducing a TEE-ready component to guarantee transaction ordering and inclusion, providing a verifiable commitment to the transaction stream.

### 1.2 Key Components
- **`resources/`**: Contains Kubernetes manifests for the L2 stack, including specialized configurations for `rollup-boost`, `op-rbuilder`, and `tx-order-guarantor`. It also includes setups for monitoring (Grafana/Prometheus).
- **`scripts/`**: Automation scripts for deploying the stack (`setup-stack.sh`), managing port-forwards (`setup-forward.sh`), and initializing testing environments.
- **`storage/`**: Contains the initial state (genesis files, jwt secrets) required to bootstrap the L2 network.
- **`online-voting/`**: A full-stack decentralized application (DApp) used as a real-world use case.
    - **Frontend (FE)**: React/Vite application with Material UI.
    - **Backend (BE)**: Express.js server using Hardhat for contract interaction and MongoDB for metadata storage.
    - **Features**: Includes scripts for massive user generation and a "parallel wallet pool" strategy to prefund multiple source accounts, preventing nonce collisions during high-load simulations.
- **`tx-order-guarantor`**: A specialized component that interposes in the transaction stream. It simulates block ordering logic (matching `op-rbuilder`) and exposes the ordering to the builder, ensuring that the final block includes a verifiable order commitment.
- **`testing/`**: Centralized location for test scenarios and load injection scripts.
- **Submodules**: Links to forked and modified versions of `op-rbuilder` and `contender` to support research-specific amendments.

---

## 2. Research Aim & Objectives

The primary goal of this project is to identify, implement, and evaluate different architectural tradeoffs for **preventing censorship** and enhancing **censorship resistance** in L2 networks.

### Investigated Solutions & Tradeoffs:
- **TEEs for Censorship Resistance:** Running the entire sequencer or builder within a Trusted Execution Environment (e.g., Intel TDX) to ensure integrity and prevent arbitrary transaction exclusion.
- **PBS for Decentralization:** Using Proposer-Builder Separation to diminish the centralization of power in a single sequencer node.
- **Tx-Order-Guarantor in TEE:** A "Smaller TCB" (Trusted Computing Base) approach where only the ordering logic runs in a TEE, providing censorship resilience without the overhead of running the full execution engine in a TEE.

---

## 3. Deployment & Usage Instructions

### 3.1 VM and Cluster Setup (2-Node K3S)
This guide details the steps to deploy a cluster consisting of an Ubuntu Master and a TDX Worker.

#### 3.1.1 Master Node Setup (Ubuntu 24.04 VM)

**Host Preparation & VM Creation**
Perform these steps on your host machine to provision the Master VM.

1.  **Prepare Workspace and Image**
    ```bash
    mkdir ~/guest-master
    cd ~/guest-master
    wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
    qemu-img resize noble-server-cloudimg-amd64.img 50G
    ```

2.  **Generate Cloud-Init Configuration**
    ```bash
    sudo apt update && sudo apt install cloud-image-utils -y
    
    cat <<EOF > user-data
    #cloud-config
    hostname: master
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: false
        passwd: password 
    ssh_pwauth: true
    chpasswd:
      list: |
        ubuntu:secretpassword
      expire: False
    EOF
    
    cloud-localds my-seed.iso user-data
    ```

3.  **Install the VM**
    ```bash
    sudo chown libvirt-qemu:kvm noble-server-cloudimg-amd64.img my-seed.iso
    sudo chmod 644 noble-server-cloudimg-amd64.img my-seed.iso
    
    sudo virt-install \
      --name master-guest \
      --ram 4096 \
      --vcpus 4 \
      --disk path=$(pwd)/noble-server-cloudimg-amd64.img,device=disk,bus=virtio \
      --disk path=$(pwd)/my-seed.iso,device=cdrom \
      --os-variant ubuntu24.04 \
      --network network=default,model=virtio \
      --graphics none \
      --import \
      --noautoconsole
    ```

**Master Node Configuration (Inside VM)**
1.  **Access the VM**: `ssh ubuntu@<MASTER_IP>` (pass: `secretpassword`).
2.  **Install K3S**:
    ```bash
    # Set alias
    echo "alias k='sudo k3s kubectl'" >> ~/.bashrc
    source ~/.bashrc

    # Install K3S Server
    curl -sfL https://get.k3s.io | sh -s - server \
      --node-ip <MASTER_IP> \
      --advertise-address <MASTER_IP> \
      --flannel-iface=enp1s0  

    # Fix VirtIO Checksum Offloading bug
    sudo apt-get install -y ethtool
    sudo ethtool -K flannel.1 tx-checksum-ip-generic off
    ```
3.  **Get Join Token**: `sudo cat /var/lib/rancher/k3s/server/node-token`

#### 3.1.2 TDX Worker Node Setup (TEE VM)

**Host Preparation (TDX)**
Perform these steps on your host machine.

1.  **Clone and Configure TDX Image**
    ```bash
    git clone https://github.com/canonical/tdx
    cd tdx/guest-tools/image
    
    # Open script to change disk size
    vim create-td-image.sh
    # ACTION: Locate the variable `SIZE` and change it to `50` (e.g., SIZE=50)
    
    # Build the image
    ./create-td-image.sh -v 24.04
    ```

2.  **Run the TDX Guest**
    ```bash
    cd ..
    vim trust_domain.xml.template 
    # ACTION: memory and cpu and set 4G and 4 vcpus respectively 
    ./tdvirsh new
    ```

**Worker Node Configuration (Inside VM)**
Once the VM is running, join it to the cluster using the agent install command:
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://<MASTER_IP>:6443 \
  K3S_TOKEN=<TOKEN> \
  sh -s - agent \
  --with-node-id \
  --node-ip <TDX_IP> \
  --flannel-iface=enp0s2
```

#### 3.1.3 Standard Worker Nodes
Standard (non-TEE) worker nodes can be provisioned using the same steps as the **Master Node** (Ubuntu 24.04 VM). Once the VM is running, join it to the cluster using the agent install command:
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://<MASTER_IP>:6443 \
  K3S_TOKEN=<TOKEN> \
  sh -s - agent --node-ip <WORKER_IP>
```

#### 3.1.4 Target Deployment Scenarios
The cluster supports various research configurations by distributing workloads across Normal and TDX nodes. In all scenarios, the **Master Node** handles the K8S Control Plane, metrics and testing pods.

| Scenario | Master Node | Normal Node 1 | Normal Node 2 | TDX Node (TEE) |
| :--- | :--- | :--- | :--- | :--- |
| **No-TEE Monolithic (Baseline)** | CP + Metrics + Testing | Sequencer + Builder | - | - |
| **TEE Monolithic Sequencer** | CP + Metrics + Testing | - | - | Sequencer + Builder |
| **PBS with no-TEE Builder** | CP + Metrics + Testing | Sequencer | External Builder | - |
| **PBS with TEE Builder** | CP + Metrics + Testing | Sequencer | - | External Builder |

#### 3.1.5 Node Affinity & Scheduling
To ensure that specific components (like the TEE-based builder or sequencer) run on the correct hardware, the Kubernetes manifests use `nodeAffinity` rules. This pins pods to nodes based on their hostname (e.g., `tdx-guest`).

Example from `resources/02_op-geth_tdx.yaml`:
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
            - tdx-guest
```

---

### 3.2 Kubernetes Resource Deployment
Use the `setup-stack.sh` script to deploy one of the three variants:
```bash
cd scripts
./setup-stack.sh <MODE>
```
- **Mode 1**: Monolithic Sequencer
- **Mode 2**: PBS (External Builder)
- **Mode 3**: PBS + Tx-Order-Guarantor

### 3.3 Port Forwarding
To access the services locally, use the `setup-forward.sh` script:
- **Grafana**: `./scripts/setup-forward.sh grafana metrics 3000`
- **L2 RPC (op-rbuilder)**: `./scripts/setup-forward.sh op-geth default 8545`
- **Online Voting FE**: `./scripts/setup-forward.sh online-voting-fe default 3030`

The script requires: `<service-name> <namespace> <port>`.

#### SSH Tunneling from Local Machine
If you are accessing the cluster from a remote local machine through a jump host, use the following to forward ports to your local environment:
```bash
ssh -J <user>@<jump-host> \
  -L 3000:localhost:3000 \
  -L 3030:localhost:3030 \
  -L 8545:localhost:8545 \
  ubuntu@<MASTER_IP>
```

### 3.4 Block Explorer
A lightweight block explorer can be used to visualize transactions and blocks on the L2 network. Run it using Docker:
```bash
docker run -p 80:80 -e APP_NODE_URL="http://localhost:8545" alethio/ethereum-lite-explorer
```
Once running, access the explorer at `http://localhost:80`.

### 3.5 Running Tests & Load Injection

#### Load Injection with Contender
Exec into the `contender` pod and run the spam script:
```bash
# Inside the contender pod
/scripts/run.sh
```

#### Online Voting DApp Testing
1.  **Deploy Contract**: Use Hardhat in `online-voting/be` to deploy.
2.  **Generate Users**: `node scripts/CreateUsers.js` in `be` folder.
3.  **Run JMeter**:
    - Feed the generated CSV to the JMeter pod.
    - Execute: `jmeter -n -t /test/online-voting-tests.jmx -l results.jtl`

---

## 4. Credits

The **online-voting** DApp was originally developed by [Gabriela Neagu](https://github.com/gabrielaneagu).
