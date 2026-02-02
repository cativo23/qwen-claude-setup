#!/bin/bash
#
# uninstall.sh — Remove Qwen Code + Claude Code setup
#
# Removes all configurations and packages installed by the setup scripts.
#

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"

# --- Colores (solo si la salida es una terminal) ---
if [[ -t 1 ]]; then
  readonly C_RED='\033[0;31m'
  readonly C_GREEN='\033[0;32m'
  readonly C_YELLOW='\033[1;33m'
  readonly C_BLUE='\033[0;34m'
  readonly C_BOLD='\033[1m'
  readonly C_RESET='\033[0m'
else
  readonly C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_BOLD='' C_RESET=''
fi

log_info()  { echo -e "${C_BLUE}[INFO]${C_RESET} $*"; }
log_ok()    { echo -e "${C_GREEN}[OK]${C_RESET} $*"; }
log_warn()  { echo -e "${C_YELLOW}[WARN]${C_RESET} $*"; }
log_err()   { echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2; }
log_step()  { echo -e "\n${C_BOLD}==>${C_RESET} $*"; }

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTION]

Removes Qwen Code + Claude Code setup configurations and packages.

Options:
  -h, --help     Show this help and exit
  -v, --version  Show version and exit
  -f, --force    Skip confirmation prompts

Warning: This will remove all configurations and may break Claude integration.

EOF
}

print_version() {
  echo "$SCRIPT_NAME 1.0.1"
}

die() {
  log_err "$1"
  exit "${2:-1}"
}

confirm_removal() {
  if [[ "${FORCE_REMOVE:-false}" == "true" ]]; then
    return 0
  fi

  echo ""
  read -p "This will remove all Qwen-Claude configurations. Are you sure? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    die "Uninstall cancelled by user"
  fi
}

# Remove npm packages
remove_npm_packages() {
  local packages_to_remove=(
    "@qwen-code/qwen-code"
    "@anthropic-ai/claude-code"
    "@musistudio/claude-code-router"
  )

  local removed_count=0
  for package in "${packages_to_remove[@]}"; do
    if npm list -g --depth=0 "$package" &>/dev/null; then
      log_info "Removing npm package: $package"
      npm uninstall -g "$package" &>/dev/null || log_warn "Failed to remove $package"
      ((removed_count++))
    else
      log_info "Package not found: $package"
    fi
  done

  if [[ $removed_count -gt 0 ]]; then
    log_ok "$removed_count npm packages removed"
  else
    log_info "No npm packages to remove"
  fi
}

# Remove AUR packages
remove_aur_packages() {
  local aur_helper="yay"
  if [[ -n "${AUR_HELPER:-}" ]]; then
    aur_helper="$AUR_HELPER"
  elif command -v paru &>/dev/null; then
    aur_helper="paru"
  fi

  if command -v "$aur_helper" &>/dev/null; then
    local packages_to_remove=(qwen-code claude-code claude-code-router)
    local removed_count=0

    for package in "${packages_to_remove[@]}"; do
      if "$aur_helper" -Q "$package" &>/dev/null; then
        log_info "Removing AUR package: $package"
        "$aur_helper" -R --noconfirm "$package" &>/dev/null || log_warn "Failed to remove $package"
        ((removed_count++))
      else
        log_info "AUR package not found: $package"
      fi
    done

    if [[ $removed_count -gt 0 ]]; then
      log_ok "$removed_count AUR packages removed"
    else
      log_info "No AUR packages to remove"
    fi
  else
    log_warn "AUR helper not found, skipping AUR package removal"
  fi
}

# Remove configuration directories and files
remove_configs() {
  log_step "Removing configuration files"

  # Remove router configuration
  if [[ -d "$HOME/.claude-code-router" ]]; then
    rm -rf "$HOME/.claude-code-router"
    log_ok "Removed router configuration directory"
  else
    log_info "Router configuration directory not found"
  fi

  # Remove Claude configuration
  if [[ -f "$HOME/.claude.json" ]]; then
    rm -f "$HOME/.claude.json"
    log_ok "Removed Claude configuration file"
  else
    log_info "Claude configuration file not found"
  fi

  # Remove Qwen credentials (optional, ask user)
  if [[ -f "$HOME/.qwen/oauth_creds.json" ]]; then
    read -p "Remove Qwen OAuth credentials? This will require re-authentication. (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$HOME/.qwen"
      log_ok "Removed Qwen credentials"
    else
      log_info "Preserved Qwen credentials"
    fi
  else
    log_info "Qwen credentials not found"
  fi
}

# Remove environment variables from shell configuration
remove_env_vars() {
  log_step "Removing environment variables from shell configuration"

  local rc_file=""
  if [[ -f "$HOME/.zshrc" ]]; then
    rc_file="$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    rc_file="$HOME/.bashrc"
  else
    log_warn "Shell configuration file not found"
    return
  fi

  if [[ -f "$rc_file" ]]; then
    local temp_rc
    temp_rc=$(mktemp)

    # Remove the specific environment variable lines
    grep -v 'ANTHROPIC_BASE_URL\|ANTHROPIC_AUTH_TOKEN\|CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC' "$rc_file" > "$temp_rc"

    if cmp -s "$rc_file" "$temp_rc"; then
      log_info "No environment variables to remove from $rc_file"
    else
      mv "$temp_rc" "$rc_file"
      log_ok "Removed environment variables from $rc_file"
    fi

    # Clean up in case temp file still exists
    rm -f "$temp_rc" 2>/dev/null || true
  fi
}

# --- Check arguments ---
FORCE_REMOVE=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -v|--version)
      print_version
      exit 0
      ;;
    -f|--force)
      FORCE_REMOVE=true
      shift
      ;;
    *)
      usage
      die "Unrecognized option: $1"
      ;;
  esac
done

log_step "Starting uninstallation process"
confirm_removal

# Detect if this is an AUR-based or npm-based installation
if command -v qwen &>/dev/null; then
  remove_aur_packages
else
  remove_npm_packages
fi

remove_configs
remove_env_vars

log_ok "Uninstallation completed!"
echo ""
echo "Note: You may need to restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to fully remove environment changes."