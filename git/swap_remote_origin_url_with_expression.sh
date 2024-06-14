#!/bin/bash

# Script: swap_remote_origin_url_with_expression.sh
# Author: Gabriel Juliao
# Description: This script iterates through all subdirectories in the specified directory (or current directory if none specified),
# checks if they are Git repositories, and updates their remote URLs.

set -e

# Function to backup the current remote URL
# Arguments:
# $1 - Current remote URL
# $2 - Repository name (directory name)
backup_remote_url() {
  local remote_url=$1
  local repo_name=$2
  local backup_dir="$HOME/git_migration_backup/$repo_name"

  # Create backup directory if it doesn't exist
  mkdir -p "$backup_dir"

  # Save the remote URL backup to a file in the backup directory
  echo "$remote_url" > "$backup_dir/git_remote_url.backup"
}

# Function to restore the original remote URL from backup
# Arguments:
# $1 - Repository name (directory name)
restore_remote_url() {
  local repo_name=$1
  local backup_dir="$HOME/git_migration_backup/$repo_name"
  local backup_file="$backup_dir/git_remote_url.backup"

  if [ -f "$backup_file" ]; then
    local original_url=$(cat "$backup_file")
    echo "Restoring original remote URL: $original_url"
    if git -C "$repo_name" remote set-url origin "$original_url"; then
      echo "Successfully restored original remote URL"
      rm "$backup_file" # Remove backup file after successful restore
    else
      echo "Failed to restore original remote URL"
    fi
  else
    echo "Backup file '$backup_file' not found, unable to restore original remote URL"
  fi
}

# Function to process repository based on parameters
# Arguments:
# $1 - Directory path of the repository
# $2 - Sed expression for URL conversion
process_repository() {
  local dir=$1
  local sed_expression=$2

  cd "$dir" || return

  # Retrieve the current remote URL for 'origin'
  local remote_url
  remote_url=$(git remote get-url origin)

  # If the remote URL is empty, skip this repository
  if [ -z "$remote_url" ]; then
    echo "No remote URL found for 'origin' in directory: $dir"
    cd .. # Return to the parent directory
    return
  fi

  # Backup the current remote URL
  local repo_name=$(basename "$dir")
  backup_remote_url "$remote_url" "$repo_name"
  echo "Backed up the original remote URL to $HOME/git_migration_backup/$repo_name in directory: $dir"

  # Convert URL using sed expression
  local new_url
  new_url=$(echo "$remote_url" | sed -E "$sed_expression")
  echo "Old URL: $remote_url"
  echo "New URL: $new_url"

  # Set the new remote URL for 'origin'
  echo "Setting new remote URL for 'origin'"
  if git -C "$dir" remote set-url origin "$new_url"; then
    echo "Successfully set new remote URL for 'origin' in directory: $dir"
  else
    echo "Failed to set new remote URL for 'origin' in directory: $dir"
  fi

  cd .. # Return to the parent directory
}

# Function to process each repository
# Arguments:
# $1 - Action to perform ('--replace' or '--restore')
# $2 - Directory path to process (optional)
# $3 - Sed expression for URL conversion (for '--replace' action)
process_repositories() {
  local action=$1
  local dir=$2
  local sed_expression=$3

  # If no directory is specified, use the current directory
  if [ -z "$dir" ]; then
    dir="."
  fi

  # Check if --restore parameter is provided
  if [ "$action" == "--restore" ]; then
    # Iterate through all backup directories and restore
    for backup_dir in "$HOME/git_migration_backup"/*/; do
      local repo_name=$(basename "$backup_dir")
      restore_remote_url "$repo_name"
    done
    return
  fi

  # Iterate through all subdirectories
  for sub_dir in "$dir"/*/; do
    # Check if the subdirectory is a Git repository
    if [ -d "$sub_dir" ] && [ -e "$sub_dir/.git" ]; then
      process_repository "$sub_dir" "$sed_expression"
    fi
  done
}

# Main function
main() {
  local action=$1
  local dir=$2
  local sed_expression=$3

  # Validate action parameter
  if [ "$action" != "--replace" ] && [ "$action" != "--restore" ]; then
    echo "Invalid action parameter. Usage: ./my-script.sh [--replace <sed_expression>] [--restore] [<directory>]"
    exit 1
  fi

  process_repositories "$action" "$dir" "$sed_expression"
}

# Execute main function with command-line arguments
main "$@"