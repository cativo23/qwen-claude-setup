#!/bin/bash
#
# common.sh — Shared functions for Qwen Code + Claude Code setup scripts
#
# Contains common functions used across different distribution setup scripts.
#

# --- Constants ---
readonly QWEN_CREDS_PATH="${HOME}/.qwen/oauth_creds.json"
readonly ROUTER_CONFIG_DIR="${HOME}/.claude-code-router"
readonly ROUTER_PORT=3456
readonly QWEN_PORTAL_URL="https://portal.qwen.ai/v1/chat/completions"

# --- Shell RC detection (zsh or bash) ---
if [[ -f "${HOME}/.zshrc" ]]; then
  RC_FILE="${HOME}/.zshrc"
else
  RC_FILE="${HOME}/.bashrc"
fi

# --- Shared Functions ---

# Escapes a string for safe use inside JSON values (double quotes and backslashes)
json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# Adds a line to the RC file if it doesn't exist (avoids duplicates)
add_rc_line() {
  local line="$1"
  [[ -f "$RC_FILE" ]] && grep -qFx "$line" "$RC_FILE" 2>/dev/null && return
  echo "$line" >> "$RC_FILE"
}

# Checks if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Waits for a port to be available
wait_for_port() {
  local port=$1
  local timeout=${2:-30}
  local count=0

  while ! nc -z localhost "$port" 2>/dev/null; do
    sleep 1
    ((count++))
    if [[ $count -ge $timeout ]]; then
      return 1
    fi
  done
  return 0
}

# Validates if a file exists and is readable
validate_file() {
  local file="$1"
  if [[ ! -f "$file" ]] || [[ ! -r "$file" ]]; then
    log_err "File does not exist or is not readable: $file"
    return 1
  fi
}

# Extracts Qwen token from credentials file
extract_qwen_token() {
  local creds_file="$1"
  local token=""

  if command_exists jq; then
    token=$(jq -r '.access_token // empty' "$creds_file" 2>/dev/null || true)
  else
    token=$(grep -oP '(?<="access_token": ")[^"]*' "$creds_file" 2>/dev/null || true)
  fi

  # Clean up the token
  token=$(printf '%s' "$token" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  if [[ -z "$token" ]]; then
    die "Could not extract access_token from $creds_file. Is the file corrupted or token expired?"
  fi

  echo "$token"
}

# Gets or creates Qwen credentials
setup_qwen_credentials() {
  log_step "Setting up Qwen OAuth credentials"

  if [[ ! -f "$QWEN_CREDS_PATH" ]]; then
    echo ""
    echo "  Credentials file not found: $QWEN_CREDS_PATH"
    echo "  For the free tier (2000 req/day, 60 req/min) with portal.qwen.ai:"
    echo "    1. The Qwen CLI will be opened."
    echo "    2. Type: /auth"
    echo "    3. Sign in to the browser with your qwen.ai account."
    echo "    4. When you see 'Success', type: /exit"
    echo ""

    if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]]; then
      die "Credentials file not found and no interactive terminal (or CI=true). Run 'qwen' and '/auth' manually."
    fi

    read -p "  Press Enter to open qwen now (or Ctrl+C to cancel)..."
    qwen || true
  fi

  if [[ ! -f "$QWEN_CREDS_PATH" ]]; then
    die "Credentials file not found. Run 'qwen', then '/auth' and sign in."
  fi

  local token
  token=$(extract_qwen_token "$QWEN_CREDS_PATH")
  local token_esc
  token_esc=$(json_escape "$token")

  log_ok "OAuth token obtained (portal.qwen.ai)"

  # Restrict permissions on credentials file
  chmod 600 "$QWEN_CREDS_PATH"

  echo "$token_esc"
}

# Generates the Claude Code Router configuration
generate_router_config() {
  local token_esc="$1"

  log_step "Configuring claude-code-router"

  mkdir -p "$ROUTER_CONFIG_DIR"

  cat > "${ROUTER_CONFIG_DIR}/config.json" <<EOF
{
  "LOG": true,
  "LOG_LEVEL": "info",
  "HOST": "127.0.0.1",
  "PORT": $ROUTER_PORT,
  "API_TIMEOUT_MS": 600000,
  "Providers": [
    {
      "name": "qwen",
      "api_base_url": "$QWEN_PORTAL_URL",
      "api_key": "$token_esc",
      "models": ["qwen3-coder-plus"]
    }
  ],
  "Router": {
    "default": "qwen,qwen3-coder-plus",
    "background": "qwen,qwen3-coder-plus",
    "think": "qwen,qwen3-coder-plus",
    "longContext": "qwen,qwen3-coder-plus",
    "longContextThreshold": 60000,
    "webSearch": "qwen,qwen3-coder-plus"
  }
}
EOF

  chmod 600 "${ROUTER_CONFIG_DIR}/config.json"
  log_ok "Config written to ${ROUTER_CONFIG_DIR}/config.json (permissions 600)"
}

# Sets up environment variables
setup_environment() {
  log_step "Setting up environment variables in $RC_FILE"

  add_rc_line 'export ANTHROPIC_BASE_URL="http://127.0.0.1:'"$ROUTER_PORT"'/v1"'
  add_rc_line 'export ANTHROPIC_AUTH_TOKEN="dummy-token"'
  add_rc_line 'export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"'

  log_ok "Environment variables added (no duplicates)"
}

# Bypasses Claude onboarding
bypass_onboarding() {
  echo '{"hasCompletedOnboarding": true}' > "${HOME}/.claude.json"
}

# Shows setup completion summary
show_completion_summary() {
  echo ""
  echo -e "${C_GREEN}${C_BOLD}Setup completed successfully.${C_RESET}"
  echo ""
  echo "  Next steps:"
  echo "    1. Reload your shell:  source $RC_FILE"
  echo "    2. Start the router:   ccr start   (or  ccr code  for all-in-one)"
  echo "    3. If already running: ccr restart"
  echo "    4. Open Claude:        claude"
  echo ""
  echo "  VS Code / Cursor: open from terminal (code .) for extension to use router."
  echo ""
  echo -e "  ${C_YELLOW}If token expires: run  qwen → /auth  and rerun this script.${C_RESET}"
  echo ""
}