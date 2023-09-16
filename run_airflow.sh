#!/bin/bash
# Script to run Apache Airflow on the desired port

# Function to check if a port is available
is_port_available() {
    if ss -tuln | grep -q "LISTEN.*:$1"; then
        return 1 # Port is in use
    else
        return 0 # Port is available
    fi
}

# Function to run Apache Airflow on the desired port
run_airflow() {
    if is_port_available "$1"; then
        echo "Port $1 is available. Starting Apache Airflow..."
        echo "Go to http://0.0.0.0:$1"
        airflow webserver --port "$1"
    else
        echo "Port $1 is already in use. Unable to start Apache Airflow."
    fi
}

# Change the desired port number accordingly
desired_port=8081

# Activate the virtual environment for Apache Airflow
#source venv_airflow/bin/activate

# Run Apache Airflow on the desired port
run_airflow "$desired_port"
