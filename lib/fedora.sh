#!/bin/bash
#
# fedora.sh — Fedora-specific setup functions for Qwen Code + Claude Code
#

readonly NODE_MIN_MAJOR=20
readonly DNF_PACKAGES=(nodejs npm jq)

# Fedora-specific main setup function
main_setup() {
  install_dependencies
  install_npm_packages
  setup_qwen_integration
}

# Install Fedora-specific dependencies
install_dependencies() {
  log_step "Installing Fedora dependencies"

  # Check if Node.js meets requirements
  local need_node=false
  if ! command_exists node; then
    need_node=true
  elif ! node -e "process.exit(parseInt(process.versions.node.split('.')[0], 10) >= ${NODE_MIN_MAJOR} ? 0 : 1)" 2>/dev/null; then
    need_node=true
  fi

  if [[ "$need_node" == true ]]; then
    log_info "Node.js ${NODE_MIN_MAJOR}+ not found. Installing..."

    if ! command_exists dnf; then
      die "dnf package manager not found. This doesn't appear to be a Fedora system."
    fi

    echo -e "  Installing packages: ${C_CYAN}${DNF_PACKAGES[*]}${C_RESET}"
    sudo dnf install -y "${DNF_PACKAGES[@]}" > /dev/null
    log_ok "Node.js installed: ${C_GREEN}$(node -v)${C_RESET}"
  else
    log_ok "Node.js version satisfied: ${C_GREEN}$(node -v)${C_RESET}"
  fi

  # Install jq if needed (likely already installed with dnf packages)
  if ! command_exists jq; then
    log_info "Installing ${C_CYAN}jq${C_RESET} for OAuth credential reading..."
    sudo dnf install -y jq > /dev/null
    log_ok "jq installed"
  else
    log_ok "jq already installed"
  fi
}

# Install npm packages for Fedora
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