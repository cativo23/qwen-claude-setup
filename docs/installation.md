# Installation Guide

This guide provides detailed instructions for installing and setting up the Qwen-Claude integration scripts on various Linux distributions.

## Prerequisites

Before starting the installation, ensure you have:

- A supported Linux distribution (Ubuntu, Arch, Fedora, or Debian)
- Bash shell
- Internet connection
- Administrative privileges (for package installation)
- GitHub account for Qwen OAuth setup

## Quick Installation

### Method 1: Unified Installer (Recommended)

The unified installer automatically detects your distribution and runs the appropriate setup:

```bash
# Clone the repository
git clone https://github.com/yourusername/qwen-claude-setup.git
cd qwen-claude-setup

# Make the installer executable
chmod +x install.sh

# Run the unified installer
./install.sh
```

## Post-Installation Setup

After running the installation script, you'll need to complete the Qwen OAuth setup:

1. If prompted, run `qwen` in your terminal
2. Type `/auth` to start the authentication process
3. Complete the OAuth flow in your browser
4. Type `/exit` when authentication is successful

## Verifying Installation

To verify the installation was successful:

1. Reload your shell configuration:
   ```bash
   source ~/.bashrc  # or ~/.zshrc if using zsh
   ```

2. Start the Claude Code Router:
   ```bash
   ccr start
   ```

3. Check the router status:
   ```bash
   ccr status
   ```

4. Open Claude and verify it connects to the Qwen backend:
   ```bash
   ccr code
   ```

## Troubleshooting

### Installation Fails Due to Missing Dependencies

If the installation fails due to missing dependencies, try installing them manually:

- For Ubuntu/Debian: `sudo apt install curl jq nodejs npm`
- For Arch: `sudo pacman -S curl jq nodejs npm`
- For Fedora: `sudo dnf install curl jq nodejs npm`

### Permission Denied Errors

Make sure all scripts have execute permissions:
```bash
chmod +x install.sh
chmod +x common.sh
chmod +x scripts/*.sh
chmod +x distros/*.sh
```

### Node.js Version Issues

The scripts require Node.js version 20 or higher. If you have an older version:

- Ubuntu/Debian: The script will install the required version automatically
- Arch: Install/update Node.js from the AUR
- Fedora: Update Node.js via dnf

## Next Steps

After successful installation, see [Troubleshooting](troubleshooting.md) if you run into issues.