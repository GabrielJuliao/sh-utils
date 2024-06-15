# Git Repository URL Migration Script

## Description

This Bash script (`swap_remote_origin_url_with_expression.sh`) automates the migration of Git repository remote URLs from one format to another. It iterates through all subdirectories within a specified directory, checks if they are Git repositories, and updates their remote URLs based on user-defined rules using `sed`.

## Installation and Usage

To install and run the script directly from a URL using `curl` and `bash`, execute the following command:

```bash
curl -s https://raw.githubusercontent.com/GabrielJuliao/sh-utils/main/git/swap_remote_origin_url_with_expression.sh | bash -s -- --replace . '<sed_expression>'
```

Replace `<sed_expression>` with your specific `sed` command for URL transformation. For example:

```bash
curl -s https://raw.githubusercontent.com/GabrielJuliao/sh-utils/main/git/swap_remote_origin_url_with_expression.sh | bash -s -- --replace . 's|^([a-zA-Z]+)://([^@]+)@server1\.mydomain1\.com(:[0-9]+)?(/a)?(/[^ ]*)?|https://\2@server2.mydomain2.com/a\5|'
```

### Command-line Options

- `--replace <path_to_git_repos> <sed_expression>`: Replace remote URLs based on the provided sed expression.
- `--restore`: Restore original remote URLs from backups.

## Script Details

- **Requirements**: Bash shell, Git installed and configured.
- **License**: GNU GPL - see [LICENSE](../LICENSE) file for details.
- **Contributing**: Fork the repository, create your feature branch, commit changes, and submit a pull request.

## Usage Notes

- Ensure proper permissions if executing on a Unix-like system (e.g., `chmod +x swap_remote_origin_url_with_expression.sh`).
- Backup your repositories or test in a safe environment before executing changes.