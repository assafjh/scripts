#!/bin/bash
# This script will remove a certificate from the OS truststore
# Usage: 07-remove-certificate-from-trust.sh certificate-hash

CERTIFICATE_HASH="$1"

OS_NAME=$(uname -s)

case "$OS_NAME" in
    Linux*)
        if command -v update-ca-certificates &> /dev/null; then
            # Debian/Ubuntu
            sudo rm "/usr/local/share/ca-certificates/$CERTIFICATE_HASH.crt"
            sudo update-ca-certificates --fresh
        elif command -v update-ca-trust &> /dev/null; then
            # CentOS/RHEL
            sudo rm "/etc/pki/ca-trust/source/anchors/$CERTIFICATE_HASH.pem"
            sudo update-ca-trust
        else
            echo "Unsupported Linux distribution"
            return 1
        fi
        ;;
    Darwin*)
        # macOS
        sudo security delete-certificate -Z "$CERTIFICATE_HASH" /Library/Keychains/System.keychain
        ;;
    *)
        echo "Unsupported operating system: $OS_NAME"
        return 1
        ;;
esac

echo "Certificate with hash $CERTIFICATE_HASH removed successfully from the trust store."
