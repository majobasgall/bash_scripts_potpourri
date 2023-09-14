#!/bin/bash
# Backup script from the same source directory to multiple destination directories

# Usage: ./sync_to_multi_destinations.sh <source_directory> <backup_directories_file>
# In <backup_directories_file>: use each line for each full path destination
# Example: ./sync_to_multi_destinations.sh /run/media/myUser/myDiskSource/backup/photos/ ../backup_photos_dir_file
#
# backup_photos_dir_file content:
# /run/media/myUser/myDiskDestination1/backup/photos/
# /run/media/myUser/myDiskDestination2/backup/photos/
# /run/media/myUser/myDiskDestination3/backup/photos/

# Function to perform the backup and print status message
perform_and_print_status() {
  local source_dir="$1"
  local backup_dir="$2"

  # Perform the backup
  if rsync -av --delete "$source_dir" "$backup_dir"; then
    echo "INFO: Backup to $backup_dir completed successfully."
  else
    echo "ERROR: Backup to $backup_dir failed."
  fi
}

is_directory_mounted() {
  local directory="$1"

  # Remove the last two parts, keep only the volume name
  volume_name="$(dirname "$(dirname "$directory")")"

  echo "INFO: Checking if '$volume_name' is mounted..."
  if mount | grep -q "$volume_name"; then
    echo "'$volume_name' is mounted."
    return 0  # Directory is mounted
  else
    echo "ERROR: '$volume_name' is not mounted."
    return 1  # Directory is not mounted
  fi
}

# Check if the source directory and backup directories file are provided as arguments
if [ $# -ne 2 ]; then
  echo "Usage: $0 <source_directory> <backup_directories_file>"
  exit 1
fi

# Source directory
source_dir="$1"

# File containing backup directories (each directory on a separate line)
backup_directories_file="$2"

# Check if the source directory exists
if [ ! -d "$source_dir" ]; then
  echo "ERROR: Source directory does not exist."
  exit 1
fi

# Check if the backup directories file exists
if [ ! -f "$backup_directories_file" ]; then
  echo "ERROR: Backup directories file does not exist."
  exit 1
fi


# Perform backup for each directory listed in the file
while IFS='' read -r backup_dir || [[ -n "$backup_dir" ]]; do
  # Check if the backup directory is valid
  if [ ! -d "$backup_dir" ]; then
    echo "WARN: Skipping... invalid backup directory: $backup_dir"
    continue
  fi

  # Check if the backup directory is mounted
  if is_directory_mounted "$backup_dir"; then
    echo "INFO: Performing backup to: $backup_dir"
    perform_and_print_status "$source_dir" "$backup_dir"
  else
    echo "WARN: Skipping... backup for unmounted directory: $backup_dir"
    mount | grep "$backup_dir"  # Display mounted filesystems to help diagnose the issue
  fi
done < "$backup_directories_file"