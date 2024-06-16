Welcome to the sh-utils repository! This repository hosts a collection of useful Bash shell utilities and scripts.

## Scripts

### Ubuntu Docker Installation Script

The Docker Installation Script (`install_docker_ubuntu_20_04_through_22_04.sh`) automates the installation of Docker on Ubuntu versions 20.04 through 22.04. It handles the uninstallation of old Docker versions, sets up the Docker repository, installs Docker Engine and CLI components, and starts the Docker service.

- **[View Script Documentation](ubuntu/install_docker_ubuntu_20_04_through_22_04.md)**: Detailed documentation on how to use `install_docker_ubuntu_20_04_through_22_22.sh`.

### Git Repository URL Migration Script

The Git Repository URL Migration Script (`swap_remote_origin_url_with_expression.sh`) automates the migration of Git repository remote URLs from one format to another. It iterates through all subdirectories within a specified directory (or the current directory by default), checks if they are Git repositories, and updates their remote URLs based on user-defined rules using `sed`.

- **[View Script Documentation](git/swap_remote_origin_url_with_expression.md)**: Detailed documentation on how to use `swap_remote_origin_url_with_expression.sh`.

### Usage

To use any script from this repository, you can clone the repository or directly download and execute the scripts using `curl` and `bash`.

#### Example Usage

```bash
# By Cloning the repository
git clone https://github.com/GabrielJuliao/sh-utils.git
cd sh-utils/<script-dir>
chmod +x <desired-script>
./<desired-script>

# Running with curl | bash
curl -s https://raw.githubusercontent.com/GabrielJuliao/sh-utils/main/<script-dir>/<desired-script>.sh | bash -s -- <script-args>
```

### Contributing

We welcome contributions! To contribute to the sh-utils repository:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Create a new Pull Request

## License

This project is licensed under the GNU GPL License - see the [LICENSE](LICENSE) file for details.

## Authors

- [Gabriel Juliao](https://github.com/GabrielJuliao)