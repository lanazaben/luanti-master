# Installing Homebrew

Homebrew installation requires your administrator password and must be run in your terminal.

## Steps:

1. Open Terminal (or use your current terminal window)

2. Run this command:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. When prompted, enter your macOS password (you won't see characters as you type)

4. Wait for the installation to complete (this may take a few minutes)

5. After installation, if you're on Apple Silicon (M1/M2/M3), you may need to add Homebrew to your PATH:
   ```bash
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
   source ~/.zshrc
   ```
   
   If you're on Intel Mac, it should already be in your PATH.

6. Verify installation:
   ```bash
   brew --version
   ```

7. Once Homebrew is installed, you can run the build script:
   ```bash
   cd /Users/lanazaben/Downloads/luanti-master
   ./build_game.sh
   ```

The build script will automatically install all required dependencies and build the game.






