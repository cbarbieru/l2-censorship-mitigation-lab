# 2-Node Kubernetes Cluster Setup (Ubuntu Master + TDX Worker)

This guide details the steps to deploy a 2-node K3S cluster consisting of:
1.  **Master Node:** Ubuntu 24.04 (Noble) VM running on Libvirt/KVM.
2.  **Worker Node:** Canonical TDX VM.

---

## 1. Master Node Setup (Ubuntu 24.04 VM)

### Host Preparation & VM Creation
Perform these steps on your host machine to provision the Master VM.

1.  **Prepare Workspace and Image**
    ```bash
    mkdir ~/guest-master
    cd ~/guest-master
    
    # Download Ubuntu 24.04 Cloud Image
    wget [https://cloud-images.ubuntu.com/noble/20260108/noble-server-cloudimg-amd64.img](https://cloud-images.ubuntu.com/noble/20260108/noble-server-cloudimg-amd64.img)
    
    # Resize image to 50GB
    qemu-img resize noble-server-cloudimg-amd64.img 50G
    ```

2.  **Generate Cloud-Init Configuration**
    Install utilities and create the user-data file.
    ```bash
    sudo apt update && sudo apt install cloud-image-utils -y
    
    cat <<EOF > user-data
    #cloud-config
    hostname: master
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: false
        # Sets password to "secretpassword"
        passwd: password 
    
    # This ensures password authentication is allowed if SSH key fails
    ssh_pwauth: true
    chpasswd:
      list: |
        ubuntu:secretpassword
      expire: False
    EOF
    
    # Build seed ISO
    cloud-localds my-seed.iso user-data
    ```

3.  **Install the VM**
    Set permissions for Libvirt and run the install command.
    ```bash
    # Set permissions
    sudo chown libvirt-qemu:kvm noble-server-cloudimg-amd64.img my-seed.iso
    sudo chmod 644 noble-server-cloudimg-amd64.img my-seed.iso
    
    # Provision VM (4 vCPUs, 4GB RAM)
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

### Master Node Configuration
Perform these steps inside the Master VM.

1.  **Access the VM**
    Find the IP address and SSH in (password: `secretpassword`).
    ```bash
    # On Host
    sudo virsh domifaddr guest-master
    ssh ubuntu@<MASTER_IP>
    ```

2.  **Install K3S & Configure Environment**
    ```bash
    # Switch shell to bash and setup alias
    chsh -s /bin/bash
    echo "alias k='sudo k3s kubectl'" >> ~/.bashrc
    source ~/.bashrc


    # Install K3S
    hostname -I
    ip a
    curl -sfL https://get.k3s.io | sh -s - server \
      --node-ip 192.168.122.58 \
      --advertise-address 192.168.122.58 \
      --flannel-iface=enp1s0  

    # Prevent VirtIO Checksum Offloading bug
    sudo apt-get update && sudo apt-get install -y ethtool
    sudo ethtool -K flannel.1 tx-checksum-ip-generic off
    ```

3.  **Get Join Token**
    Run the following to generate the connection string for the worker. **Save the output.**
    ```bash
    sudo cat /var/lib/rancher/k3s/server/node-token
    ```

---

## 2. Worker Node Setup (TDX VM)

### Host Preparation (TDX)
Perform these steps on your host machine.

1.  **Clone and Configure TDX Image**
    ```bash
    git clone [https://github.com/canonical/tdx](https://github.com/canonical/tdx)
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

### Worker Node Configuration
Perform these steps inside the TDX Guest VM.
1.  **Login to TDX node**
    ```bash
    sudo virsh domifaddr tdx-guest
    ssh tdx@<TDX_IP>
    ```

2.  **Install K3S**
    ```bash
    curl -sfL https://get.k3s.io | K3S_URL=https://192.168.122.58:6443 \
      K3S_TOKEN=YOUR_TOKEN_FROM_STEP_2 \
      sh -s - agent \
      --with-node-id \
      --node-ip 192.168.122.89 \
      --flannel-iface=enp0s2
    ```

---

## 3. Workload Deployment

Perform these steps on the **Master Node**.

1.  **Download Workload Scripts**
    ```bash
    git clone [https://github.com/cbarbieru/builder-playground-opstack-k8s](https://github.com/cbarbieru/builder-playground-opstack-k8s)
    cd builder-playground-opstack-k8s/scripts
    ```

2.  **Run Setup and Tests**
    ```bash
    # Setup Contender
    ./setup-contender.sh
    
    # Run Test
    ./setup-test.sh
    ```

3.  **Verify**
    ```bash
    k get pods -A
    ```