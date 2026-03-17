#!/usr/bin/env bash
# Connects to an MCP server via stdio, performs JSON-RPC handshake,
# queries tools/list, and outputs the byte count of the tools JSON array.
# Outputs -1 on any failure.
#
# Usage: query-mcp.sh <command> [args...]

set -euo pipefail

TIMEOUT_SEC=5
FAIL=-1

# Ensure we have a command
if [ $# -lt 1 ]; then
  echo "$FAIL"
  exit 0
fi

COMMAND="$1"
shift

# Check that the command exists
if ! command -v "$COMMAND" &>/dev/null; then
  echo "$FAIL"
  exit 0
fi

# Create named pipes for bidirectional communication
TMPDIR_MCP="$(mktemp -d)"
PIPE_IN="${TMPDIR_MCP}/in"
PIPE_OUT="${TMPDIR_MCP}/out"
mkfifo "$PIPE_IN" "$PIPE_OUT"

SERVER_PID=""
cleanup() {
  [ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null || true
  rm -rf "$TMPDIR_MCP"
}
trap cleanup EXIT

# Start the MCP server with named pipes
"$COMMAND" "$@" < "$PIPE_IN" > "$PIPE_OUT" 2>/dev/null &
SERVER_PID=$!

# Open write end of pipe (keep fd open so server doesn't see EOF)
exec 3>"$PIPE_IN"

# Helper: send a JSON-RPC message to the server
send_msg() {
  echo "$1" >&3
}

# Helper: read a line from the server with timeout
read_response() {
  if read -r -t "$TIMEOUT_SEC" line < "$PIPE_OUT"; then
    echo "$line"
    return 0
  fi
  return 1
}

# Step 1: Send initialize request
INIT_REQ='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"context-probe","version":"1.0.0"}}}'
send_msg "$INIT_REQ"

# Step 2: Read initialize response
INIT_RESP="$(read_response)" || { echo "$FAIL"; exit 0; }

# Validate we got a proper response
if ! echo "$INIT_RESP" | jq -e '.result' &>/dev/null; then
  echo "$FAIL"
  exit 0
fi

# Step 3: Send initialized notification
send_msg '{"jsonrpc":"2.0","method":"notifications/initialized"}'

# Step 4: Send tools/list request
send_msg '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'

# Step 5: Read tools/list response
TOOLS_RESP="$(read_response)" || { echo "$FAIL"; exit 0; }

# Step 6: Extract tools array and measure its byte count
TOOLS_BYTES="$(echo "$TOOLS_RESP" | jq -c '.result.tools // []' 2>/dev/null | wc -c | tr -d ' ')" || {
  echo "$FAIL"
  exit 0
}

echo "$TOOLS_BYTES"
