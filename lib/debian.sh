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
  log_info "Updating apt repositories..."
  sudo apt-get update -qq

  # Install prerequisites
  echo -e "  Installing prerequisites: ${C_CYAN}${APT_PACKAGES[*]}${C_RESET}"
  sudo apt-get install -y "${APT_PACKAGES[@]}" > /dev/null

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
    
    echo -e "  Downloading NodeSource setup script..."
    curl -fsSL "$NODESOURCE_SETUP_URL" -o "$NODESOURCE_TMP" || { rm -f "$NODESOURCE_TMP"; die "Failed to download NodeSource."; }
    
    log_info "Running setup script..."
    sudo -E bash "$NODESOURCE_TMP" > /dev/null
    rm -f "$NODESOURCE_TMP"
    
    echo -e "  Installing package: ${C_CYAN}nodejs${C_RESET}"
    sudo apt-get install -y nodejs > /dev/null
    log_ok "Node.js installed: ${C_GREEN}$(node -v)${C_RESET}"
  else
    log_ok "Node.js version satisfied: ${C_GREEN}$(node -v)${C_RESET}"
  fi
}

# Install npm packages for ${DISTRO^}
install_npm_packages() {
  log_step "Installing npm packages globally"

  local NPM_PACKAGES=(
    "@qwen-code/qwen-code@latest"
    "@anthropic-ai/claude-code"
    "@musistudio/claude-code-router"
  )

  echo -e "  Target packages:"
  for pkg in "${NPM_PACKAGES[@]}"; do
    echo -e "    • ${C_CYAN}$pkg${C_RESET}"
  done

  if npm install -g "${NPM_PACKAGES[@]}"; then
    log_ok "All npm packages installed successfully"
  else
    log_err "Failed npm installation"
    die "Check permissions and connectivity."
  fi
}

# Setup Qwen integration using common functions
setup_qwen_integration() {
  local token_esc
  token_esc=$(setup_qwen_credentials)
  generate_router_config "$token_esc"
  setup_environment
  bypass_onboarding
  restart_router
  show_completion_summary
}