#!/bin/bash

# Script: swap_remote_origin_url_with_expression.sh
# Author: Gabriel Juliao
# Description: This script iterates through Git repositories in the specified directory (or current directory if none specified),
# checks if they are Git repositories, and updates their remote URLs using sed expressions.

set -e

log_file="$HOME/swap_remote_origin_url_with_expression_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages with timestamp
# Arguments:
# $1 - Log level (INFO, WARNING, ERROR, SUCCESS)
# $2 - Log message
log_message() {
  local log_level=$1
  local log_message=$2
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [$log_level] $log_message" | tee -a "$log_file"
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

# Function to backup the current remote URL and repository path
# Arguments:
# $1 - Current remote URL
# $2 - Absolute path of the repository
backup_remote_url() {
  local remote_url=$1
  local repo_path=$2
  local backup_dir="$HOME/git_migration_backup/$repo_path"

  log_info "Backing up remote URL for repository at $repo_path"

  # Create backup directory if it doesn't exist
  mkdir -p "$backup_dir"

  # Save the repository path and remote URL to a backup file
  echo "$repo_path" > "$backup_dir/git_remote_url.backup"
  echo "$remote_url" >> "$backup_dir/git_remote_url.backup"
  log_success "Backup completed for $repo_path"
}

# Function to restore the original remote URL from backup
restore_remote_url() {
  local backup_base_dir="$HOME/git_migration_backup"

  log_info "Starting restoration of original remote URLs from backups"

  # Iterate through all backup files
  find "$backup_base_dir" -name 'git_remote_url.backup' | while read -r backup_file; do
    local repo_path=$(sed -n '1p' "$backup_file")
    local original_url=$(sed -n '2p' "$backup_file")
    log_info "Restoring original remote URL for repository at $repo_path"
    if git -C "$repo_path" remote set-url origin "$original_url"; then
      log_success "Successfully restored original remote URL for repository at $repo_path"
      rm "$backup_file" # Remove backup file after successful restore
    else
      log_error "Failed to restore original remote URL for repository at $repo_path"
    fi
  done
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

  log_info "Processing repository in directory $dir"

  # Retrieve the current remote URL for 'origin'
  local remote_url
  remote_url=$(git remote get-url origin 2>/dev/null)

  # If the remote URL retrieval failed, skip this repository
  if [ $? -ne 0 ] || [ -z "$remote_url" ]; then
    log_warning "No remote URL found for 'origin' in directory: $dir, skipping"
    cd .. # Return to the parent directory
    return
  fi

  # Check if the current remote URL matches the desired format
  local new_url
  new_url=$(echo "$remote_url" | sed -E "$sed_expression")
  if [ "$remote_url" == "$new_url" ]; then
    log_info "Remote URL in directory $dir already matches the desired format, skipping"
    cd .. # Return to the parent directory
    return
  fi

  # Backup the current remote URL with full repository path
  local repo_path=$(realpath "$PWD")
  backup_remote_url "$remote_url" "$repo_path"

  # Validate the new URL
  if validate_url "$new_url"; then
    log_info "Old URL: $remote_url"
    log_info "New URL: $new_url"

    # Set the new remote URL for 'origin'
    log_info "Setting new remote URL for 'origin'"
    if git remote set-url origin "$new_url"; then
      log_success "Successfully set new remote URL for 'origin' in directory $dir"
    else
      log_error "Failed to set new remote URL for 'origin' in directory $dir"
    fi
  else
    log_error "Invalid new URL: $new_url"
  fi

  cd .. # Return to the parent directory
}

# Function to process each repository
# Arguments:
# $1 - Action to perform ('--replace' or '--restore')
# $2 - Path to directory containing repositories
# $3 - Sed expression for URL conversion (for '--replace' action)
process_repositories() {
  local action=$1
  local dir=$2
  local sed_expression=$3

  # Check if --restore parameter is provided
  if [ "$action" == "--restore" ]; then
    restore_remote_url
    return
  fi

  log_info "Starting URL replacement in repositories under $dir"

  # Iterate through all subdirectories in the specified directory
  for sub_dir in "$dir"/*/; do
    # Check if the subdirectory is a Git repository
    if [ -d "$sub_dir" ] && git -C "$sub_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      process_repository "$sub_dir" "$sed_expression"
    else
      log_warning "Directory $sub_dir is not a valid Git repository, skipping"
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
    log_error "Invalid action parameter. Usage: $0 [--replace <path_to_git_repos> <sed_expression>] [--restore]"
    exit 1
  fi

  # Validate mandatory parameters for --replace action
  if [ "$action" == "--replace" ]; then
    if [ -z "$dir" ] || [ -z "$sed_expression" ]; then
      log_error "Error: Both <path_to_git_repos> and <sed_expression> are required for --replace action."
      exit 1
    fi
  fi

  process_repositories "$action" "$dir" "$sed_expression"
}

# Execute main function with command-line arguments
main "$@"
