#!/bin/bash


# Script to resolve GPG signature and database sync errors in Manjaro

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root"
    exit 1
fi


echo "🔧 Resolving GPG signature and database sync errors on Manjaro..."

# Step 1: Backup and reset GPG keyring
echo "📦 Backing up and resetting GPG keyring..."
sudo mv /etc/pacman.d/gnupg /etc/pacman.d/gnupg.bak_$(date +%F_%H-%M-%S)
sudo pacman-key --init
sudo pacman-key --populate archlinux manjaro

# Step 2: Clear cached sync databases
echo "🧹 Removing cached package database files..."
sudo rm -r /var/lib/pacman/sync

# Step 3: Reinstall keyring packages
echo "🔄 Reinstalling Arch and Manjaro keyrings..."
sudo pacman -Sy archlinux-keyring manjaro-keyring --overwrite '*'

# Step 4: Refresh mirrors and update
echo "🌐 Refreshing mirror list..."
sudo pacman-mirrors --fasttrack
echo "📥 Running full system update..."
sudo pacman -Syyu

echo "✅ Done. GPG signature and database sync problems should be resolved."
