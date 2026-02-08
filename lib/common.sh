#!/bin/bash
#
# common.sh — Shared functions for Qwen Code + Claude Code setup scripts
#
# Contains common functions used across different distribution setup scripts.
#

readonly LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly SCRIPT_VERSION="1.1.0"
readonly QWEN_CREDS_PATH="${HOME}/.qwen/oauth_creds.json"
readonly ROUTER_CONFIG_DIR="${HOME}/.claude-code-router"
readonly ROUTER_PORT=3456

# Updated: Correct URLs based on authentication method
readonly URL_PORTAL="https://portal.qwen.ai/v1/chat/completions"
readonly URL_DASHSCOPE="https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions"

# This will be updated by setup functions
QWEN_API_URL="$URL_PORTAL"

# --- Colors (only if output is a terminal) ---
# Standard colors - check if C_RED is set (even if empty)
if [[ -z "${C_RED+x}" ]]; then
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
fi

# Helper checks for extra colors
if [[ -z "${C_CYAN+x}" ]]; then
  [[ -t 1 ]] && readonly C_CYAN='\033[0;36m' || readonly C_CYAN=''
fi

if [[ -z "${C_WHITE+x}" ]]; then
  [[ -t 1 ]] && readonly C_WHITE='\033[0;37m' || readonly C_WHITE=''
fi

# --- Shell RC detection (zsh or bash) ---
if [[ -f "${HOME}/.zshrc" ]]; then
  RC_FILE="${HOME}/.zshrc"
else
  RC_FILE="${HOME}/.bashrc"
fi

log_info()  { echo -e "${C_BLUE}[INFO]${C_RESET} $*" >&2; }
log_ok()    { echo -e "${C_GREEN}[OK]${C_RESET} $*" >&2; }
log_warn()  { echo -e "${C_YELLOW}[WARN]${C_RESET} $*" >&2; }
log_err()   { echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2; }
log_step()  { echo -e "\n${C_BOLD}==>${C_RESET} $*" >&2; }

die() {
  log_err "$1"
  exit "${2:-1}"
}

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

