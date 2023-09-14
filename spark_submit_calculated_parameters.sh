#!/usr/bin/env bash

# Script to automatically calculate Spark configuration parameters based on available hardware resources of a cluster.
# Prerequisite: 'lscpu' and 'free' commands
# NOTE: This script was originally created in 2019, and some parameter recommendations may be outdated.
# IMPORTANT: Use this script as a general guideline, but before running, verify the current available resources in
# your cluster for accurate configuration.

# Function to print usage instructions
usage() {
  echo "Usage: $0"
  echo "Calculate Spark configuration parameters based on available cluster resources."
}

# Check if no arguments are provided
if [ $# -ne 0 ]; then
  usage
  exit 1
fi

# Function to calculate executor memory
calculate_executor_memory() {
  local total_ram_per_node="$1"
  local num_of_executors_per_node="$2"

  # Calculate memory per executor
  local mem_per_executor=$((total_ram_per_node / num_of_executors_per_node))

  # Calculate off-heap overhead (7% of memory)
  local off_heap_overhead=$((mem_per_executor / 7))

  # Calculate executor memory (minus off-heap overhead)
  local executor_memory=$((mem_per_executor - off_heap_overhead))

  echo "$executor_memory"
}

# Retrieve system information using 'lscpu' and 'free' commands
total_nodes_in_cluster=$(lscpu | grep "CPU(s):" | awk '{print $2}')
total_cores_per_node=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')
total_ram_per_node=$(free -g | grep "Mem:" | awk '{print $2}')

# Constants
CORES_PER_EXECUTOR=5
HADOOP_DAEMONS_CORE=1

# Check if required values are not empty
if [ -z "$total_nodes_in_cluster" ] || [ -z "$total_cores_per_node" ] || [ -z "$total_ram_per_node" ]; then
  echo "Error: Unable to retrieve system information. Check if 'lscpu' and 'free' commands are available."
  exit 1
fi

# Calculate available resources per node
available_cores_per_node=$((total_cores_per_node - HADOOP_DAEMONS_CORE))
available_cores_in_cluster=$((available_cores_per_node * total_nodes_in_cluster))

# Debugging: Print the calculated values for debugging
echo "Debug Information:"
echo "-----------------"
echo "Total Nodes in Cluster: $total_nodes_in_cluster"
echo "Cores per Node: $total_cores_per_node"
echo "Available Cores per Node: $available_cores_per_node"
echo "Available Cores in Cluster: $available_cores_in_cluster"
echo "-----------------"

# Check if the calculated value is non-zero
if [ -z "$available_cores_in_cluster" ] || [ "$available_cores_in_cluster" -lt 1 ]; then
  echo "Error: No available cores detected. Check your system configuration."
  exit 1
fi

# Calculate available executors (leave 1 for ApplicationManager)
available_executors=$((available_cores_in_cluster / CORES_PER_EXECUTOR - 1))

# Calculate executors per node
num_of_executors_per_node=$((available_executors / total_nodes_in_cluster))

# Calculate executor memory
executor_memory=$(calculate_executor_memory "$total_ram_per_node" "$num_of_executors_per_node")

# Print Spark configuration parameters
echo "Spark Configuration Parameters:"
echo "--------------------------------"
echo "Number of Nodes in Cluster: $total_nodes_in_cluster"
echo "Cores per Node: $total_cores_per_node"
echo "Total RAM per Node (GB): $total_ram_per_node"
echo "Available Cores in Cluster: $available_cores_in_cluster"
echo "Available Executors: $available_executors"
echo "Executors per Node: $num_of_executors_per_node"
echo "Executor Cores: $CORES_PER_EXECUTOR"
echo "Executor Memory (GB): $executor_memory"
echo "--------------------------------"

# Display the Spark submit command with calculated parameters
echo -e "\nSpark Submit Command:"
echo "---------------------"
echo "spark-submit --class <CLASS_NAME> --num-executors ${available_executors} --executor-cores ${CORES_PER_EXECUTOR} --executor-memory ${executor_memory}G ..."
echo "---------------------"