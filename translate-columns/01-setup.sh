#!/bin/bash

# Script to install Python dependencies from requirements file

# Define your requirements file
REQUIREMENTS_FILE="requirements.txt"

# Check if requirements file exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "Requirements file '$REQUIREMENTS_FILE' not found."
    exit 1
fi

# Install dependencies using pip3
echo "Installing dependencies from $REQUIREMENTS_FILE ..."
pip3 install -r "$REQUIREMENTS_FILE"

# Check pip installation status
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Failed to install dependencies. Exiting."
    exit $EXIT_CODE
fi

# Install NLTK data packages
python3 -m nltk.downloader punkt

# Check NLTK downloader status
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Failed to download NLTK data. Exiting."
    exit $EXIT_CODE
fi

echo "Dependencies installation completed successfully."
