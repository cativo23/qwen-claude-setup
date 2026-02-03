#!/bin/bash
#
# debian.sh — Debian-specific setup functions for Qwen Code + Claude Code
#

readonly NODE_MIN_MAJOR=20
readonly NODESOURCE_SETUP_URL="https://deb.nodesource.com/setup_20.x"
readonly APT_PACKAGES=(curl jq)

# Debian-specific main setup function
main_setup() {
  install_dependencies
  install_npm_packages
  setup_qwen_integration
}

# Install Debian/Ubuntu-specific dependencies
install_dependencies() {
  log_step "Installing ${DISTRO^} dependencies"

  # Update package lists
  sudo apt-get update -qq

  # Install prerequisites
  sudo apt-get install -y "${APT_PACKAGES[@]}"

  # Check if Node.js meets requirements
  local need_node=false
  if ! command_exists node; then
    need_node=true
  elif ! node -e "process.exit(parseInt(process.versions.node.split('.')[0], 10) >= ${NODE_MIN_MAJOR} ? 0 : 1)" 2>/dev/null; then
    need_node=true
  fi

  if [[ "$need_node" == true ]]; then
    log_info "Node.js ${NODE_MIN_MAJOR}+ not found. Installing via NodeSource..."

    # Download to temp file (avoids issues with pipefail)
    local NODESOURCE_TMP
    NODESOURCE_TMP=$(mktemp) || die "Could not create temp file"
    curl -fsSL "$NODESOURCE_SETUP_URL" -o "$NODESOURCE_TMP" || { rm -f "$NODESOURCE_TMP"; die "Failed to download NodeSource."; }
    sudo -E bash "$NODESOURCE_TMP"
    rm -f "$NODESOURCE_TMP"
    sudo apt-get install -y nodejs
    log_ok "Node.js installed: $(node -v)"
  else
    log_ok "Node.js $(node -v)"
  fi
}

# Install npm packages for ${DISTRO^}
install_npm_packages() {
  log_step "Installing npm packages globally"

  readonly NPM_PACKAGES=(
    "@qwen-code/qwen-code@latest"
    "@anthropic-ai/claude-code"
    "@musistudio/claude-code-router"
  )

  local packages_list
  packages_list="${NPM_PACKAGES[*]}"
  log_info "Packages: $packages_list"

  if npm install -g "${NPM_PACKAGES[@]}"; then
    log_ok "npm packages installed"
  else
    die "Failed npm installation. Check permissions and connectivity."
  fi
}

# Setup Qwen integration using common functions
setup_qwen_integration() {
  local token_esc
  token_esc=$(setup_qwen_credentials)
  generate_router_config "$token_esc"
  setup_environment
  bypass_onboarding
  show_completion_summary
}