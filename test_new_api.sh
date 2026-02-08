#!/bin/bash
# Test script for the new Qwen API endpoint

# Replace YOUR_API_KEY with your actual Qwen API key from dashscope.aliyuncs.com
API_KEY="YOUR_API_KEY"

echo "Testing the new Qwen API endpoint..."
echo "Make sure to replace YOUR_API_KEY with your actual API key from dashscope.aliyuncs.com"
echo ""

if [[ "$API_KEY" == "YOUR_API_KEY" ]]; then
    echo "ERROR: Please update the API_KEY variable in this script with your actual API key."
    exit 1
fi

response=$(curl -s --max-time 25 -X POST "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{"model":"qwen3-coder-plus","messages":[{"role":"user","content":"Di solo: OK"}]}')

echo "$response" | jq .

# Check if the response contains an error
if echo "$response" | jq -e '.error' >/dev/null; then
    echo ""
    echo "The API request failed. Please check your API key and try again."
    exit 1
else
    echo ""
    echo "API test successful!"
fi