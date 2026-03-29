#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/release.sh <version>"
    echo "Example: ./scripts/release.sh 1.0.0"
    exit 1
fi

VERSION=$1

echo "=== Releasing HostsManager v${VERSION} ==="

# Update version in project.yml
sed -i '' "s/MARKETING_VERSION: .*/MARKETING_VERSION: \"${VERSION}\"/" project.yml

# Update version in Makefile
sed -i '' "s/^VERSION = .*/VERSION = ${VERSION}/" Makefile

# Commit and tag
git add -A
git commit -m "chore: release v${VERSION}"
git tag -a "v${VERSION}" -m "Release v${VERSION}"
git push origin main --tags

echo "=== Done! GitHub Actions will create the release ==="
