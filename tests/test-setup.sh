#!/bin/bash
#
# test-setup.sh — Basic tests for Qwen-Claude setup scripts
#
# Performs basic validation of the setup process and configurations.
#

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"

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

print_version() {
  echo "$SCRIPT_NAME 1.0.1"
}

die() {
  log_err "$1"
  exit "${2:-1}"
}

# Test script permissions
test_script_permissions() {
  log_step "Testing script permissions"

  local scripts_to_check=(
    "$PROJECT_ROOT/install.sh"
    "$PROJECT_ROOT/common.sh"
    "$PROJECT_ROOT/scripts/uninstall.sh"
    "$PROJECT_ROOT/distros/ubuntu.sh"
    "$PROJECT_ROOT/distros/arch.sh"
    "$PROJECT_ROOT/distros/fedora.sh"
    "$PROJECT_ROOT/distros/debian.sh"
  )

  local failures=0
  for script in "${scripts_to_check[@]}"; do
    if [[ ! -f "$script" ]]; then
      log_err "Script not found: $script"
      ((failures++))
    elif [[ ! -x "$script" ]]; then
      log_err "Script not executable: $script"
      ((failures++))
    else
      log_ok "Found and executable: $(basename "$script")"
    fi
  done

  if [[ $failures -gt 0 ]]; then
    die "Failed permission checks: $failures"
  fi
}

# Test script syntax
test_script_syntax() {
  log_step "Testing script syntax"

  local scripts_to_check=(
    "$PROJECT_ROOT/install.sh"
    "$PROJECT_ROOT/common.sh"
    "$PROJECT_ROOT/scripts/uninstall.sh"
    "$PROJECT_ROOT/distros/ubuntu.sh"
    "$PROJECT_ROOT/distros/arch.sh"
    "$PROJECT_ROOT/distros/fedora.sh"
    "$PROJECT_ROOT/distros/debian.sh"
  )

  local failures=0
  for script in "${scripts_to_check[@]}"; do
    if [[ -f "$script" ]]; then
      if ! bash -n "$script"; then
        log_err "Syntax error in: $script"
        ((failures++))
      else
        log_ok "Syntax OK: $(basename "$script")"
      fi
    fi
  done

  if [[ $failures -gt 0 ]]; then
    die "Failed syntax checks: $failures"
  fi
}

# Test required commands
test_required_commands() {
  log_step "Testing required commands"

  local required_commands=(bash curl jq)
  local failures=0

  for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      log_err "Required command not found: $cmd"
      ((failures++))
    else
      log_ok "Command available: $cmd"
    fi
  done

  # Check Node.js version if available
  if command -v node &>/dev/null; then
    local node_version
    node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ "$node_version" -lt 20 ]]; then
      log_warn "Node.js version may be too low: $(node -v) (recommended: v20+)"
    else
      log_ok "Node.js version OK: $(node -v)"
    fi
  else
    log_info "Node.js not found (will be installed by setup scripts)"
  fi

  if [[ $failures -gt 0 ]]; then
    die "Missing required commands: $failures"
  fi
}

# Test directory structure
test_directory_structure() {
  log_step "Testing directory structure"

  local dirs_to_check=(
    "$PROJECT_ROOT/docs"
    "$PROJECT_ROOT/scripts"
    "$PROJECT_ROOT/distros"
    "$PROJECT_ROOT/examples"
    "$PROJECT_ROOT/tests"
  )

  local failures=0
  for dir in "${dirs_to_check[@]}"; do
    if [[ ! -d "$dir" ]]; then
      log_err "Directory not found: $dir"
      ((failures++))
    else
      log_ok "Directory exists: $(basename "$dir")"
    fi
  done

  # Check for important files
  local files_to_check=(
    "$PROJECT_ROOT/README.md"
    "$PROJECT_ROOT/LICENSE"
    "$PROJECT_ROOT/CHANGELOG.md"
    "$PROJECT_ROOT/CONTRIBUTING.md"
  )

  for file in "${files_to_check[@]}"; do
    if [[ ! -f "$file" ]]; then
      log_err "File not found: $file"
      ((failures++))
    else
      log_ok "File exists: $(basename "$file")"
    fi
  done

  if [[ $failures -gt 0 ]]; then
    die "Structure validation failed: $failures"
  fi
}

# Test documentation
test_documentation() {
  log_step "Testing documentation"

  local docs_to_check=(
    "$PROJECT_ROOT/docs/installation.md"
    "$PROJECT_ROOT/docs/troubleshooting.md"
  )

  local failures=0
  for doc in "${docs_to_check[@]}"; do
    if [[ ! -f "$doc" ]]; then
      log_err "Documentation not found: $doc"
      ((failures++))
    else
      log_ok "Documentation exists: $(basename "$doc")"
    fi
  done

  if [[ $failures -gt 0 ]]; then
    die "Documentation validation failed: $failures"
  fi
}

# Run all tests
run_tests() {
  log_info "Starting tests for Qwen-Claude Setup Scripts"
  log_info "Project root: $PROJECT_ROOT"
  echo ""

  test_directory_structure
  test_script_permissions
  test_script_syntax
  test_required_commands
  test_documentation

  log_ok "All tests passed!"
}

# --- Main execution ---
case "${1:-}" in
  -v|--version)
    print_version
    exit 0
    ;;
  "")
    run_tests
    ;;
  *)
    echo "Usage: $SCRIPT_NAME [OPTION]"
    echo "Options:"
    echo "  -v, --version  Show version and exit"
    exit 1
    ;;
esac