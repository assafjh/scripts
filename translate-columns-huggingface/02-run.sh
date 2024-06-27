#!/bin/bash

# Define the path to the virtual environment
VENV_PATH="./venv"

# Check if virtual environment exists
if [ ! -d "$VENV_PATH" ]; then
    echo "Virtual environment '$VENV_PATH' not found."
    exit 1
fi

# Activate the virtual environment
source "$VENV_PATH/bin/activate"

# Check if activation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to activate virtual environment. Exiting."
    exit 1
fi

# Run the translate.py script with the specified arguments
src/translate.py --input /mnt/d/git/translate-columns-huggingface/test.xlsx --output /mnt/d/git/translate-columns-huggingface/translated.xlsx \
--source_columns B --target_columns D \
--source_lang hu --target_lang de
