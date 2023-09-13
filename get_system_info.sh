#!/usr/bin/env bash
#Show kernel version and system architecture
uname -a

# show installed kernels
mhwd-kernel -li
# to delete linux49: sudo mhwd-kernel -r linux49

#Show name and version of distribution
head -n1 /etc/issue
cat /proc/version

#Show all partitions registered on the system
#cat /proc/partitions

#Show RAM total seen by the system
grep MemTotal /proc/meminfo

#Show CPU(s) info
grep "model name" /proc/cpuinfo

#Show info about disk sda
#hdparm -i /dev/sda
sudo lshw
cat /proc/cpuinfo

# memory
free -h

# get pc temperature
sensors

# get information of the RAM memory slots
sudo dmidecode --type 17

sudo lshw -short -C memory