# Sets up Qwen credentials using bearer token from portal.qwen.ai (OAuth)
setup_qwen_bearer_token() {
  QWEN_API_URL="$URL_PORTAL"
  clear >&2
  echo "" >&2
  echo -e "${C_YELLOW}${C_BOLD}╔═══════════════════════════════════════════════════════════════════════════╗${C_RESET}" >&2
  echo -e "${C_YELLOW}${C_BOLD}║                                                                           ║${C_RESET}" >&2
  echo -e "${C_YELLOW}${C_BOLD}║              🔑  BEARER TOKEN AUTHENTICATION (FREE TIER)  🔑              ║${C_RESET}" >&2
  echo -e "${C_YELLOW}${C_BOLD}║                                                                           ║${C_RESET}" >&2
  echo -e "${C_YELLOW}${C_BOLD}╚═══════════════════════════════════════════════════════════════════════════╝${C_RESET}" >&2
  echo "" >&2

  echo -e "${C_BOLD}📋 Authentication Instructions:${C_RESET}" >&2
  echo "" >&2
  echo -e "  ${C_CYAN}1.${C_RESET} Open a ${C_BOLD}separate terminal${C_RESET} window." >&2
  echo -e "  ${C_CYAN}2.${C_RESET} Run the command: ${C_BOLD}${C_GREEN}qwen${C_RESET}" >&2
  echo -e "  ${C_CYAN}3.${C_RESET} Inside the Qwen CLI, type: ${C_BOLD}${C_GREEN}/auth${C_RESET}" >&2
  echo -e "  ${C_CYAN}4.${C_RESET} Sign in to your browser." >&2
  echo -e "  ${C_CYAN}5.${C_RESET} Once you see 'Success', type: ${C_BOLD}${C_GREEN}/exit${C_RESET} and close that terminal." >&2
  echo "" >&2
  echo -e "${C_YELLOW}─────────────────────────────────────────────────────────────────────────${C_RESET}" >&2
  echo "" >&2

  while true; do
    if [[ -f "$QWEN_CREDS_PATH" ]]; then
      echo -e "${C_GREEN}✓ Local credentials found at $QWEN_CREDS_PATH${C_RESET}" >&2
      echo -ne "${C_BOLD}${C_CYAN}➜ Do you want to use existing credentials or refresh them manually? [U]se/[r]efresh:${C_RESET} " >&2
      read -r auth_choice
      [[ -z "$auth_choice" ]] && auth_choice="u"
      
      if [[ "$auth_choice" =~ ^[Uu]$ ]]; then
        break
      fi
    fi

    echo -e "${C_CYAN}📍 Please complete the steps in your other terminal...${C_RESET}" >&2
    echo -ne "${C_BOLD}${C_WHITE}➜ Press Enter ONLY AFTER you have finished the /auth process:${C_RESET} " >&2
    read
    
    if [[ -f "$QWEN_CREDS_PATH" ]]; then
      echo "" >&2
      echo -e "${C_GREEN}✓ Detected new credentials!${C_RESET}" >&2
      break
    else
      echo "" >&2
      echo -e "${C_RED}✗ Error: Credentials file still not found at $QWEN_CREDS_PATH${C_RESET}" >&2
      echo -e "${C_YELLOW}  Make sure you ran '/auth' and saw the 'Success' message.${C_RESET}" >&2
      echo -ne "${C_YELLOW}➜ Would you like to try again? [Y/n]:${C_RESET} " >&2
      read -r retry
      [[ -z "$retry" ]] && retry="y"
      if [[ ! "$retry" =~ ^[Yy]$ ]]; then
        die "Authentication failed or cancelled by user."
      fi
    fi
  done

  local token
  token=$(extract_qwen_token "$QWEN_CREDS_PATH")
  local token_esc
  token_esc=$(json_escape "$token")

  echo "" >&2
  echo -e "${C_GREEN}${C_BOLD}✓ OAuth token obtained successfully from portal.qwen.ai${C_RESET}" >&2
  echo "" >&2

  echo "$token_esc"
}

# Sets up Qwen credentials using API key from dashscope.aliyuncs.com
setup_qwen_api_key() {
  QWEN_API_URL="$URL_DASHSCOPE"
  clear >&2
  echo "" >&2
  echo -e "${C_GREEN}${C_BOLD}╔═══════════════════════════════════════════════════════════════════════════╗${C_RESET}" >&2
  echo -e "${C_GREEN}${C_BOLD}║                                                                           ║${C_RESET}" >&2
  echo -e "${C_GREEN}${C_BOLD}║                 🔑  API KEY AUTHENTICATION (PAID)  🔑                     ║${C_RESET}" >&2
  echo -e "${C_GREEN}${C_BOLD}║                                                                           ║${C_RESET}" >&2
  echo -e "${C_GREEN}${C_BOLD}╚═══════════════════════════════════════════════════════════════════════════╝${C_RESET}" >&2
  echo "" >&2
  
  echo -e "${C_BOLD}📋 API Key Information:${C_RESET}" >&2
  echo "" >&2
  echo -e "  ${C_WHITE}Provider:${C_RESET}      dashscope-intl.aliyuncs.com" >&2
  echo -e "  ${C_WHITE}Format:${C_RESET}        sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" >&2
  echo -e "  ${C_WHITE}Documentation:${C_RESET} https://dashscope.aliyuncs.com/" >&2
  echo "" >&2
  echo -e "${C_YELLOW}─────────────────────────────────────────────────────────────────────────${C_RESET}" >&2
  echo "" >&2
  
  if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]]; then
    die "No interactive terminal (or CI=true). Please provide your API key."
  fi

  local api_key
  while true; do
    echo -ne "${C_BOLD}${C_CYAN}➜ Enter your API Key:${C_RESET} " >&2
    read -r api_key
    
    if [[ -z "$api_key" ]]; then
      echo "" >&2
      echo -e "${C_RED}✗ API key cannot be empty.${C_RESET}" >&2
      echo -e "${C_YELLOW}  Please try again or press Ctrl+C to cancel.${C_RESET}" >&2
      echo "" >&2
    else
      break
    fi
  done
  
  # Escape the API key for JSON
  local api_key_esc
  api_key_esc=$(json_escape "$api_key")

  echo "" >&2
  echo -e "${C_GREEN}${C_BOLD}✓ API key validated successfully${C_RESET}" >&2
  echo "" >&2

  echo "$api_key_esc"
}

