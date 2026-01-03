#!/bin/bash
# Build script for Luanti on macOS
# This script will build the game after dependencies are installed

set -e  # Exit on error

echo "=== Luanti Build Script ==="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "ERROR: Homebrew is not installed!"
    echo ""
    echo "Please install Homebrew first by running:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    echo "After installation, add Homebrew to your PATH if needed:"
    echo "  echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zshrc"
    echo "  source ~/.zshrc"
    exit 1
fi

echo "✓ Homebrew found"
echo ""

# Install dependencies
echo "Installing dependencies with Homebrew..."
brew install cmake freetype gettext gmp hiredis jpeg-turbo jsoncpp leveldb libogg libpng libvorbis luajit zstd sdl2 openal-soft

echo ""
echo "✓ Dependencies installed"
echo ""

# Create build directory
echo "Setting up build directory..."
cd "$(dirname "$0")"
mkdir -p build
cd build

# Configure with CMake
echo "Configuring with CMake..."
cmake .. \
    -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_INSTALL_PREFIX=../build/macos/ \
    -DRUN_IN_PLACE=FALSE \
    -DENABLE_GETTEXT=TRUE

echo ""
echo "✓ Configuration complete"
echo ""

# Build
echo "Building the game (this may take a while)..."
make -j$(sysctl -n hw.logicalcpu)

echo ""
echo "✓ Build complete"
echo ""

# Install
echo "Installing..."
make install

echo ""
echo "✓ Installation complete"
echo ""

# Sign the app (required on Apple Silicon Macs)
if [[ $(uname -m) == "arm64" ]]; then
    echo "Signing app for Apple Silicon..."
    codesign --force --deep -s - --entitlements ../misc/macos/entitlements/debug.entitlements macos/luanti.app
    echo "✓ App signed"
    echo ""
fi

echo "=== Build Complete! ==="
echo ""
echo "To run the game, use:"
echo "  open ./build/macos/luanti.app"
echo ""
echo "Or from the build directory:"
echo "  open macos/luanti.app"
echo ""





