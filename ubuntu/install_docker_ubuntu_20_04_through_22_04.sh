#!/bin/bash

# Script: install_docker_ubuntu_20_04_through_22_04.sh
# Author: Gabriel Juliao
# Description: This script installs Docker on Ubuntu 20.04 through 22.04. It uninstalls old versions,
# sets up the repository, and installs Docker Engine and CLI components.

log_file="$(pwd)/install_docker_ubuntu_20_04_through_22_04_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages with timestamp
# Arguments:
# $1 - Log level (INFO, WARNING, ERROR, SUCCESS)
# $2 - Log message
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

  echo "[$timestamp] [$log_level] $script_name: $log_message" | tee -a "$log_file"
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

# Function to run a command and log its stdout and stderr
# Arguments:
# $1 - Command to run
run_and_log() {
  local command=$1
  log_info "Running command: $command"

  {
    eval "$command"
  } &> >(tee -a "$log_file")

  local exit_code=$?

  if [ $exit_code -ne 0 ]; then
    log_error "Command failed with exit code $exit_code: $command"
    log_info "The log file is located at: \"$log_file\""
    exit $exit_code
  else
    log_success "Command succeeded: $command"
  fi
}

# Function to check if the script is run as root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root"
    exit 1
  fi
}

# Function to uninstall old versions of Docker
uninstall_old_docker() {
  log_info "Uninstalling old versions of Docker, if any."
  run_and_log "apt-get remove -y docker docker-engine docker.io containerd runc"
}

# Function to update the package index
update_package_index() {
  log_info "Updating package index."
  run_and_log "apt-get update"
}

# Function to install prerequisites
install_prerequisites() {
  log_info "Installing prerequisites."
  run_and_log "apt-get install -y ca-certificates curl gnupg lsb-release"
}

# Function to add Docker’s official GPG key
add_docker_gpg_key() {
  log_info "Adding Docker's official GPG key."
  run_and_log "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"
}

# Function to set up Docker repository
setup_docker_repository() {
  local distro
  distro=$(lsb_release -cs)
  log_info "Setting up Docker repository for $distro."
  run_and_log "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $distro stable\" | tee /etc/apt/sources.list.d/docker.list >/dev/null"
}

# Function to install Docker Engine and CLI components
install_docker() {
  log_info "Installing Docker Engine and CLI components."
  run_and_log "apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin"
}

# Function to start Docker service
start_docker_service() {
  log_info "Starting Docker service."
  run_and_log "service docker start"
}

# Function to wait for a specified number of seconds
# Arguments:
# $1 - Number of seconds to wait
wait_for_seconds() {
  local sec=$1
  log_info "Waiting $sec seconds to ensure the service starts properly..."
  run_and_log "sleep $sec"
  log_info "Wait time completed."
}

# Function to run a sample Docker container
run_sample_container() {
  log_info "Running sample container. You should see 'Hello World' from Docker."
  run_and_log "docker run hello-world"
}

# Main function to execute the script steps
main() {
  check_root
  log_info "Script created by Gabriel Juliao. See more on: https://github.com/GabrielJuliao"
  uninstall_old_docker
  update_package_index
  install_prerequisites
  add_docker_gpg_key
  setup_docker_repository
  update_package_index
  install_docker
  start_docker_service
  wait_for_seconds 30
  run_sample_container
  log_success "Docker installation completed successfully!"
  log_info "The log file is located at: \"$log_file\""

  printf "\n\nRun the below commands as a normal user to manage Docker without sudo:\n\n"
  printf "sudo groupadd docker\n"
  printf "sudo usermod -aG docker \$USER\n"
  printf "newgrp docker\n"
}

# Execute main function
main
