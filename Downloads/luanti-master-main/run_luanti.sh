#!/bin/zsh

# --- 1. Install dependencies (only first time)
echo "Installing Homebrew dependencies..."
brew install cmake freetype gettext gmp hiredis jpeg-turbo jsoncpp leveldb libogg libpng libvorbis luajit zstd sdl2 openal-soft

# --- 2. Go to source folder
cd ~/Downloads/luanti-master-main || exit

# --- 3. Create a clean build folder
echo "Creating build folder..."
rm -rf build
mkdir build
cd build || exit

# --- 4. Configure build with CMake
echo "Configuring build..."
cmake .. \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DRUN_IN_PLACE=TRUE \
  -DBUILD_CLIENT=TRUE \
  -DBUILD_SERVER=TRUE \
  -DENABLE_GETTEXT=TRUE

# --- 5. Compile
echo "Building Luanti..."
make -j$(sysctl -n hw.logicalcpu)

# --- 6. Start SafeLuanti backend in background
echo "Starting SafeLuanti backend..."
cd /Users/lanazaben/Downloads/Usability-Project-main-2/backend || exit
node server.js &
BACKEND_PID=$!
sleep 2  # wait a moment for backend to start

# 7. Start server
cd /Users/lanazaben/Downloads/luanti-master-main/bin || exit
mkdir -p ../../worlds/testworld
./luantiserver --verbose --world ../../worlds/testworld &
SERVER_PID=$!
sleep 2

# 8. Open GUI client
open ./luanti

# 9. Wait
echo "Server PID: $SERVER_PID, Backend PID: $BACKEND_PID"
wait $SERVER_PID
wait $BACKEND_PID

