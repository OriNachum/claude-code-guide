#!/usr/bin/env bash
# Fetches all review comments for a PR in a structured format.
# Usage: fetch-pr-comments.sh <pr-number>
# Output: one block per comment with id, file, line, author, body
set -euo pipefail

PR="${1:?Usage: fetch-pr-comments.sh <pr-number>}"
REPO="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"

echo "=== INLINE REVIEW COMMENTS ==="
gh api "repos/${REPO}/pulls/${PR}/comments" --jq '.[] | "---\nid: \(.id)\nfile: \(.path) line: \(.line // .original_line)\nauthor: \(.user.login)\nbody: \(.body)\n"' 2>/dev/null || echo "(none)"

echo ""
echo "=== ISSUE-LEVEL COMMENTS ==="
gh api "repos/${REPO}/issues/${PR}/comments" --jq '.[] | "---\nauthor: \(.user.login)\nbody: \(.body[:500])\n"' 2>/dev/null || echo "(none)"
