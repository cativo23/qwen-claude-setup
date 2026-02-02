#!/bin/bash
#
# arch.sh — Arch Linux-specific setup functions for Qwen Code + Claude Code
#

readonly AUR_PACKAGES=(qwen-code claude-code claude-code-router)
AUR_HELPER="${AUR_HELPER:-yay}"

# Arch-specific main setup function
main_setup() {
  check_aur_helper
  install_aur_packages
  setup_qwen_integration
}

# Check if AUR helper is available
check_aur_helper() {
  log_step "Checking AUR helper"

  if ! command_exists "$AUR_HELPER"; then
    die "AUR helper '$AUR_HELPER' not found. Install it or set AUR_HELPER (e.g., export AUR_HELPER=paru)."
  fi

  log_ok "AUR helper: $AUR_HELPER"
}

# Install AUR packages for Arch
install_aur_packages() {
  log_step "Installing AUR packages (qwen-code, claude-code, claude-code-router)"

  if "$AUR_HELPER" -S --needed --noconfirm "${AUR_PACKAGES[@]}"; then
    log_ok "AUR packages installed"
  else
    die "AUR installation failed. Check connectivity and permissions."
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