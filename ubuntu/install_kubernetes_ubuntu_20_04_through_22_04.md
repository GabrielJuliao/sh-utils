# Kubernetes Setup Script (Ubuntu)

This script automates the installation and configuration of Kubernetes on Ubuntu systems, including essential components like container runtimes (containerd), network interfaces, and the Kubernetes control plane setup.

## Prerequisites

- **Ubuntu**: Designed for Ubuntu systems (20.04 - 22.04), amd64 or arm64.
- **Root Access**: Requires root privileges to execute.
- **Unique Hostname**: Each node must have a unique hostname for cluster identification.
- **Static IP Address**: Configure a static IP address for each node in the cluster.

## Configuration Variables

You can configure the script by adjusting the variables at the top of script.

- `KUBERNETES_VERSION`: Kubernetes version to install.
- `CONTAINERD_VERSION`: Version of containerd (container runtime).
- `RUNC_VERSION`: Version of runc (container runtime dependency).
- `CNI_VERSION`: Version of CNI (Container Network Interface).
- `POD_NETWORK_CIDR`: Pod network CIDR for the Kubernetes cluster.
- `CPU_ARCH`: Architecture of the packages to be installed (`amd64` or `arm64`, by default is set automatically).

## Before Installation

### Network Configuration

1. **Configure Static IP**:
    - Create a network configuration file based on the provided template.

      ```yaml
      network:
        version: 2
        renderer: networkd
        ethernets:
          enp0s3:
            addresses:
              - 192.168.1.100/24
            routes:
              - to: 0.0.0.0/0
                via: 192.168.1.1
                on-link: true
            nameservers:
              addresses: [1.1.1.1, 8.8.8.8]
      ```

   **Explanation**:
    - `network`: Top-level key specifying network configuration.
    - `version: 2`: Netplan configuration version.
    - `renderer: networkd`: Backend renderer used.
    - `ethernets`: Configuration for Ethernet interfaces.
    - `enp0s3`: Interface name (replace with your actual interface name, listed using `ip a`).
    - `addresses`: Specifies static IP address and subnet mask.
    - `routes`: Defines routing information including the default route and gateway IP.
    - `nameservers`: Specifies DNS server settings.

   **Test/Apply Configuration**:
    - Edit the file to set the desired static IP address, subnet mask, gateway, and DNS server IPs for your node.
    - Place the file named `00-installer-config.yaml` under `/etc/netplan` (the file may already exist).
    - Test the configuration using `netplan try` (Note: SSH connections may disrupt).
    - Apply the configuration permanently using `netplan apply`.

2. **Configure Hostname**:
    - Set a new hostname using `hostnamectl set-hostname NEW_HOSTNAME`.
    - Replace `NEW_HOSTNAME` with the desired hostname.
    - Verify the change by running `hostname`.

   **Note**: Ensure that the IP addresses provided, both for static assignment and the hostname, are either leased from your network's DHCP server or are outside the DHCP range to prevent conflicts or address allocation issues within your network.

## Installation

### Option 1: Download and Execute Script

1. Clone the repository and navigate to the script folder:

   ```bash
   cd sh-utils/ubuntu
   ```

2. Make the script executable:

   ```bash
   chmod +x install_kubernetes_ubuntu_20_04_through_22_04.sh
   ```

3. Execute the script with superuser privileges:

   ```bash
   sudo ./install_kubernetes_ubuntu_20_04_through_22_04.sh
   ```

### Option 2: Direct Execution via curl | bash

> **Caution**: This method is convenient but requires caution, as it executes code from the internet with root privileges.

You can directly download and execute the script using `curl` and `bash`.

```bash
curl -fsSL https://raw.githubusercontent.com/GabrielJuliao/sh-utils/main/ubuntu/install_kubernetes_ubuntu_20_04_through_22_04.sh | sudo bash -s --
```

### Initialize Control Plane

- After running the script, it will prompt you to initialize a control plane if desired.
- Follow the post-installation instructions provided by the script after initializing the control plane.

## Script Details

- **Network Configuration**:
    - Initializes necessary network configurations for Kubernetes.
    - Modifies system settings and configurations related to networking.

- **Install Containerd**:
    - Downloads and installs containerd, container runtime, and related dependencies.
    - Configures containerd and its services.

- **Install Kubernetes**:
    - Disables swap, sets up Kubernetes repositories, and installs required Kubernetes components (`kubelet`, `kubeadm`, `kubectl`).

- **Initialize Control Plane**:
    - Prompts the user to initialize a control plane.
    - Initializes the Kubernetes control plane and provides additional instructions for setting up worker nodes and running workloads.

## Important Notes

- Review and modify variables according to your system requirements before running the script.
- Follow the post-installation instructions provided by the script after initializing the control plane.

