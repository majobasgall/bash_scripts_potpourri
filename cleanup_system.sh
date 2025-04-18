#!/bin/bash

# Script Name: cleanup_system.sh
# Author: @majobasgall
# Version: 2.0
# Description: This script checks and cleans unused packages or files in Arch Linux systems.

bold_fuchsia() {
    echo -e "\e[1;35m$1\e[0m"
}

bold_green() {
    echo -e "\e[1;32m$1\e[0m"
}

bold_turquoise() {
    echo -e "\e[1;36m$1\e[0m"
}

bold_yellow() {
    echo -e "\e[1;33m$1\e[0m"
}

bold_red() {
    echo -e "\e[1;31m$1\e[0m"
}

# Function to check pacman locks
check_pacman_lock() {
    local lock_file="/var/lib/pacman/db.lck"
    
    if [ -f "$lock_file" ]; then
        bold_red "Error: Pacman database is locked!"
        bold_yellow "Please wait for any running pacman processes to complete or remove the lock file manually."
        bold_yellow "Lock file location: $lock_file"
        return 1
    fi
    return 0
}

# Display disk usage in human-readable format.
show_disk_usage() {
  du -sh "$1"
}

purge_pacman_cache() {
    # Check for pacman lock before proceeding
    if ! check_pacman_lock; then
        return 1
    fi

    # Define the maximum number of versions to keep (adjust as needed).
    MAX_VERSIONS=1

    # Define the package cache path
    CACHE_PATH="/var/cache/pacman/pkg/"

    # Display the space used by the package cache before cleanup.
    bold_fuchsia "Space used by package cache before cleanup:"
    show_disk_usage $CACHE_PATH

    # Remove unused packages, keeping the specified number of versions.
    paccache -rk$MAX_VERSIONS

    # Display the space used by the package cache after cleanup.
    bold_fuchsia "Space used by package cache after cleanup:"
    show_disk_usage $CACHE_PATH

    # Display a summary of the cleaned packages.
    # paccache -ruk0
}

# Function to display the installed kernels and ask the user which one to delete
select_and_remove_kernel() {
    bold_fuchsia "Installed Kernels:"
    mhwd-kernel -li
    
    echo -e "\n$(bold_turquoise)Kernel Removal Options:"
    echo "0. Do not remove any kernel (exit)"
    echo "1. Enter kernel version to remove"
    
    read -p "$(bold_fuchsia)Select an option (0-1): " choice
    
    case $choice in
        0)
            bold_green "No kernel will be removed."
            return 0
            ;;
        1)
            read -p "Enter the kernel version you want to remove (e.g., linux49): " kernel_version
            if [[ -n "$kernel_version" ]]; then
                bold_fuchsia "You are about to remove kernel: $kernel_version"
                read -p "Are you sure you want to proceed? (Y/n): " confirm
                if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
                    sudo mhwd-kernel -r $kernel_version
                    if [ $? -eq 0 ]; then
                        bold_green "Kernel $kernel_version removed successfully."
                    else
                        bold_red "Failed to remove kernel $kernel_version."
                    fi
                else
                    bold_yellow "Kernel removal cancelled."
                fi
            else
                bold_red "No kernel version specified."
            fi
            ;;
        *)
            bold_red "Invalid option selected."
            ;;
    esac
}

# Function to check and purge old cache files
purge_home_cache() {
    read -p "Enter the maximum age of cache files to delete (in days): " max_age

    if [[ -n "$max_age" ]]; then
        bold_fuchsia "Purging cache files older than $max_age days..."
        find ~/.cache/ -type f -atime +$max_age -delete
    fi
}

# Function to remove orphaned packages
remove_orphans() {
    # Check for pacman lock before proceeding
    if ! check_pacman_lock; then
        return 1
    fi

    orphans=$(pacman -Qdtq)

    if [ -z "$orphans" ]; then
        bold_fuchsia "No orphaned packages found."
    else
        bold_fuchsia "Removing orphaned packages..."
        sudo pacman -Rns $orphans
    fi
}

