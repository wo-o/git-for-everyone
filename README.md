# git-for-everyone

Claude Code가 위험한 Git 원격 작업을 실행하지 못하도록 자동으로 차단하는 플러그인입니다.

## 왜 필요한가요?

Claude Code는 강력한 코딩 에이전트지만, 실수로 위험한 git 명령어를 실행할 수 있습니다.

- `git push --force`로 동료의 커밋을 덮어쓰기
- `git push origin main`으로 리뷰 없이 프로덕션 반영
- `gh repo delete`로 저장소를 되돌릴 수 없게 삭제

이 플러그인은 이런 원격(remote) 작업을 사전에 차단하고, 안전한 대안을 안내합니다.
로컬 작업(`reset`, `clean`, `checkout` 등)은 전혀 제한하지 않습니다.

## 설치

Claude Code에서 아래 두 명령어를 순서대로 실행하세요.

```
/plugin marketplace add https://github.com/wo-o/git-for-everyone.git
/plugin install git-guardrail
```

설치 완료 후 별도 설정 없이 바로 동작합니다.

## 차단 대상

| 작업 | 예시 | 차단 이유 | 대안 |
|---|---|---|---|
| Force push | `git push --force` | 동료 커밋 덮어쓰기 위험 | `--force-with-lease` 사용 |
| 보호 브랜치 push | `git push origin main` | 리뷰 없이 프로덕션 반영 | feature 브랜치에서 PR 생성 |
| Refspec push | `git push origin HEAD:main` | 우회 경로로 main에 push | feature 브랜치에서 PR 생성 |
| Admin 머지 | `gh pr merge --admin` | 브랜치 보호 규칙 무시 | `--admin` 플래그 제거 |
| 저장소 삭제 | `gh repo delete` | 되돌릴 수 없음 | Claude 외부에서 직접 실행 |

## 허용 대상

모든 로컬 git 명령어는 제한 없이 사용할 수 있습니다.

```
git reset --hard HEAD~3       # 로컬 커밋 되돌리기
git clean -fd                 # 추적되지 않는 파일 정리
git checkout .                # 변경사항 되돌리기
git branch -D old-feature     # 로컬 브랜치 삭제
git push origin feature-login # feature 브랜치 push
```

## 사용 가능한 명령어

| 명령어 | 설명 |
|---|---|
| `/help` | 가드레일 동작 방식, 차단 규칙, FAQ 안내 |
| `/scenarios` | 실제 차단/허용 시나리오 6가지 예시 |

## 차단 시 동작

위험한 명령어가 감지되면 실행 자체가 차단되고, 다음과 같은 메시지가 표시됩니다.

```
차단: git push --force 사용 불가
  → --force-with-lease를 사용하세요
```

## 커스터마이징

보호 브랜치를 추가하고 싶다면 `github-guardrail.sh`의 패턴을 수정하세요.

```bash
# 기본값: main, master
(main|master)

# develop 추가 예시
(main|master|develop)
```

## 라이선스

MIT
