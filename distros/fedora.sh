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

    sudo dnf install -y "${DNF_PACKAGES[@]}"
    log_ok "Node.js installed: $(node -v)"
  else
    log_ok "Node.js $(node -v)"
  fi

  # Install jq if needed (likely already installed with dnf packages)
  if ! command_exists jq; then
    log_info "Installing jq for OAuth credential reading..."
    sudo dnf install -y jq
    log_ok "jq installed"
  else
    log_ok "jq already installed"
  fi
}

# Install npm packages for Fedora
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