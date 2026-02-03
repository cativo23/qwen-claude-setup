#!/bin/bash

CONFIG_FILE="${HOME}/.claude-code-router/config.json"
API_KEY=$(jq -r '.Providers[] | select(.name=="qwen") | .api_key' "$CONFIG_FILE")
API_URL=$(jq -r '.Providers[] | select(.name=="qwen") | .api_base_url' "$CONFIG_FILE")

test_tool() {
    local tool_name=$1
    echo "Testing tool: $tool_name"
    
    curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d '{
            "model": "qwen3-coder-plus",
            "messages": [
                {"role": "user", "content": "What is the latest Laravel version? Use your search tool."}
            ],
            "tools": [
                {
                    "type": "function",
                    "function": {
                        "name": "'"$tool_name"'",
                        "description": "Search the web for information",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "query": {"type": "string", "description": "The search query"}
                            },
                            "required": ["query"]
                        }
                    }
                }
            ],
            "tool_choice": "auto"
        }' | jq '.choices[0].message'
}

test_tool "WebSearch"
echo "---"
test_tool "web_search"
