#!/usr/bin/env bash
# Waits for Qodo and Copilot to finish reviewing a PR.
# Usage: wait-for-reviews.sh <pr-number> [initial-delay] [poll-interval] [max-attempts]
# Defaults: initial-delay=300s, poll-interval=120s, max-attempts=10
set -euo pipefail

PR="${1:?Usage: wait-for-reviews.sh <pr-number>}"
INITIAL_DELAY="${2:-300}"
POLL_INTERVAL="${3:-120}"
MAX_ATTEMPTS="${4:-10}"

REPO="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"

echo "Waiting ${INITIAL_DELAY}s before first check..."
sleep "$INITIAL_DELAY"

for i in $(seq 1 "$MAX_ATTEMPTS"); do
  # Check inline review comments (Copilot posts here)
  INLINE_AUTHORS="$(gh api "repos/${REPO}/pulls/${PR}/comments" --jq '[.[].user.login] | unique | .[]' 2>/dev/null || true)"
  # Check issue-level comments (Qodo posts here)
  ISSUE_AUTHORS="$(gh api "repos/${REPO}/issues/${PR}/comments" --jq '[.[].user.login] | unique | .[]' 2>/dev/null || true)"

  ALL_AUTHORS="$(printf '%s\n%s' "$INLINE_AUTHORS" "$ISSUE_AUTHORS" | sort -u)"

  HAS_COPILOT=false
  HAS_QODO=false
  echo "$ALL_AUTHORS" | grep -qi "copilot" && HAS_COPILOT=true
  echo "$ALL_AUTHORS" | grep -qi "qodo" && HAS_QODO=true

  if $HAS_COPILOT && $HAS_QODO; then
    echo "READY: Both Copilot and Qodo have reviewed PR #${PR}"
    exit 0
  fi

  MISSING=""
  $HAS_COPILOT || MISSING="${MISSING} Copilot"
  $HAS_QODO || MISSING="${MISSING} Qodo"
  echo "Check ${i}/${MAX_ATTEMPTS}: waiting for${MISSING} (next check in ${POLL_INTERVAL}s)"
  sleep "$POLL_INTERVAL"
done

echo "TIMEOUT: Proceeding after ${MAX_ATTEMPTS} attempts. Missing reviewers may not have posted."
exit 0
