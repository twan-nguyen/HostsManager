#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/release.sh <version>"
    echo "Example: ./scripts/release.sh 1.2.0"
    exit 1
fi

VERSION=$1

echo "=== Releasing Hosven v${VERSION} ==="

# Update MARKETING_VERSION (user-facing) in project.yml — preserve trailing
# release-please marker comment so auto-release tooling stays in sync.
sed -i '' "s/MARKETING_VERSION: \"[^\"]*\"/MARKETING_VERSION: \"${VERSION}\"/" project.yml

# Update CURRENT_PROJECT_VERSION (CFBundleVersion) — must change per release so
# Sparkle's generate_appcast treats each release as a new entry (it keys on
# CFBundleVersion). Without this bump, appcast.xml fails to embed edSignature.
sed -i '' "s/CURRENT_PROJECT_VERSION: \"[^\"]*\"/CURRENT_PROJECT_VERSION: \"${VERSION}\"/" project.yml

# Update version in Makefile (line is bracketed by release-please block markers,
# safe to replace the whole line since markers live on neighbouring lines).
sed -i '' "s/^VERSION = .*/VERSION = ${VERSION}/" Makefile

# Update release-please manifest so the next push-to-master cycle uses this
# version as the new baseline (otherwise release-please would try to bump from
# the stale version and create a conflicting Release PR).
if [ -f .release-please-manifest.json ]; then
    sed -i '' "s/\"\\.\": \"[^\"]*\"/\"\\.\": \"${VERSION}\"/" .release-please-manifest.json
fi

# Verify versions were updated
if ! grep -q "MARKETING_VERSION: \"${VERSION}\"" project.yml; then
    echo "ERROR: Failed to update MARKETING_VERSION in project.yml"
    exit 1
fi

if ! grep -q "CURRENT_PROJECT_VERSION: \"${VERSION}\"" project.yml; then
    echo "ERROR: Failed to update CURRENT_PROJECT_VERSION in project.yml"
    exit 1
fi

if ! grep -q "^VERSION = ${VERSION}" Makefile; then
    echo "ERROR: Failed to update version in Makefile"
    exit 1
fi

if [ -f .release-please-manifest.json ] && ! grep -q "\"${VERSION}\"" .release-please-manifest.json; then
    echo "ERROR: Failed to update .release-please-manifest.json"
    exit 1
fi

echo "✓ Updated project.yml, Makefile, manifest to v${VERSION}"

# Commit version files
git add project.yml Makefile .release-please-manifest.json
git commit -m "chore: release v${VERSION}"
git tag -a "v${VERSION}" -m "Release v${VERSION}"

echo "✓ Created commit and tag v${VERSION}"

# Push
git push origin master --tags

echo ""
echo "=== Done! ==="
echo "GitHub Actions will:"
echo "  1. Build universal binary"
echo "  2. Create GitHub Release with ZIP + DMG"
echo "  3. Update Homebrew tap automatically"
echo ""
echo "Track progress: gh run list --limit 1"
