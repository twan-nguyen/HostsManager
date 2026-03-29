#!/bin/bash
set -e

echo "=== HostsManager Build Script ==="

# Check dependencies
if ! command -v xcodegen &> /dev/null; then
    echo "Installing XcodeGen..."
    brew install xcodegen
fi

echo "1. Generating Xcode project..."
xcodegen generate

echo "2. Building universal binary..."
xcodebuild -project HostsManager.xcodeproj \
    -scheme HostsManager \
    -configuration Release \
    -derivedDataPath build \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="-" \
    build

echo ""
echo "=== Build complete! ==="
echo "App: build/Build/Products/Release/HostsManager.app"
echo ""
echo "To install: cp -R build/Build/Products/Release/HostsManager.app /Applications/"
echo "Or run: make install"
