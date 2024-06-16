## Welcome to sh-utils!

Welcome to the sh-utils repository! Here you will find a variety of Bash shell utilities and scripts aimed at simplifying your work.

### Overview

This repository contains a growing collection of Bash shell utilities and scripts. Each script is designed to provide solutions for specific challenges and is accompanied by documentation to help you understand its purpose and usage.

### Scripts

#### Ubuntu Docker Installation

Automates Docker installation on Ubuntu versions 20.04 through 22.04.

- **[Documentation](ubuntu/install_docker_ubuntu_20_04_through_22_04.md)**

#### Git Repository URL Migration

Simplifies migration of Git repository remote URLs, updating them based on user-defined rules using `sed`.

- **[Documentation](git/swap_remote_origin_url_with_expression.md)**

### Usage

To use scripts from this repository, clone or download the repository and execute scripts using `curl` and `bash`.

#### Example Usage

```bash
# By cloning the repository
git clone https://github.com/GabrielJuliao/sh-utils.git
cd sh-utils/<script-dir>
chmod +x <desired-script>
./<desired-script>

# OR

# Using curl | bash
curl -s https://raw.githubusercontent.com/GabrielJuliao/sh-utils/main/<script-dir>/<desired-script>.sh | bash -s -- <script-args>
```

### Contributing

Contributions are welcome! To contribute to sh-utils - see [Contribution Guidelines](CONTRIBUTING)

### License

This project is licensed under the GNU GPL License - see the [LICENSE](LICENSE) file for details.