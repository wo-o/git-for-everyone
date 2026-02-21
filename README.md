# git-for-everyone

Claude Code용 Git 안전장치 플러그인 모음입니다.

## 플러그인 목록

### git-guardrail

위험한 원격(remote) Git 작업을 자동 차단하는 PreToolUse hook입니다.
로컬 명령어는 제한하지 않습니다.

**차단 대상:**

| 작업 | 예시 | 대안 |
|---|---|---|
| Force push | `git push --force` | `--force-with-lease` 사용 |
| 보호 브랜치 push | `git push origin main` | feature 브랜치에서 PR 생성 |
| Refspec push | `git push origin HEAD:main` | feature 브랜치에서 PR 생성 |
| Admin 머지 | `gh pr merge --admin` | `--admin` 플래그 제거 |
| 저장소 삭제 | `gh repo delete` | Claude 외부에서 수동 실행 |

**허용 대상:**

모든 로컬 git 명령어 — `reset --hard`, `clean -f`, `checkout .`, `branch -D` 등

## 설치

```
/plugin marketplace add https://github.com/wo-o/git-for-everyone.git
/plugin install git-guardrail
```

설치 후 `/help` 명령어로 상세 가이드를 확인할 수 있습니다.

## 라이선스

MIT
