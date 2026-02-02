#!/bin/bash
#
# install.sh — Unified Qwen Code + Claude Code setup for multiple distributions
#
# Detects the Linux distribution and runs the appropriate setup script.
# Supported distributions: Ubuntu, Arch, Fedora, Debian.
#

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_VERSION="1.0.1"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

die() {
  log_err "$1"
  exit "${2:-1}"
}

# Detect the Linux distribution
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
DISTRO=$(detect_distro)
log_info "Detected distribution: $DISTRO"

# Define supported distributions and their script paths
SUPPORTED_DISTROS=("ubuntu" "arch" "fedora" "debian")
COMMON_SCRIPT="${SCRIPT_DIR}/common.sh"
DISTRO_SCRIPT="${SCRIPT_DIR}/distros/${DISTRO}.sh"

# Check if the detected distribution is supported
if ! [[ " ${SUPPORTED_DISTROS[*]} " =~ " ${DISTRO} " ]]; then
  die "Unsupported distribution: $DISTRO. Supported: ${SUPPORTED_DISTROS[*]}"
fi

# Source the common functions
if [[ -f "$COMMON_SCRIPT" ]]; then
  source "$COMMON_SCRIPT"
else
  die "Common script not found: $COMMON_SCRIPT"
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