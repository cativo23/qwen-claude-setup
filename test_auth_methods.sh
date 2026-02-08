#!/bin/bash
#
# test_auth_methods.sh — Test script to demonstrate both authentication methods
#
# This script shows how to use both authentication methods:
# 1. API Key (dashscope.aliyuncs.com)
# 2. Bearer Token (portal.qwen.ai)
#

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Colors are provided by common.sh

# Logging functions
log_step() {
  echo -e "${C_YELLOW}➜ $1${C_RESET}"
}

log_ok() {
  echo -e "${C_GREEN}✔ $1${C_RESET}"
}

die() {
  echo -e "\033[31m✘ $1\033[0m" >&2
  exit 1
}

# Main test
main() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "  Testing Qwen Authentication Methods"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  
  # Test the authentication selection
  local auth_result
  auth_result=$(setup_qwen_credentials)
  
  if [[ -n "$auth_result" ]]; then
    log_ok "Authentication successful!"
    echo ""
    echo "Credentials obtained:"
    echo "  - Length: ${#auth_result} characters"
    echo "  - Preview: ${auth_result:0:20}..."
    echo ""
  else
    die "Authentication failed - no credentials obtained"
  fi
  
  log_ok "Test completed successfully"
}

# Run main function
main "$@"
