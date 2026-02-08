#!/bin/bash

# Installation script for repolicense-cli
# This script helps you install Zig and build the project

set -e

echo "=== Repolicense CLI Installation ==="
echo ""

# Check if Zig is already installed
if command -v zig &> /dev/null; then
    ZIG_VERSION=$(zig version)
    echo "✓ Zig is already installed: $ZIG_VERSION"
else
    echo "✗ Zig is not installed"
    echo ""
    echo "Please install Zig from: https://ziglang.org/download/"
    echo ""
    echo "Recommended methods:"
    echo "1. Download pre-built binary from https://ziglang.org/download/"
    echo "2. Use a package manager:"
    echo "   - macOS: brew install zig"
    echo "   - Linux: Check your distribution's package manager"
    echo "   - Windows: Use scoop or chocolatey"
    echo ""
    exit 1
fi

echo ""
echo "Building repolicense-cli..."
zig build

echo ""
echo "✓ Build complete!"
echo ""
echo "Run the program with:"
echo "  ./zig-out/bin/repolicense"
echo ""
echo "Or:"
echo "  zig build run"