# Displays a professional authentication selection menu
show_auth_menu() {
  clear >&2
  echo "" >&2
  echo -e "${C_CYAN}${C_BOLD}" >&2
  echo "╔═══════════════════════════════════════════════════════════════════════════╗" >&2
  echo "║                                                                           ║" >&2
  echo "║                    🔐  QWEN AUTHENTICATION SETUP  🔐                      ║" >&2
  echo "║                                                                           ║" >&2
  echo "╚═══════════════════════════════════════════════════════════════════════════╝" >&2
  echo -e "${C_RESET}" >&2
  echo "" >&2
  echo -e "${C_BOLD}Please select your preferred authentication method:${C_RESET}" >&2
  echo "" >&2
  echo -e "${C_GREEN}${C_BOLD}┌─────────────────────────────────────────────────────────────────────────┐${C_RESET}" >&2
  echo -e "${C_GREEN}${C_BOLD}│  [1] API Key Authentication                                            ${C_GREEN}${C_BOLD}│${C_RESET}" >&2
  echo -e "${C_GREEN}${C_BOLD}└─────────────────────────────────────────────────────────────────────────┘${C_RESET}" >&2
  echo -e "${C_WHITE}    Provider:${C_RESET}  dashscope-intl.aliyuncs.com" >&2
  echo -e "${C_WHITE}    Cost:${C_RESET}      Paid service (requires API key)" >&2
  echo "" >&2
  echo -e "    ${C_BOLD}✓${C_RESET} Higher rate limits for intensive usage" >&2
  echo -e "    ${C_BOLD}✓${C_RESET} More stable and reliable connection" >&2
  echo -e "    ${C_BOLD}✓${C_RESET} Better suited for production environments" >&2
  echo -e "    ${C_BOLD}⚠${C_RESET} 1M free tokens per model; then paid usage applies" >&2
  echo "" >&2
  echo "" >&2
  echo -e "${C_YELLOW}${C_BOLD}┌─────────────────────────────────────────────────────────────────────────┐${C_RESET}" >&2
  echo -e "${C_YELLOW}${C_BOLD}│  [2] Bearer Token Authentication ${C_RESET}${C_YELLOW}(RECOMMENDED / FREE)                 ${C_YELLOW}${C_BOLD}│${C_RESET}" >&2
  echo -e "${C_YELLOW}${C_BOLD}└─────────────────────────────────────────────────────────────────────────┘${C_RESET}" >&2
  echo -e "${C_WHITE}    Provider:${C_RESET}  portal.qwen.ai (OAuth)" >&2
  echo -e "${C_WHITE}    Cost:${C_RESET}      Free tier with usage limits" >&2
  echo "" >&2
  echo -e "    ${C_BOLD}✓${C_RESET} Completely free to use" >&2
  echo -e "    ${C_BOLD}✓${C_RESET} 1,000 requests per day" >&2
  echo -e "    ${C_BOLD}✓${C_RESET} 60 requests per minute" >&2
  echo -e "    ${C_BOLD}⚠${C_RESET} May experience rate limiting with heavy usage" >&2
  echo "" >&2
  echo "" >&2
  echo -e "${C_CYAN}─────────────────────────────────────────────────────────────────────────${C_RESET}" >&2
  echo "" >&2
}

