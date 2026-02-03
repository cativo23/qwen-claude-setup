# Qwen-Claude Setup - Project Context

## Project Overview

Qwen-Claude Setup is a collection of bash scripts designed to simplify the installation and configuration of Qwen Code and Claude Code on Linux systems. The project provides a unified setup solution that automatically detects the Linux distribution and performs the appropriate installation steps for Qwen Code, Claude Code, and the Claude Code Router.

The project integrates Qwen's API access (using OAuth) with Claude Code through a router, allowing users to access Qwen's capabilities through Claude's interface. It supports major Linux distributions including Ubuntu, Debian, Arch, and Fedora.

### Main Technologies
- **Shell Scripting**: Bash-based installation and configuration scripts
- **Node.js**: Runtime environment for Qwen Code, Claude Code, and Claude Code Router
- **OAuth Integration**: Secure authentication with Qwen's API services
- **Configuration Management**: Automated setup of environment variables and router configuration

### Architecture
The project follows a modular architecture:
- `install.sh`: Main entry point that detects the distribution and delegates to the appropriate setup script
- `common.sh`: Shared functions used across all distribution-specific scripts
- `distros/`: Distribution-specific installation scripts (e.g., `arch.sh`, `debian.sh`)
- `scripts/`: Utility scripts including the uninstaller
- `plugins/`: JavaScript transformer plugin for API compatibility
- `docs/`: Documentation files

## Building and Running

### Installation Process
1. Clone the repository:
   ```bash
   git clone https://github.com/cativo23/qwen-claude-setup.git
   cd qwen-claude-setup
   ```

2. Make scripts executable:
   ```bash
   chmod +x install.sh common.sh distros/*.sh scripts/uninstall.sh
   ```

3. Run the installer:
   ```bash
   ./install.sh
   ```

The installer automatically detects your Linux distribution and runs the appropriate setup script from the `distros/` directory.

### Post-Installation Steps
1. Reload your shell configuration:
   ```bash
   source ~/.bashrc   # or source ~/.zshrc
   ```

2. Authenticate with Qwen (if not done during installation):
   ```bash
   qwen
   # Type: /auth
   # Complete authentication in browser
   # Type: /exit
   ```

3. Start the Claude Code Router:
   ```bash
   ccr start
   ```

### Uninstallation
To remove the setup completely:
```bash
./scripts/uninstall.sh
```

This removes configuration files, environment variables, and optionally the installed packages, though system packages remain (to be removed separately).

## Development Conventions

### Script Structure and Patterns
- Use strict error handling: `set -Eeuo pipefail`
- Implement consistent logging with colored output
- Use readonly variables for constants
- Source common functionality from `common.sh`
- Follow a modular approach with distribution-specific modules

### Error Handling
- Use `die()` function for fatal errors with appropriate exit codes
- Validate prerequisites before proceeding with installation
- Implement proper permission checking for configuration files

### Configuration Management
- Store router configuration in `~/.claude-code-router/config.json`
- Store authentication credentials in `~/.qwen/oauth_creds.json`
- Automatically manage environment variables in `~/.bashrc` or `~/.zshrc`
- Maintain proper file permissions (especially for credential files)

### OAuth Integration
- Use Qwen's OAuth system for API access
- Store credentials securely with restricted permissions (600)
- Handle token extraction and validation gracefully
- Provide clear instructions for manual authentication when needed

## Key Features

### Distribution Support
- Automatic detection of Ubuntu, Debian, Arch, and Fedora
- Proper handling of different package managers (apt, pacman, dnf)
- AUR helper support (yay/paru) for Arch-based systems

### Router Configuration
- Automatically generates Claude Code Router configuration
- Configures Qwen as the primary provider with proper API endpoint
- Includes transformer plugin for API compatibility
- Sets up environment variables for Claude integration

### Security and Permissions
- Restricts permissions on credential files (600)
- Secure handling of OAuth tokens
- Automatic cleanup of sensitive information

### Modular Design
- Shared functionality in `common.sh`
- Distribution-specific modules in `distros/`
- Plugin system for API transformations
- Easy extensibility for new distributions

## Usage Tips

### For Users
- Run `./install.sh` for automatic setup
- Follow the authentication prompts when installing
- Use `ccr start` to start the router service
- Reload shell configuration after installation

### For Developers
- Add new distribution support by creating a new script in `distros/`
- Use functions from `common.sh` to maintain consistency
- Follow the existing patterns for error handling and logging
- Test thoroughly on the target distribution before submitting changes

### Troubleshooting
- Check distribution detection by examining `/etc/os-release`
- Verify Node.js version (requires v20+)
- Confirm OAuth token validity
- Check router configuration at `~/.claude-code-router/config.json`
- Review environment variables in your shell configuration file