# Function to display the size of /var/log directory
show_log_size() {
    log_size=$(sudo du -sh /var/log | awk '{print $1}')
    bold_fuchsia "Size of /var/log: $log_size"
}

# Function to remove old log files
remove_old_logs() {
    read -p "Enter the maximum age of log files to delete (in days): " max_age

    if [[ -n "$max_age" ]]; then
        bold_fuchsia "Removing log files older than $max_age days..."
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

# System Journal Cleanup
clean_system_journal() {
    bold_fuchsia "Current journal size:"
    journalctl --disk-usage
    read -p "Do you want to clean system journal? (Y/n): " clean_journal
    if [[ "$clean_journal" == "Y" || "$clean_journal" == "y" ]]; then
        sudo journalctl --vacuum-time=2weeks
        bold_green "System journal cleaned."
        bold_fuchsia "New journal size:"
        journalctl --disk-usage
    fi
}

# Thumbnail Cache Cleanup
clean_thumbnail_cache() {
    bold_fuchsia "Current thumbnail cache size:"
    show_disk_usage ~/.cache/thumbnails
    read -p "Do you want to clean thumbnail cache? (Y/n): " clean_thumbnails
    if [[ "$clean_thumbnails" == "Y" || "$clean_thumbnails" == "y" ]]; then
        rm -rf ~/.cache/thumbnails/*
        bold_green "Thumbnail cache cleaned."
        bold_fuchsia "New thumbnail cache size:"
        show_disk_usage ~/.cache/thumbnails
    fi
}

# Temporary Files Cleanup
clean_temp_files() {
    bold_fuchsia "Current /tmp size:"
    show_disk_usage /tmp
    bold_fuchsia "Current trash size:"
    show_disk_usage ~/.local/share/Trash
    read -p "Do you want to clean temporary files? (Y/n): " clean_temp
    if [[ "$clean_temp" == "Y" || "$clean_temp" == "y" ]]; then
        sudo rm -rf /tmp/*
        rm -rf ~/.local/share/Trash/*
        bold_green "Temporary files cleaned."
        bold_fuchsia "New /tmp size:"
        show_disk_usage /tmp
        bold_fuchsia "New trash size:"
        show_disk_usage ~/.local/share/Trash
    fi
}

# Old Configuration Files Cleanup
clean_old_configs() {
    bold_fuchsia "Searching for old configuration files..."
    total_size=0
    file_count=0
    while read file; do
        size=$(du -sb "$file" | cut -f1)
        total_size=$((total_size + size))
        file_count=$((file_count + 1))
    done < <(find ~ -name "*.old" -o -name "*.bak" -o -name "*.backup")
    
    bold_fuchsia "Found $file_count old configuration files"
    bold_fuchsia "Total size: $(numfmt --to=iec $total_size)"
    
    read -p "Do you want to review and delete these files? (Y/n): " review_files
    if [[ "$review_files" == "Y" || "$review_files" == "y" ]]; then
        find ~ -name "*.old" -o -name "*.bak" -o -name "*.backup" | while read file; do
            size=$(du -sh "$file" | cut -f1)
            echo "Found: $file (Size: $size)"
            read -p "Delete this file? (Y/n): " delete_file
            if [[ "$delete_file" == "Y" || "$delete_file" == "y" ]]; then
                rm -f "$file"
                bold_green "Deleted: $file"
            fi
        done
    fi
}

# Unused Locale Cleanup
clean_unused_locales() {
    bold_fuchsia "Current locale size:"
    localedef --list-archive | wc -l
    bold_fuchsia "Current locale directory size:"
    show_disk_usage /usr/share/locale
    read -p "Do you want to remove unused locales? (Y/n): " clean_locales
    if [[ "$clean_locales" == "Y" || "$clean_locales" == "y" ]]; then
        sudo localepurge
        bold_green "Unused locales removed."
        bold_fuchsia "New locale directory size:"
        show_disk_usage /usr/share/locale
    fi
}

# Browser Cache Cleanup
clean_browser_cache() {
    # Function to check and show browser cache size
    check_browser_cache() {
        local browser_name=$1
        local cache_path=$2
        if [ -d "$cache_path" ]; then
            bold_fuchsia "$browser_name cache size:"
            show_disk_usage "$cache_path"
            return 0
        fi
        return 1
    }

    # Function to clean browser cache
    clean_browser() {
        local browser_name=$1
        local cache_path=$2
        if [ -d "$cache_path" ]; then
            read -p "Do you want to clean $browser_name cache? (Y/n): " clean_browser
            if [[ "$clean_browser" == "Y" || "$clean_browser" == "y" ]]; then
                rm -rf "$cache_path"/*
                bold_green "$browser_name cache cleaned."
                bold_fuchsia "New $browser_name cache size:"
                show_disk_usage "$cache_path"
            fi
        fi
    }

    # Define browser paths
    declare -A browsers=(
        ["Firefox"]="$HOME/.mozilla/firefox/*.default-release/cache"
        ["Chromium"]="$HOME/.cache/chromium/Default/Cache"
        ["Chrome"]="$HOME/.cache/google-chrome/Default/Cache"
        ["Brave"]="$HOME/.cache/BraveSoftware/Brave-Browser/Default/Cache"
    )

    # Show sizes for all installed browsers
    bold_fuchsia "Current browser cache sizes:"
    for browser in "${!browsers[@]}"; do
        check_browser_cache "$browser" "${browsers[$browser]}"
    done

    # Clean each browser individually
    for browser in "${!browsers[@]}"; do
        clean_browser "$browser" "${browsers[$browser]}"
    done
}

# Package Cache Size Limit
set_pacman_cache_limit() {
    bold_fuchsia "Current pacman cache size:"
    show_disk_usage /var/cache/pacman/pkg
    read -p "Enter maximum cache size in MB (e.g., 2048): " cache_size
    if [[ -n "$cache_size" ]]; then
        sudo sed -i "s/#CacheDir.*/CacheDir    = \/var\/cache\/pacman\/pkg/" /etc/pacman.conf
        sudo sed -i "/CacheDir/a CleanMethod = KeepSize" /etc/pacman.conf
        sudo sed -i "/CleanMethod/a CleanSize = $cache_size" /etc/pacman.conf
        bold_green "Pacman cache size limit set to ${cache_size}MB"
        bold_fuchsia "New pacman cache size:"
        show_disk_usage /var/cache/pacman/pkg
    fi
}

while true; do
    bold_fuchsia "Clean Up Space System Menu"
    bold_turquoise "0. Clean up Pacman Cache"
    bold_turquoise "1. Remove Kernels"
    bold_turquoise "2. Purge Home Cache Files"
    bold_turquoise "3. Remove Orphaned Packages"
    bold_turquoise "4. Show /var/log Size and Remove Old Logs"
    bold_turquoise "5. Clean up Docker components"
    bold_turquoise "6. Inspect and Clean /home Subdirs"
    bold_turquoise "7. Clean System Journal"
    bold_turquoise "8. Clean Thumbnail Cache"
    bold_turquoise "9. Clean Temporary Files"
    bold_turquoise "10. Clean Old Configuration Files"
    bold_turquoise "11. Clean Unused Locales"
    bold_turquoise "12. Clean Browser Cache"
    bold_turquoise "13. Set Pacman Cache Size Limit"
    bold_turquoise "14. Quit"

    read -p "$(bold_fuchsia)Select an option (0-14): " choice

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
            clean_system_journal
            ;;
        8)
            clean_thumbnail_cache
            ;;
        9)
            clean_temp_files
            ;;
        10)
            clean_old_configs
            ;;
        11)
            clean_unused_locales
            ;;
        12)
            clean_browser_cache
            ;;
        13)
            set_pacman_cache_limit
            ;;
        14)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done