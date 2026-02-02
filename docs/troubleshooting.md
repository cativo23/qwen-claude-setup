# Troubleshooting Guide

This guide helps diagnose and resolve common issues with the Qwen-Claude setup.

## Common Issues

### Installation Fails

**Problem**: Installation script fails with permission errors.

**Solution**:
- Ensure you have administrative privileges (sudo access)
- Make sure all scripts have execute permissions:
  ```bash
  chmod +x install.sh
  chmod +x scripts/*.sh
  chmod +x distros/*.sh
  ```

**Problem**: Installation fails due to missing dependencies.

**Solution**:
- For Ubuntu/Debian: `sudo apt install curl jq nodejs npm`
- For Arch: `sudo pacman -S curl jq nodejs npm` (or install via AUR)
- For Fedora: `sudo dnf install curl jq nodejs npm`

### Authentication Issues

**Problem**: Qwen authentication fails or token is invalid.

**Solution**:
1. Run `qwen` in your terminal
2. Type `/auth` to start the authentication process
3. Complete the OAuth flow in your browser
4. Type `/exit` when authentication is successful
5. Rerun the setup script

**Problem**: OAuth token expires frequently.

**Solution**: OAuth tokens typically expire after a certain period. To refresh:
1. Run `qwen` in your terminal
2. Type `/auth` to refresh the token
3. The new token will be automatically used by the router

### Router Connection Issues

**Problem**: Claude cannot connect to the router.

**Solution**:
1. Check if the router is running:
   ```bash
   ccr status
   ```
2. If not running, start it:
   ```bash
   ccr start
   ```
3. If still having issues, restart the router:
   ```bash
   ccr restart
   ```

**Problem**: Router starts but connection times out.

**Solution**:
1. Verify the port configuration in `~/.claude-code-router/config.json`
2. Check if the port is already in use:
   ```bash
   netstat -tulpn | grep 3456
   ```
3. Try changing the port in the configuration file if there's a conflict

### Distribution Detection Issues

**Problem**: The unified installer doesn't detect your distribution correctly.

**Solution**:
1. Check which distribution is detected:
   ```bash
   cat /etc/os-release
   ```
2. The unified installer uses `distros/<id>.sh` based on detection. Ensure you run `./install.sh` from the repository root so it can find `distros/` and `common.sh`.

### Node.js Version Issues

**Problem**: Installation fails due to incorrect Node.js version.

**Solution**:
- The scripts require Node.js version 20 or higher
- Ubuntu/Debian: The script will install the required version automatically
- Arch: Install/update Node.js from the AUR
- Fedora: Update Node.js via dnf

## Diagnostic Commands

### Check Installation Status
```bash
# Verify Claude Code Router is installed
which ccr

# Check if Qwen CLI is available
which qwen

# Verify Node.js version
node --version
```

### Check Configuration Files
```bash
# Verify router configuration exists
ls -la ~/.claude-code-router/config.json

# Check Claude configuration
cat ~/.claude.json

# Verify Qwen credentials
ls -la ~/.qwen/
```

### Check Environment Variables
```bash
# Verify environment variables are set
env | grep ANTHROPIC
```

### Test Router Connection
```bash
# Check if router is listening on the configured port
nc -zv localhost 3456
```

## Log Files and Debugging

### Router Logs
Check the router logs for errors:
```bash
# If the router provides logging capability
ccr logs
```

### System Logs
Check system logs for any permission or dependency issues:
```bash
# For systemd-based systems
journalctl -xe

# For general system logs
tail -f /var/log/syslog  # Ubuntu/Debian
tail -f /var/log/messages  # Other distributions
```

## Recovery Steps

### Complete Reset
If you need to completely reset the setup:

1. Run the uninstall script:
   ```bash
   ./scripts/uninstall.sh
   ```

2. Manually remove any remaining configuration:
   ```bash
   rm -rf ~/.claude-code-router
   rm -f ~/.claude.json
   rm -rf ~/.qwen
   ```

3. Remove environment variables from your shell configuration:
   ```bash
   # Edit ~/.bashrc or ~/.zshrc and remove the ANTHROPIC_* variables
   ```

4. Reinstall using the setup script

### Partial Recovery
If only specific components are failing:

1. Restart the router: `ccr restart`
2. Re-authenticate with Qwen: Run `qwen` and `/auth`
3. Reload shell configuration: `source ~/.bashrc`
4. Verify individual components as per diagnostic commands above

## Support Information

When seeking help with issues:

1. Include your Linux distribution and version
2. Share the output of `cat /etc/os-release`
3. Include the Node.js version: `node --version`
4. Provide the error message from the installation script
5. Mention which installation method you used (unified installer or distribution-specific)