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
  log_step "Checking for AUR helper"

  if ! command_exists "$AUR_HELPER"; then
    log_err "AUR helper '${C_BOLD}$AUR_HELPER${C_RESET}' not found."
    echo -e "${C_YELLOW}  Please install 'yay' or 'paru', or set AUR_HELPER env var.${C_RESET}"
    die "Missing required AUR helper."
  fi

  log_info "Using AUR helper: ${C_GREEN}${C_BOLD}$AUR_HELPER${C_RESET}"
}

# Install AUR packages for Arch
install_aur_packages() {
  log_step "Installing AUR packages"
  echo -e "  Target packages: ${C_CYAN}${AUR_PACKAGES[*]}${C_RESET}"

  if "$AUR_HELPER" -S --needed --noconfirm "${AUR_PACKAGES[@]}"; then
    log_ok "All AUR packages installed successfully"
  else
    log_err "Failed to install packages via $AUR_HELPER"
    die "AUR installation failed. Check internet connection and permissions."
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