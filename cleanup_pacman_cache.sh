#!/bin/bash

# Script Name: cleanup_pacman_cache.sh
# Author: @majobasgall
# Version: 1.0
# Description: This script checks and cleans unused packages in Arch Linux's package cache.
# It also displays the space used by the package cache before and after the cleanup.
# Usage: Run this script to clean the package cache, keeping a specified number of versions.
# Example: ./cleanup_pacman_cache.sh

# Define the maximum number of versions to keep (adjust as needed).
MAX_VERSIONS=1

# Define the package cache path
CACHE_PATH="/var/cache/pacman/pkg/"

# Display disk usage in human-readable format.
show_disk_usage() {
  du -sh "$1"
}

# Display the space used by the package cache before cleanup.
echo "Space used by package cache before cleanup:"
show_disk_usage $CACHE_PATH

# Remove unused packages, keeping the specified number of versions.
paccache -rk$MAX_VERSIONS

# Display the space used by the package cache after cleanup.
echo "Space used by package cache after cleanup:"
show_disk_usage $CACHE_PATH

# Display a summary of the cleaned packages.
paccache -ruk0