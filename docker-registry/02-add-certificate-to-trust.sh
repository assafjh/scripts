#!/bin/bash
# This script will add the generated rootCA to the OS truststore

#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#================ Variables ==============
CERTIFICATE_FILE_PATH="$SCRIPT_DIR/certs/registry/docker-registry.crt"

#================ Script ==============
if [[ ! -f "$CERTIFICATE_FILE_PATH" ]]; then
    echo "Certificate file not found: $CERTIFICATE_FILE_PATH"
    return 1
fi

OS_NAME=$(uname -s)

case "$OS_NAME" in
    Linux*)
        if command -v update-ca-certificates &> /dev/null; then
            # Debian/Ubuntu
            sudo cp "$CERTIFICATE_FILE_PATH" /usr/local/share/ca-certificates/
            sudo update-ca-certificates
        elif command -v update-ca-trust &> /dev/null; then
            # CentOS/RHEL
            sudo cp "$CERTIFICATE_FILE_PATH" /etc/pki/ca-trust/source/anchors/
            sudo update-ca-trust
        else
            echo "Unsupported Linux distribution"
            return 1
        fi
        ;;
    Darwin*)
        # macOS
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERTIFICATE_FILE_PATH"
        ;;
    *)
        echo "Unsupported operating system: $OS_NAME"
        return 1
        ;;
esac

echo "Certificate added successfully to the trust store."

