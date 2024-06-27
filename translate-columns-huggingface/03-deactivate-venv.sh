#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [--cleanup]"
    echo "  --cleanup  Optional flag to delete the virtual environment after deactivation"
    exit 1
}

# Check if a virtual environment is active
if [ -z "$VIRTUAL_ENV" ]; then
    echo "No virtual environment is currently active."
    exit 1
fi

# Deactivate the virtual environment
deactivate

echo "Virtual environment deactivated successfully."

# Check for optional --cleanup flag
if [ "$1" == "--cleanup" ]; then
    # Define the path to the virtual environment
    VENV_PATH="$VIRTUAL_ENV"

    # Confirm deletion with the user
    read -p "Are you sure you want to delete the virtual environment at '$VENV_PATH'? [y/N] " confirmation
    case "$confirmation" in
        [yY][eE][sS]|[yY])
            rm -rf "$VENV_PATH"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to delete the virtual environment. Exiting."
                exit 1
            fi
            echo "Virtual environment deleted successfully."
            ;;
        *)
            echo "Cleanup cancelled."
            ;;
    esac
fi
