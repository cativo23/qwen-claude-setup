#!/bin/bash
#
# Bootstrapper for qwen-claude CLI
# Installs the tool to /usr/local/lib/qwen-claude and symlinks the binary.
#

set -Eeuo pipefail

# Colors
if [[ -t 1 ]]; then
  readonly C_GREEN='\033[0;32m'
  readonly C_RED='\033[0;31m'
  readonly C_BOLD='\033[1m'
  readonly C_RESET='\033[0m'
else
  readonly C_GREEN='' C_RED='' C_BOLD='' C_RESET=''
fi

log_info() { echo -e "${C_BOLD}[INFO]${C_RESET} $*"; }
log_ok()   { echo -e "${C_GREEN}[OK]${C_RESET} $*"; }
die()      { echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2; exit 1; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
INSTALL_DIR="/usr/local/lib/qwen-claude"
BIN_LINK="/usr/local/bin/qwen-claude"

# Check for sudo
if [[ $EUID -ne 0 ]]; then
   log_info "This script requires root privileges to install to /usr/local."
   log_info "Please run with sudo or as root."
   exit 1
fi

log_info "Installing qwen-claude to $INSTALL_DIR..."

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy files
cp -r "$SCRIPT_DIR/bin" "$INSTALL_DIR/"
cp -r "$SCRIPT_DIR/lib" "$INSTALL_DIR/"
# Copy LICENSE and README if they exist
[[ -f "$SCRIPT_DIR/LICENSE" ]] && cp "$SCRIPT_DIR/LICENSE" "$INSTALL_DIR/"
[[ -f "$SCRIPT_DIR/README.md" ]] && cp "$SCRIPT_DIR/README.md" "$INSTALL_DIR/"

# Set permissions
chmod +x "$INSTALL_DIR/bin/qwen-claude"
chmod +x "$INSTALL_DIR/lib/setup.sh" # Ensure original setup script is executable

# Create symlink
log_info "Creating symlink at $BIN_LINK..."
ln -sf "$INSTALL_DIR/bin/qwen-claude" "$BIN_LINK"

log_ok "Installation successful!"
echo ""
echo -e "You can now run setup by typing: ${C_BOLD}qwen-claude install${C_RESET}"
echo ""
