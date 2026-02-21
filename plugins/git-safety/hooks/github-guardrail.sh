#!/usr/bin/env bash
# Hook: github-guardrail.sh
# Trigger: PreToolUse (Bash)
# 위험한 원격 Git/GitHub 작업을 차단합니다
# 로컬 git 명령어는 제한하지 않습니다

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
  exit 0
fi

# 원격 관련 명령어가 아니면 바로 통과
echo "$COMMAND" | grep -qE '\bgit\s+push\b|\bgh\s' || exit 0

block() {
  echo "차단: $1"
  echo "  → $2"
  exit 2
}

# ═══════════════════════════════════════════════════
# 1. Force push 차단
#    --force-with-lease만 허용
# ═══════════════════════════════════════════════════
if echo "$COMMAND" | grep -qE '\bgit\s+push\b'; then
  # --force (--force-with-lease 제외)
  if echo "$COMMAND" | grep -qE -- '--force\b' && \
     ! echo "$COMMAND" | grep -q -- '--force-with-lease'; then
    block "git push --force 사용 불가" "--force-with-lease를 사용하세요"
  fi
  # -f 단축 플래그
  if echo "$COMMAND" | grep -qE '\s-f(\s|$)' && \
     ! echo "$COMMAND" | grep -q -- '--force-with-lease'; then
    block "git push -f 사용 불가" "--force-with-lease를 사용하세요"
  fi
fi

# ═══════════════════════════════════════════════════
# 2. 보호 브랜치 직접 push 차단
# ═══════════════════════════════════════════════════
if echo "$COMMAND" | grep -qE '\bgit\s+push\b'; then
  # git push 구간만 추출 (명령어 구분자 전까지)
  PUSH_SEGMENT=$(echo "$COMMAND" | grep -oE 'git\s+push[^;&|]*' | head -1)

  if [ -n "$PUSH_SEGMENT" ]; then
    # 명시적 대상: git push origin main
    if echo "$PUSH_SEGMENT" | grep -qE '\b(main|master)(\s|$)'; then
      block "보호 브랜치에 직접 push 불가" "feature 브랜치를 만들고 PR을 생성하세요"
    fi
    # Refspec: HEAD:main, feature:main
    if echo "$PUSH_SEGMENT" | grep -qE ':(main|master)(\s|$)'; then
      block "refspec으로 보호 브랜치 push 불가" "feature 브랜치를 만들고 PR을 생성하세요"
    fi
  fi

  # 보호 브랜치에서 인자 없이 git push
  if echo "$COMMAND" | grep -qE 'git\s+push\s*($|&&|;|\|)'; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
    if [[ "$CURRENT_BRANCH" =~ ^(main|master)$ ]]; then
      block "$CURRENT_BRANCH 브랜치에서 암묵적 push 불가" "feature 브랜치로 전환 후 push하세요"
    fi
  fi
fi

# ═══════════════════════════════════════════════════
# 3. GitHub CLI 가드레일
# ═══════════════════════════════════════════════════
echo "$COMMAND" | grep -qE '\bgh\s+pr\s+merge\b.*--admin' && \
  block "gh pr merge --admin은 브랜치 보호를 우회합니다" "--admin 플래그를 제거하세요"

echo "$COMMAND" | grep -qE '\bgh\s+repo\s+delete\b' && \
  block "gh repo delete는 되돌릴 수 없습니다" "Claude 외부에서 직접 실행하세요"

exit 0
