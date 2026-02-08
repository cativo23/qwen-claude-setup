#!/bin/bash
#
# install.sh — Unified Qwen Code + Claude Code setup for multiple distributions
#
# Detects the Linux distribution and runs the appropriate setup script.
# Supported distributions: Ubuntu, Arch, Fedora, Debian.
#

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"

# --- Source Common Logic ---
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$LIB_DIR/common.sh" ]]; then
  source "$LIB_DIR/common.sh"
else
  echo -e "\033[0;31mError: common.sh not found in $LIB_DIR\033[0m" >&2
  exit 1
fi

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTION]

Unified setup script for Qwen Code + Claude Code across multiple Linux distributions.

Options:
  -h, --help     Show this help and exit
  -v, --version  Show version and exit

The script automatically detects your Linux distribution and runs the appropriate setup.
Supported distributions: Ubuntu, Arch, Fedora, Debian.

EOF
}

print_version() {
  echo "$SCRIPT_NAME $SCRIPT_VERSION"
}
detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$ID"
  elif [[ -f /etc/redhat-release ]]; then
    # Handle older Red Hat based systems
    if grep -q "Fedora" /etc/redhat-release; then
      echo "fedora"
    else
      echo "rhel"
    fi
  else
    echo "unknown"
  fi
}

# --- Check arguments ---
case "${1:-}" in
  -h|--help)    usage; exit 0 ;;
  -v|--version) print_version; exit 0 ;;
  '')           ;;
  *)            usage; die "Unrecognized option: $1" ;;
esac

log_step "Detecting Linux distribution"

# Display Banner
echo -e "${C_CYAN}${C_BOLD}"
echo "   ____                         _____ _                 _       "
echo "  / __ \                       / ____| |               | |      "
echo " | |  | |_      _____ _ __    | |    | | __ _ _   _  __| | ___  "
echo " | |  | \ \ /\ / / _ \ '_ \   | |    | |/ _\` | | | |/ _\` |/ _ \ "
echo " | |__| |\ V  V /  __/ | | |  | |____| | (_| | |_| | (_| |  __/ "
echo "  \____/  \_/\_/ \___|_| |_|   \_____|_|\__,_|\__,_|\__,_|\___| "
echo "                                                                "
echo "   🚀 Qwen Code + Claude Code Setup | v${SCRIPT_VERSION}              "
echo -e "${C_RESET}"
echo ""

DISTRO=$(detect_distro)
log_info "Detected distribution: ${C_BOLD}${C_GREEN}${DISTRO}${C_RESET}"

# Confirmation
echo ""
echo -e "${C_BOLD}This script will install Qwen Code, Claude Code setup, and configure authentication.${C_RESET}"
echo -e "Target Distribution: ${C_GREEN}${DISTRO^}${C_RESET}"
echo ""
echo -ne "${C_CYAN}Do you want to proceed? [Y/n] ${C_RESET}"
read -r confirm
[[ -z "$confirm" ]] && confirm="y"
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo -e "${C_YELLOW}Installation aborted by user.${C_RESET}"
  exit 0
fi
echo ""

# Define supported distributions
SUPPORTED_DISTROS=("ubuntu" "arch" "fedora" "debian")

# Check if the detected distribution is supported
if ! [[ " ${SUPPORTED_DISTROS[*]} " =~ " ${DISTRO} " ]]; then
  die "Unsupported distribution: $DISTRO. Supported: ${SUPPORTED_DISTROS[*]}"
fi

# Check for distro-specific script
DISTRO_SCRIPT="${LIB_DIR}/${DISTRO}.sh"
if [[ ! -f "$DISTRO_SCRIPT" ]]; then
  # Fallback for debian-based if specific script doesn't exist
  if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
    DISTRO_SCRIPT="${LIB_DIR}/debian.sh"
  else
    log_err "Unsupported distribution: $DISTRO"
    die "No setup script found at $DISTRO_SCRIPT"
  fi
fi

# Source the distribution-specific script
if [[ -f "$DISTRO_SCRIPT" ]]; then
  source "$DISTRO_SCRIPT"
else
  die "Distribution script not found: $DISTRO_SCRIPT"
fi

# Run the main setup function from the distribution script
if declare -f main_setup &>/dev/null; then
  main_setup
else
  die "main_setup function not defined in $DISTRO_SCRIPT"
fi

log_ok "Setup completed successfully for $DISTRO"