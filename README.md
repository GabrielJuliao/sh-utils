# Shell Utils

Welcome to the sh-utils repository! This repository hosts a collection of useful Bash shell utilities and scripts.

## Scripts

### Git Repository URL Migration Script

The Git Repository URL Migration Script (`swap_remote_origin_url_with_expression.sh`) automates the migration of Git repository remote URLs from one format to another. It iterates through all subdirectories within a specified directory (or the current directory by default), checks if they are Git repositories, and updates their remote URLs based on user-defined rules using `sed`.

- **[View Script Documentation](git/swap_remote_origin_url_with_expression.md)**: Detailed documentation on how to install, use, and contribute to `swap_remote_origin_url_with_expression.sh`.

### Future Scripts

_(future scripts and utilities are planned for inclusion in sh-utils)_

## Usage

To use any script from this repository, you can clone the repository or directly download and execute the scripts using `curl` and `bash`.

### Example Usage

```bash
# Clone the repository
git clone https://github.com/GabrielJuliao/sh-utils.git
cd sh-utils

# Run <desired-script> with curl
curl -s https://raw.githubusercontent.com/GabrielJuliao/sh-utils/main/<script-dir>/<desired-script>.sh | bash -s -- <script-args>
```

## Contributing

We welcome contributions! To contribute to the sh-utils repository:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

- [Gabriel Juliao](https://github.com/GabrielJuliao)