# git-for-everyone

Claude Code에서 Git을 안전하고 쉽게 사용할 수 있도록 도와주는 플러그인 모음입니다.

## 왜 필요한가요?

Claude Code는 강력한 코딩 에이전트지만, 실수로 위험한 git 명령어를 실행할 수 있습니다.

- `git push --force`로 동료의 커밋을 덮어쓰기
- `git push origin main`으로 리뷰 없이 프로덕션 반영
- `gh repo delete`로 저장소를 되돌릴 수 없게 삭제
- `git commit` on main — feature 브랜치 없이 직접 커밋

이 플러그인 모음은 3가지 독립된 기능을 제공합니다:

| 플러그인 | 설명 |
|---|---|
| **git-safety** | 위험한 원격 Git 작업 자동 차단 |
| **git-workflow** | GitHub Flow 워크플로우 안내 |
| **git-onboarding** | Git 초보자를 위한 단계별 설정 가이드 |

## 설치

Claude Code에서 마켓플레이스를 추가한 후, 필요한 플러그인을 설치하세요.

```
/plugin marketplace add https://github.com/wo-o/git-for-everyone.git
```

### 전체 설치 (권장)

```
/plugin install git-safety
/plugin install git-workflow
/plugin install git-onboarding
```

### 개별 설치

필요한 플러그인만 골라서 설치할 수 있습니다.

```
/plugin install git-safety       # 원격 작업 안전장치만
/plugin install git-workflow     # 워크플로우 안내만
/plugin install git-onboarding   # 초보자 가이드만
```

## git-safety — 원격 작업 안전장치

위험한 원격 Git/GitHub 작업을 자동으로 차단합니다.

### 차단 대상

| 작업 | 예시 | 차단 이유 | 대안 |
|---|---|---|---|
| Force push | `git push --force` | 동료 커밋 덮어쓰기 위험 | `--force-with-lease` 사용 |
| 보호 브랜치 push | `git push origin main` | 리뷰 없이 프로덕션 반영 | feature 브랜치에서 PR 생성 |
| Refspec push | `git push origin HEAD:main` | 우회 경로로 main에 push | feature 브랜치에서 PR 생성 |
| Admin 머지 | `gh pr merge --admin` | 브랜치 보호 규칙 무시 | `--admin` 플래그 제거 |
| 저장소 삭제 | `gh repo delete` | 되돌릴 수 없음 | Claude 외부에서 직접 실행 |

### 허용 대상

모든 로컬 git 명령어는 제한 없이 사용할 수 있습니다.

```
git reset --hard HEAD~3       # 로컬 커밋 되돌리기
git clean -fd                 # 추적되지 않는 파일 정리
git checkout .                # 변경사항 되돌리기
git branch -D old-feature     # 로컬 브랜치 삭제
git push origin feature-login # feature 브랜치 push (보호 대상 아님)
```

### 명령어

| 명령어 | 설명 |
|---|---|
| `/git-safety:help` | 차단 규칙, 동작 방식, FAQ |
| `/git-safety:scenarios` | 실제 차단/허용 시나리오 6가지 |

### 커스터마이징

보호 브랜치를 추가하고 싶다면 `github-guardrail.sh`의 패턴을 수정하세요.

```bash
# 기본값: main, master
(main|master)

# develop 추가 예시
(main|master|develop)
```

## git-workflow — GitHub Flow 안내

main/master 브랜치에서의 직접 commit/merge를 차단하고, 현재 상태에 맞는 다음 단계를 안내합니다.

### 차단 대상

| 명령어 | 브랜치 | 결과 |
|---|---|---|
| `git commit` | main/master | 차단 — feature 브랜치를 만들고 작업하세요 |
| `git merge feature` | main/master | 차단 — PR을 통해 머지하세요 |
| `git commit` | feature/* | 허용 |
| `git merge main` | feature/* | 허용 |

### 명령어

| 명령어 | 설명 |
|---|---|
| `/git-workflow:workflow` | 현재 git 상태를 분석하고 GitHub Flow 다음 단계 안내 |

## git-onboarding — 초보자 가이드

Git 설치부터 첫 PR까지, 처음 사용자를 위한 10단계 안내입니다.

### 명령어

| 명령어 | 설명 |
|---|---|
| `/git-onboarding:setup` | Git/GitHub 초기 설정 (Git 설치 ~ SSH 연결 ~ 저장소 준비) |
| `/git-onboarding:step` | 전체 10단계 진행 상황 체크리스트 |

## 차단 시 동작

위험한 명령어가 감지되면 실행 자체가 차단되고, 다음과 같은 메시지가 표시됩니다.

```
차단: git push --force 사용 불가
  → --force-with-lease를 사용하세요
```

```
차단: main 브랜치에서 직접 commit 불가
  → feature 브랜치를 만들고 작업하세요: git checkout -b feat/my-feature
```

## 라이선스

MIT
