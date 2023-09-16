#!/bin/bash
# Script to install and set up Apache Superset

# Create and activate the virtual environment for Superset
python -m venv venv_superset
source venv_superset/bin/activate

# Install Superset and required packages (I had dependencies problems)
pip install apache-superset
pip install sqlparse=='0.4.3'
pip install marshmallow_enum

# Generate SECRET_KEY using openssl and save it in superset_config.py
SECRET_KEY=$(openssl rand -base64 42)
echo "SECRET_KEY = '${SECRET_KEY}'" > venv_superset/bin/superset_config.py

# Initialize Superset and create the first admin user
superset db upgrade
superset init
superset fab create-admin

# Set the environment variables
export FLASK_APP=superset
export FLASK_ENV=development

superset load_examples

# Run Superset
superset run