# Gets or creates Qwen credentials - allows user to choose authentication method
setup_qwen_credentials() {
  show_auth_menu
  
  if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]]; then
    die "No interactive terminal (or CI=true). Cannot prompt for authentication method."
  fi

  local choice
  local attempts=0
  local max_attempts=3
  
  while true; do
    echo -ne "${C_BOLD}${C_CYAN}➜ Enter your choice [1 or 2]:${C_RESET} " >&2
    read choice
    
    case $choice in
      1)
        echo "" >&2
        echo -e "${C_GREEN}✓ Selected: API Key Authentication${C_RESET}" >&2
        echo "" >&2
        sleep 1
        setup_qwen_api_key
        return
        ;;
      2)
        echo "" >&2
        echo -e "${C_YELLOW}✓ Selected: Bearer Token Authentication${C_RESET}" >&2
        echo "" >&2
        sleep 1
        setup_qwen_bearer_token
        return
        ;;
      q|Q)
        echo "" >&2
        die "Installation cancelled by user."
        ;;
      *)
        ((attempts++))
        echo "" >&2
        echo -e "${C_RED}✗ Invalid choice: '$choice'${C_RESET}" >&2
        
        if [[ $attempts -ge $max_attempts ]]; then
          echo "" >&2
          echo -e "${C_RED}Too many invalid attempts. Installation cancelled.${C_RESET}" >&2
          exit 1
        fi
        
        echo -e "${C_YELLOW}  Please enter either '1' for API Key or '2' for Bearer Token.${C_RESET}" >&2
        echo -e "${C_YELLOW}  (Or press 'q' to quit)${C_RESET}" >&2
        echo "" >&2
        ;;
    esac
  done
}

# Generates the Claude Code Router configuration
generate_router_config() {
  local api_key="$1"
  local plugins_dir="${ROUTER_CONFIG_DIR}/plugins"
  local transformer_src="${LIB_DIR}/plugins/qwen-transformer.js"
  local transformer_dest="${plugins_dir}/qwen-transformer.js"

  # Auto-detect correct URL if using API Key (sk-...) vs OAuth token
  local active_url="$QWEN_API_URL"
  if [[ "$api_key" == sk-* ]]; then
    active_url="$URL_DASHSCOPE"
  elif [[ -n "$api_key" ]]; then
    active_url="$URL_PORTAL"
  fi

  log_step "Configuring claude-code-router"

  mkdir -p "$plugins_dir"

  # Copy the Qwen transformer plugin if it exists in the repo
  if [[ -f "$transformer_src" ]]; then
    cp "$transformer_src" "$transformer_dest"
    log_ok "Qwen transformer plugin installed to $transformer_dest"
  else
    log_warn "Qwen transformer plugin not found in $transformer_src. Web search might not work as expected."
  fi

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
      "api_base_url": "$active_url",
      "api_key": "$api_key",
      "models": ["qwen3-coder-plus"],
      "transformer": {
        "use": ["qwen-transformer"]
      }
    }
  ],
  "transformers": [
    {
      "name": "qwen-transformer",
      "path": "$transformer_dest"
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

# Restarts the Claude Code Router process
restart_router() {
  log_step "Restarting Claude Code Router"
  
  if command_exists ccr; then
    log_info "Attempting to restart router process..."
    # Kill existing process if running
    pkill -f "claude-code-router" || true
    # We don't start it automatically here as it might need to run in a specific terminal/background
    # but the user requested "ccr restart el solito".
    # if ccr has a restart command, use it
    ccr restart 2>/dev/null || true
    log_ok "Restart signal sent to router."
  else
    log_warn "'ccr' command not found. If the router is running, please restart it manually."
  fi
}

# Sets up environment variables
setup_environment() {
  log_step "Setting up environment variables in $RC_FILE"

  add_rc_line 'export ANTHROPIC_BASE_URL="http://127.0.0.1:'"$ROUTER_PORT"'"'
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
  echo "    2. Open Claude:        claude"
  echo ""
  echo "  VS Code / Cursor: open from terminal (code .) for extension to use router."
  echo ""
  echo -e "  ${C_YELLOW}If credentials expire:${C_RESET}"
  echo -e "  ${C_YELLOW}  • Bearer Token: run 'qwen' -> '/auth' and 'qwen-claude refresh'${C_RESET}"
  echo -e "  ${C_YELLOW}  • API Key: run 'qwen-claude install' and provide new key${C_RESET}"
  echo ""
}