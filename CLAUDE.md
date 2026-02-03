# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Linux shell script-based project that integrates Qwen AI's free-tier API with Claude Code, allowing developers to use Claude's interface with Qwen's backend for free (up to 2,000 requests/day). The project provides a unified installer that works across multiple Linux distributions.

## Architecture & Key Components

### Main Scripts
- `install.sh` - Primary entry point that detects Linux distribution and runs appropriate setup
- `common.sh` - Shared functions used across all distributions
- `distros/*.sh` - Distribution-specific installation scripts (debian.sh, arch.sh, fedora.sh)
- `scripts/uninstall.sh` - Removes all configurations and settings

### Core Features
- **Distribution Detection**: Automatically identifies Linux distribution via `/etc/os-release`
- **Package Management**: Handles different package managers (apt for Debian/Ubuntu, yay/paru for Arch, dnf for Fedora)
- **OAuth Integration**: Manages Qwen authentication and token extraction
- **Router Configuration**: Sets up Claude Code Router with proper Qwen API integration
- **Environment Setup**: Configures shell environment variables

### Configuration Management
- Creates `~/.claude-code-router/config.json` with Qwen API settings
- Sets environment variables (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`)
- Handles credential security with proper file permissions (chmod 600)

### Special Feature: Transformer Plugin
The project includes a sophisticated JavaScript transformer (`plugins/qwen-transformer.js`) that solves a critical compatibility issue:
- **Problem**: Claude CLI sends tools in PascalCase (`WebSearch`) but Qwen expects snake_case (`web_search`)
- **Solution**: The transformer acts as middleware to convert between formats in both directions
- **Additional Feature**: Adds system prompt reminders to help Qwen use its tools effectively

## Development Commands

### Installation
```bash
# Clone and run the installer
git clone https://github.com/cativo23/qwen-claude-setup.git
cd qwen-claude-setup
chmod +x install.sh common.sh distros/*.sh scripts/uninstall.sh
./install.sh
```

### Post-installation
```bash
# Reload your shell
source ~/.bashrc   # or source ~/.zshrc

# Start the router
ccr start          # or ccr code for the full experience
```

### Uninstallation
```bash
# Remove all configurations (does not remove system packages)
./scripts/uninstall.sh
```

### Testing
```bash
# Test the WebSearch tool conversion functionality
./scripts/test_qwen_tools.sh
```

## Key Technical Solutions

### Cross-Distribution Support
The project uses a modular approach where:
- `install.sh` detects the distribution
- Distribution-specific scripts handle package installation
- Common functions in `common.sh` handle authentication, configuration, and setup

### OAuth Token Management
- Extracts tokens from `~/.qwen/oauth_creds.json`
- Handles systems with or without `jq` for JSON parsing
- Implements proper JSON escaping for security

### Environment Variable Management
- Adds environment variables to shell configuration files (`.bashrc` or `.zshrc`)
- Prevents duplicate entries with existence checks
- Configures Claude to use the local router instead of Anthropic's servers

## Security Considerations
- Sets restrictive file permissions (600) on credential files
- Proper JSON escaping to prevent injection attacks
- Secure storage of OAuth tokens

## Troubleshooting

### Token Issues
If authentication token expires:
1. Run `qwen` → `/auth` in browser → `/exit`
2. Rerun the installer script

### Port Issues
- Router default port: 3456
- Check if port is available: `nc -z localhost 3456`

### Environment Variables
After installation, ensure your shell environment is properly configured:
- Verify `ANTHROPIC_BASE_URL` points to `http://127.0.0.1:3456`
- Verify `ANTHROPIC_AUTH_TOKEN` is set to dummy value