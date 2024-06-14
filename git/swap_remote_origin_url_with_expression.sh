#!/bin/bash

# Script: swap_remote_origin_url_with_expression.sh
# Author: Gabriel Juliao
# Description: This script iterates through all subdirectories in the specified directory (or current directory if none specified),
# checks if they are Git repositories, and updates their remote URLs.

set -e

# Function to backup the current remote URL and repository path
# Arguments:
# $1 - Current remote URL
# $2 - Repository directory path
backup_remote_url() {
  local remote_url=$1
  local repo_path=$2
  local backup_dir="$HOME/git_migration_backup"

  # Create backup directory if it doesn't exist
  mkdir -p "$backup_dir"

  # Save the remote URL backup to a file in the backup directory
  echo "$remote_url" > "$backup_dir/${repo_path//\//_}_git_remote_url.backup"
}

# Function to restore the original remote URL from backup
# Arguments:
# $1 - Repository directory path
restore_remote_url() {
  local repo_path=$1
  local backup_dir="$HOME/git_migration_backup"
  local backup_file="$backup_dir/${repo_path//\//_}_git_remote_url.backup"

  if [ -f "$backup_file" ]; then
    local original_url=$(cat "$backup_file")
    echo "Restoring original remote URL: $original_url"
    if git -C "$repo_path" remote set-url origin "$original_url"; then
      echo "Successfully restored original remote URL"
      rm "$backup_file" # Remove backup file after successful restore
    else
      echo "Failed to restore original remote URL"
    fi
  else
    echo "Backup file '$backup_file' not found, unable to restore original remote URL"
  fi
}

# Function to validate URL format
# Arguments:
# $1 - URL to validate
validate_url() {
  local url=$1
  local regex='^(https|ssh):\/\/[a-zA-Z0-9.-]+(:[0-9]+)?\/?.*$'
  [[ "$url" =~ $regex ]]
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

  # Backup the current remote URL with full repository path
  local repo_path=$(pwd)
  backup_remote_url "$remote_url" "$repo_path"
  echo "Backed up the original remote URL to $HOME/git_migration_backup/${repo_path//\//_}_git_remote_url.backup in directory: $dir"

  # Convert URL using sed expression
  local new_url
  new_url=$(echo "$remote_url" | sed -E "$sed_expression")
  echo "Old URL: $remote_url"
  echo "New URL: $new_url"

  # Validate the new URL
  if validate_url "$new_url"; then
    # Set the new remote URL for 'origin'
    echo "Setting new remote URL for 'origin'"
    if git remote set-url origin "$new_url"; then
      echo "Successfully set new remote URL for 'origin' in directory: $dir"
    else
      echo "Failed to set new remote URL for 'origin' in directory: $dir"
    fi
  else
    echo "Invalid new URL: $new_url"
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
    for backup_file in "$HOME/git_migration_backup"/*_git_remote_url.backup; do
      local repo_path=${backup_file%_git_remote_url.backup}
      repo_path=${repo_path##*/}
      restore_remote_url "$repo_path"
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
    echo "Invalid action parameter. Usage: $0 [--replace <sed_expression>] [--restore] [<directory>]"
    exit 1
  fi

  process_repositories "$action" "$dir" "$sed_expression"
}

# Execute main function with command-line arguments
main "$@"
