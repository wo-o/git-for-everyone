#!/usr/bin/env bash
# Hook: github-guardrail.sh
# Trigger: PreToolUse (Bash)
# Purpose: Block dangerous remote Git/GitHub operations
# Scope: Remote operations only — local git commands are not restricted

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Skip non-remote commands early
echo "$COMMAND" | grep -qE '\bgit\s+push\b|\bgh\s' || exit 0

block() {
  echo "BLOCKED: $1"
  echo "  → $2"
  exit 2
}

# ═══════════════════════════════════════════════════
# 1. Force push protection
#    --force-with-lease is allowed, everything else blocked
# ═══════════════════════════════════════════════════
if echo "$COMMAND" | grep -qE '\bgit\s+push\b'; then
  # --force (but not --force-with-lease)
  if echo "$COMMAND" | grep -qE -- '--force\b' && \
     ! echo "$COMMAND" | grep -q -- '--force-with-lease'; then
    block "git push --force" "Use --force-with-lease instead"
  fi
  # -f short flag
  if echo "$COMMAND" | grep -qE '\s-f(\s|$)' && \
     ! echo "$COMMAND" | grep -q -- '--force-with-lease'; then
    block "git push -f" "Use --force-with-lease instead"
  fi
fi

# ═══════════════════════════════════════════════════
# 2. Protected branch direct push
# ═══════════════════════════════════════════════════
if echo "$COMMAND" | grep -qE '\bgit\s+push\b'; then
  # Extract just the git push segment (up to command separator)
  PUSH_SEGMENT=$(echo "$COMMAND" | grep -oE 'git\s+push[^;&|]*' | head -1)

  if [ -n "$PUSH_SEGMENT" ]; then
    # Explicit target: git push origin main / git push --force-with-lease origin main
    if echo "$PUSH_SEGMENT" | grep -qE '\b(main|master)(\s|$)'; then
      block "Direct push to protected branch" "Create a feature branch and open a PR"
    fi
    # Refspec: HEAD:main, feature:main
    if echo "$PUSH_SEGMENT" | grep -qE ':(main|master)(\s|$)'; then
      block "Push to protected branch via refspec" "Create a feature branch and open a PR"
    fi
  fi

  # Bare "git push" while on protected branch
  if echo "$COMMAND" | grep -qE 'git\s+push\s*($|&&|;|\|)'; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
    if [[ "$CURRENT_BRANCH" =~ ^(main|master)$ ]]; then
      block "Implicit push while on $CURRENT_BRANCH" "Switch to a feature branch first"
    fi
  fi
fi

# ═══════════════════════════════════════════════════
# 3. GitHub CLI guardrails
# ═══════════════════════════════════════════════════
echo "$COMMAND" | grep -qE '\bgh\s+pr\s+merge\b.*--admin' && \
  block "gh pr merge --admin bypasses protections" "Remove --admin flag"

echo "$COMMAND" | grep -qE '\bgh\s+repo\s+delete\b' && \
  block "gh repo delete is irreversible" "Run manually outside Claude if intended"

exit 0
