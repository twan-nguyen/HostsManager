#!/bin/bash
set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./scripts/update-homebrew.sh <version> <sha256>"
    exit 1
fi

VERSION=$1
SHA256=$2
CASK_FILE="homebrew/Casks/hostsmanager.rb"

sed -i '' "s/version \".*\"/version \"${VERSION}\"/" "$CASK_FILE"
sed -i '' "s/sha256 \".*\"/sha256 \"${SHA256}\"/" "$CASK_FILE"

echo "Updated ${CASK_FILE} to v${VERSION} (sha256: ${SHA256})"
