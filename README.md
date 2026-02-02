# Qwen-Claude Setup Scripts

A collection of scripts to set up Qwen Code + Claude Code integration on various Linux distributions.

## Overview

These scripts configure the Claude Code router to use Qwen (via portal.qwen.ai) with OAuth authentication. They support multiple Linux distributions and automate the entire setup process.

## Supported Distributions

- Ubuntu and Ubuntu-based distributions
- Arch Linux and Arch-based distributions
- Fedora
- Debian

## Prerequisites

- Bash shell
- Internet connection
- Administrative privileges (for package installation)
- GitHub account for Qwen OAuth setup

## Installation

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/qwen-claude-setup.git
cd qwen-claude-setup

# Run the unified installer (auto-detects your distribution)
./install.sh
```

## Configuration

After installation, you'll need to authenticate with Qwen:

1. If prompted, run `qwen` in your terminal
2. Type `/auth` to start the authentication process
3. Complete the OAuth flow in your browser
4. Type `/exit` when authentication is successful

## Post-Installation Steps

1. Reload your shell configuration:
   ```bash
   source ~/.bashrc  # or ~/.zshrc if using zsh
   ```

2. Start the Claude Code Router:
   ```bash
   ccr start  # or ccr code for all-in-one setup
   ```

3. If the router was already running, restart it:
   ```bash
   ccr restart
   ```

4. Open Claude as usual (it will now route through the configured Qwen backend)

## Uninstallation

To remove the setup:

```bash
./scripts/uninstall.sh
```

## Scripts Included

- `install.sh` - Unified installer that automatically detects your distribution and runs the appropriate setup from `distros/`
- `scripts/uninstall.sh` - Cleanup script to remove all configurations

## Troubleshooting

### Token Expiration

If your Qwen token expires, run:
```bash
qwen
/auth
```
Then run the setup script again.

### Permission Issues

Make sure the scripts have execute permissions:
```bash
chmod +x install.sh common.sh
chmod +x scripts/uninstall.sh
chmod +x distros/*.sh
```

### Router Connection Issues

Verify the router is running:
```bash
ccr status
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.