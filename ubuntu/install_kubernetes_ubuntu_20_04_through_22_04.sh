#!/bin/bash

# Script: install_kubernetes_ubuntu_20_04_through_22_04.sh
# Author: Gabriel Juliao
# Description: This script installs Kubernetes on Ubuntu.

LOG_FILE="$(pwd)/install_kubernetes_ubuntu_20_04_through_22_04_$(date +%Y%m%d_%H%M%S).log"

# Define the version of Kubernetes to be installed
KUBERNETES_VERSION="1.29.3-1.1"

# Define the version of containerd (container runtime) to be installed
CONTAINERD_VERSION="1.7.14"

# Define the version of runc (container runtime dependency) to be installed
RUNC_VERSION="1.1.12"

# Define the version of CNI (Container Network Interface) to be installed
CNI_VERSION="1.4.1"

# Define the Pod network CIDR (Classless Inter-Domain Routing) for Kubernetes cluster
# This defines the IP address range that Pods will use for communication within the cluster.
POD_NETWORK_CIDR="192.168.0.0/16"

# Automatically get the CPU architecture
CPU_ARCH=$(uname -m)

if [[ $CPU_ARCH == "x86_64" ]]; then
    CPU_ARCH="amd64"
elif [[ $CPU_ARCH == "aarch64" ]]; then
    CPU_ARCH="arm64"
fi

# Declare an associative array for URLs
declare -A urls=(
  ["containerd_url"]="https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-${CPU_ARCH}.tar.gz"
  ["containerd_service_url"]="https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"
  ["runc_url"]="https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.${CPU_ARCH}"
  ["cni_url"]="https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-${CPU_ARCH}-v${CNI_VERSION}.tgz"
)

