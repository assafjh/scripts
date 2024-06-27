#!/bin/bash

# Script to install Python dependencies from requirements file

# Define your requirements file
REQUIREMENTS_FILE="requirements.txt"

# Define the path to the virtual environment
VENV_PATH="./venv"

# Check if requirements file exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "Requirements file '$REQUIREMENTS_FILE' not found."
    exit 1
fi

# Check if virtual environment exists, create it if it does not
if [ ! -d "$VENV_PATH" ]; then
    echo "Virtual environment '$VENV_PATH' not found. Creating a new one..."
    python3 -m venv "$VENV_PATH"

    # Check if creation was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual environment. Exiting."
        exit 1
    fi
    echo "Virtual environment created successfully."
fi

# Create the logs directory if it doesn't exist
mkdir -p "$LOGS_PATH"

# Activate the virtual environment
source "$VENV_PATH/bin/activate"

# Check if activation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to activate virtual environment. Exiting."
    exit 1
fi

# Install dependencies using pip
echo "Installing dependencies from $REQUIREMENTS_FILE ..."
pip install -r "$REQUIREMENTS_FILE" --progress-bar=on

# Check pip installation status
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Failed to install dependencies. Exiting."
    exit $EXIT_CODE
fi

# Install NLTK data packages
python -m nltk.downloader punkt

# Check NLTK downloader status
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Failed to download NLTK data. Exiting."
    exit $EXIT_CODE
fi

echo "Dependencies installation completed successfully."
