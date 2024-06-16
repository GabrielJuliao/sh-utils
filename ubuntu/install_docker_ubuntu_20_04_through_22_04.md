# Installation Script for Docker on Ubuntu 20.04 through 22.04

## Description

This Bash script automates the installation of Docker on Ubuntu versions 20.04 through 22.04. It handles the uninstallation of old Docker versions (if present), sets up the Docker repository, installs Docker Engine and CLI components, starts the Docker service, and runs a sample Docker container.

## Prerequisites

- The script must be executed with superuser (root) privileges.
- The target system must be running Ubuntu 20.04, 20.10, 21.04, or 21.10 (code-named Focal Fossa, Groovy Gorilla, Hirsute Hippo, Impish Indri respectively).

## Installation

### Option 1: Download and Execute Script

1. Clone the repository from your distro and `cd` into the script folder:
   ```bash
   cd sh-utils/ubuntu
   ```

2. Make the script executable:
   ```bash
   chmod +x install_docker_ubuntu_20_04_through_22_04.sh
   ```

3. Execute the script with superuser privileges:
   ```bash
   sudo ./install_docker_ubuntu_20_04_through_22_04.sh
   ```

### Option 2: Direct Execution via curl | bash
[!CAUTION]
This method is convenient but requires caution, as it executes code from the internet with root privileges.

You can directly download and execute the script using `curl` and `bash`.

```bash
curl -fsSL https://raw.githubusercontent.com/GabrielJuliao/sh-utils/main/ubuntu/install_docker_ubuntu_20_04_through_22_04.sh | sudo bash -s --
```

## Features

- Uninstalls old Docker versions (docker, docker-engine, docker.io, containerd, runc).
- Sets up Docker's official repository.
- Installs Docker Engine, Docker CLI, containerd.io, and Docker Compose.
- Starts the Docker service automatically.
- Runs a sample Docker container (`hello-world`) to verify installation.

## Logging

The script logs its actions and errors to the console and a file named `install_docker_ubuntu_20_04_through_22_04_<timestamp>.log` in the current directory.

## Notes

- For troubleshooting and more detailed logs, refer to the generated log file in the current directory.
- Exercise caution when using `curl | bash` method. Verify the source URL and contents before executing.

## License

This script is licensed under the GNU GPL license. See [LICENSE](../LICENSE) for more details.