# Utility functions
log_message() {
  local log_level=$1
  local log_message=$2
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local script_name
  script_name=$(basename $0)

  # Truncate the script name to 40 characters from left to right, adding ellipses on the left if needed
  if [ ${#script_name} -gt 40 ]; then
    script_name="...${script_name: -37}"
  fi

  echo "[$timestamp] [$log_level] $script_name: $log_message" | tee -a "$LOG_FILE"
}

log_info() {
  log_message "INFO" "$1"
}

log_warning() {
  log_message "WARNING" "$1"
}

log_error() {
  log_message "ERROR" "$1"
}

log_success() {
  log_message "SUCCESS" "$1"
}

run_and_log() {
  local command=$1
  log_info "Running command: $command"

  {
    eval "$command"
  } &> >(tee -a "$LOG_FILE")

  local exit_code=$?

  if [ $exit_code -ne 0 ]; then
    log_error "Command failed with exit code $exit_code: $command"
    log_info "The log file is located at: \"$LOG_FILE\""
    exit $exit_code
  else
    log_success "Command succeeded: $command"
  fi
}

check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root"
    exit 1
  fi
}

# Function to copy files and directories recursively with logging
copy_files_with_logging() {
  local source_dir=$1
  local target_dir=$2
  local LOG_FILE=$3

  # Find all files and directories in the source directory
  while IFS= read -r -d '' item; do
    relative_path="${item#"$source_dir"}"
    target_item="$target_dir$relative_path"

    # Create target directory if it doesn't exist
    if [[ -d $item ]]; then
      mkdir -p "$target_item"
    else
      mkdir -p "$(dirname "$target_item")"
      cp "$item" "$target_item"
    fi

    # Log the action
    log_info "Copied: $item to $target_item"
  done < <(find "$source_dir" -print0)
}

verify_urls() {
  local non_existent_counter=0
  log_info "Verifying dependencies..."

  for key in "${!urls[@]}"; do
    if [[ ! $(curl -s --head -w '%{http_code}' "${urls[$key]}" -o /dev/null) =~ ^[23] ]]; then
      log_error "Not found: ${urls[$key]}"
      ((non_existent_counter++))
    else
      log_info "Found: ${urls[$key]}"
    fi
  done

  if [ "$non_existent_counter" -gt 0 ]; then
    log_error "Missing dependencies. $non_existent_counter item(s) not found."
    exit 1
  fi
}

update_package_index() {
  log_info "Updating package index."
  run_and_log "apt-get update"
}

install_prerequisites() {
  log_info "Installing prerequisites."
  update_package_index
  run_and_log "apt-get install -y apt-transport-https ca-certificates curl"
}

install_kubernetes() {
  log_info "Adding Kubernetes GPG key."
  run_and_log "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg"

  log_info "Adding Kubernetes repository."
  run_and_log "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list"
  update_package_index

  log_info "Installing Kubernetes components."
  run_and_log "apt-get install -y --allow-change-held-packages kubelet=${KUBERNETES_VERSION} kubeadm=${KUBERNETES_VERSION} kubectl=${KUBERNETES_VERSION}"
  run_and_log "apt-mark hold kubelet kubeadm kubectl"
}

install_containerd() {
  log_info "Installing containerd."

  # Download the containerd tarball
  run_and_log "curl -L ${urls["containerd_url"]} -o /tmp/containerd-${CONTAINERD_VERSION}-linux-${CPU_ARCH}.tar.gz"

  # Create a directory for extracting the tarball
  mkdir -p /tmp/containerd-extract

  # Extract the downloaded tarball
  run_and_log "tar -xzf /tmp/containerd-${CONTAINERD_VERSION}-linux-${CPU_ARCH}.tar.gz -C /tmp/containerd-extract"

  # Log the files extracted from the tarball
  log_info "Files extracted from containerd tarball:"
  find /tmp/containerd-extract -type f | tee -a "$LOG_FILE"

  # Stops containerd service if is active (required to copy extracted files in the below steps)
  if systemctl is-active --quiet containerd; then
    log_info "Containerd service is running, stopping it..."
    run_and_log "systemctl stop containerd"
  fi

  # Copy the extracted files and directories to /usr/local/ using the new copy function
  copy_files_with_logging "/tmp/containerd-extract" "/usr/local" "$LOG_FILE"

  # Download and set up the containerd service file
  run_and_log "curl -L ${urls["containerd_service_url"]} -o /etc/systemd/system/containerd.service"
  run_and_log "systemctl daemon-reload"
  run_and_log "systemctl enable --now containerd"

  # Download and install runc
  run_and_log "curl -L ${urls["runc_url"]} -o /tmp/runc.${CPU_ARCH}"
  run_and_log "install -m 755 /tmp/runc.${CPU_ARCH} /usr/local/sbin/runc"

  # Download and extract CNI plugins
  run_and_log "curl -L ${urls["cni_url"]} -o /tmp/cni-plugins-linux-${CPU_ARCH}-v${CNI_VERSION}.tgz"
  mkdir -p /tmp/cni-extract
  run_and_log "tar -xzf /tmp/cni-plugins-linux-${CPU_ARCH}-v${CNI_VERSION}.tgz -C /tmp/cni-extract"

  # Log the files extracted from the CNI tarball
  log_info "Files extracted from CNI tarball:"
  find /tmp/cni-extract -type f | tee -a "$LOG_FILE"

  # Copy the extracted CNI plugins to /opt/cni/bin/ using the new copy function
  copy_files_with_logging "/tmp/cni-extract" "/opt/cni/bin" "$LOG_FILE"

  # Configure Containerd Cgroup
  log_info "Configuring containerd."
  run_and_log "mkdir -p /etc/containerd"
  run_and_log "containerd config default | tee /etc/containerd/config.toml > /dev/null"
  run_and_log "sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml"
  run_and_log "systemctl restart containerd"
}

init_control_plane() {
  log_info "Initializing Kubernetes control plane."
  run_and_log "kubeadm init --pod-network-cidr ${POD_NETWORK_CIDR} --kubernetes-version ${KUBERNETES_VERSION%%-[0-9]*}"
  run_and_log "ufw allow 179/tcp"
  run_and_log "ufw allow 179/udp"
}

main() {
  check_root
  log_info "Script created by Gabriel Juliao. See more on: https://github.com/GabrielJuliao"
  verify_urls "${urls[@]}"
  install_prerequisites
  install_containerd
  install_kubernetes

  # Prompt the user for control plane initialization
  while true; do
    read -r -p "Do you want to init a control plane on this node? (y/n): " answer
    answer_lowercase="${answer,,}"
    if [[ $answer_lowercase == "yes" || $answer_lowercase == "y" ]]; then
      init_control_plane

      log_info "Post-install instructions:"
      echo -e "\n"
      echo -e "1. Install Calico network helm charts (If you don't have a preferred network):\n\n" | tee -a "$LOG_FILE"
      echo -e "   helm repo add project calico https://projectcalico.docs.tigera.io/charts\n   kubectl create namespace tigera-operator\n   helm install calico projectcalico/tigera-operator --namespace tigera-operator\n\n" | tee -a "$LOG_FILE"
      echo -e "   Or Weave Net (WARNING: Weave Net is no longer maintained and there is no ARM support):\n\n   kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml\n\n" | tee -a "$LOG_FILE"
      echo -e "2. Generate join command for worker nodes:\n\n   kubeadm token create --print-join-command\n\n" | tee -a "$LOG_FILE"
      echo -e "3. Allow workloads on the control plane (Optional, use only if don't have worker nodes):\n\n   kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-\n\n" | tee -a "$LOG_FILE"
      break
    elif [[ $answer_lowercase == "no" || $answer_lowercase == "n" ]]; then
      break
    else
      echo "Please answer yes (y) or no (n)."
    fi
  done


  log_info "The log file is located at: \"$LOG_FILE\""
}

# Execute main function
main
