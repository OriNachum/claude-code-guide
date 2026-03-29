#!/usr/bin/env bash
# Replies to a PR comment and resolves its thread.
# Usage: reply-and-resolve.sh <pr-number> <comment-id> <reply-body>
set -euo pipefail

PR="${1:?Usage: reply-and-resolve.sh <pr-number> <comment-id> <reply-body>}"
COMMENT_ID="${2:?Missing comment-id}"
REPLY_BODY="${3:?Missing reply body}"
REPO="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
OWNER="${REPO%%/*}"
NAME="${REPO##*/}"

# Post the reply
REPLY_ID="$(gh api "repos/${REPO}/pulls/${PR}/comments/${COMMENT_ID}/replies" -f body="${REPLY_BODY}" --jq '.id')"
echo "Replied to comment ${COMMENT_ID} (reply id: ${REPLY_ID})"

# Find and resolve the thread containing this comment
THREAD_ID="$(gh api graphql -f query="
{
  repository(owner: \"${OWNER}\", name: \"${NAME}\") {
    pullRequest(number: ${PR}) {
      reviewThreads(first: 50) {
        nodes {
          id
          isResolved
          comments(first: 5) {
            nodes { databaseId }
          }
        }
      }
    }
  }
}" --jq ".data.repository.pullRequest.reviewThreads.nodes[] | select(.comments.nodes[].databaseId == ${COMMENT_ID}) | .id" 2>/dev/null || true)"

if [ -n "$THREAD_ID" ]; then
  RESOLVED="$(gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"${THREAD_ID}\"}) { thread { isResolved } } }" --jq '.data.resolveReviewThread.thread.isResolved')"
  echo "Thread ${THREAD_ID} resolved: ${RESOLVED}"
else
  echo "No thread found for comment ${COMMENT_ID} (may be issue-level)"
fi
