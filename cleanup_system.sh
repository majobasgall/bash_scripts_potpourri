#!/bin/bash

# Script Name: cleanup_system.sh
# Author: @majobasgall
# Version: 2.0
# Description: This script checks and cleans unused packages or files in Arch Linux systems.

# Display disk usage in human-readable format.
show_disk_usage() {
  du -sh "$1"
}

purge_pacman_cache() {
    # Define the maximum number of versions to keep (adjust as needed).
    MAX_VERSIONS=1

    # Define the package cache path
    CACHE_PATH="/var/cache/pacman/pkg/"

    # Display the space used by the package cache before cleanup.
    echo "Space used by package cache before cleanup:"
    show_disk_usage $CACHE_PATH

    # Remove unused packages, keeping the specified number of versions.
    paccache -rk$MAX_VERSIONS

    # Display the space used by the package cache after cleanup.
    echo "Space used by package cache after cleanup:"
    show_disk_usage $CACHE_PATH

    # Display a summary of the cleaned packages.
    # paccache -ruk0
}

# Function to display the installed kernels and ask the user which one to delete
select_and_remove_kernel() {
    echo "Installed Kernels:"
    mhwd-kernel -li
    read -p "Enter the kernel version you want to remove (e.g., linux49): " kernel_version

    if [[ -n "$kernel_version" ]]; then
        sudo mhwd-kernel -r $kernel_version
    fi
}

# Function to check and purge old cache files
purge_home_cache() {
    read -p "Enter the maximum age of cache files to delete (in days): " max_age

    if [[ -n "$max_age" ]]; then
        echo "Purging cache files older than $max_age days..."
        find ~/.cache/ -type f -atime +$max_age -delete
    fi
}

# Function to remove orphaned packages
remove_orphans() {
    echo "Removing orphaned packages..."
    sudo pacman -Rns $(pacman -Qdtq)
}

# Function to display the size of /var/log directory
show_log_size() {
    log_size=$(sudo du -sh /var/log | awk '{print $1}')
    echo "Size of /var/log: $log_size"
}

# Function to remove old log files
remove_old_logs() {
    read -p "Enter the maximum age of log files to delete (in days): " max_age

    if [[ -n "$max_age" ]]; then
        echo "Removing log files older than $max_age days..."
        sudo find /var/log -type f -mtime +$max_age -delete
    fi
}

# Function to select what Docker component clean
clean_docker_component() {
    echo "Select Docker component to clean"
    echo "0. Images (are templates used to create Docker containers)"
    echo "1. Containers (are instances of Docker images)"
    echo "2. Volumes (are directories stored outside of containers, often used to persist data)"
    echo "3. Build Cache (stores intermediate build layers during image builds)"

    read -p "Select an option (0/1/2/3): " choice

    case $choice in
        0)
            docker image prune
            ;;
        1)
            docker container prune
            ;;
        2)
            docker volume prune
            ;;
        3)
            docker builder prune
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
}


# Function to display disk usage in the home directory excluding a specified directory
inspect_and_clean_home_subdir() {
    show_disk_usage() {
        echo "Analyzing disk usage in /home, excluding $EXCLUDE_DIR..."
        du -ah --exclude=/home/$EXCLUDE_DIR /home | sort -rh | head -n 30
    }

    # Prompt user for a directory to exclude from the disk usage analysis
    read -p "Enter the path relative to your home directory to exclude (e.g., $USER/0000): " EXCLUDE_DIR

    while true; do
        show_disk_usage

        # Ask if the user wants to delete any directory
        read -p "Do you want to delete any directory? (Y/n): " DECIDE

        if [ "$DECIDE" != "Y" ]; then
            echo "Exiting."
            break
        fi

        read -p "Copy the path of the directory you want to delete: " DELETE_PATH

	# Confirm the deletion
	read -p "Are you sure you want to delete $DELETE_PATH? This action cannot be undone. (Y/n): " CONFIRM

	if [ "$CONFIRM" == "Y" ]; then
	    rm -rf $DELETE_PATH
	    echo "$DELETE_PATH has been deleted."
	else
	    echo "Deletion cancelled."
	fi

	# Show disk usage after deletion
	show_disk_usage

	# Ask if the user wants to delete another directory or return to the calling code
        read -p "Do you want to delete another directory? (Y/n): " CONTINUE

        if [ "$CONTINUE" != "Y" ]; then
            break
        fi
    done
}


while true; do
    echo "Release Space System"
    echo "0. Clean up Pacman Cache"
    echo "1. Remove Kernels"
    echo "2. Purge Home Cache Files"
    echo "3. Remove Orphaned Packages"
    echo "4. Show /var/log Size and Remove Old Logs"
    echo "5. Clean up Docker components"
    echo "6. Inspect and Clean /home Subdirs"
    echo "7. Quit"

    read -p "Select an option (0/1/2/3/4/5/6/7): " choice

    case $choice in
        0)
            purge_pacman_cache
            ;;
        1)
            select_and_remove_kernel
            ;;
        2)
            purge_home_cache
            ;;
        3)
            remove_orphans
            ;;
        4)
            show_log_size
            remove_old_logs
            ;;
        5)
            docker system df
            clean_docker_component
	    docker system df
            ;;
        6)
            inspect_and_clean_home_subdir
            ;;
        7)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done