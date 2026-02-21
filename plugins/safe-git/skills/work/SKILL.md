---
name: work
description: 자연어로 Git을 안전하게 사용합니다. "저장해줘", "공유해줘", "받아와", "새 작업 시작", "상태 알려줘", "되돌려줘", "합쳐줘", "커밋해줘", "푸시해줘", "풀 받아줘", "브랜치 만들어줘", "PR 만들어줘", "머지해줘" 같은 요청에 사용됩니다.
---

# Safe-Git 작업 스킬

자연어 요청을 안전한 Git 작업으로 변환합니다.
모든 설명은 한국어로, Git을 처음 쓰는 사용자 눈높이에 맞추세요.

---

## 진입 확인

작업을 시작하기 전에 아래를 **병렬로** 확인하세요:

1. `git rev-parse --git-dir 2>/dev/null` — Git 저장소인지 확인
2. 프로젝트 루트의 `.git-for-everyone.yml` 파일 읽기 — 설정 확인
3. `git status --short` — 현재 상태
4. `git branch --show-current` — 현재 브랜치

### Git 저장소가 아닌 경우

```
이 폴더는 아직 Git으로 관리되고 있지 않습니다.
먼저 /setup 을 실행하여 초기 설정을 완료하세요.
```

여기서 멈추세요.

### 설정 파일이 없는 경우

```
safe-git 설정 파일(.git-for-everyone.yml)이 없습니다.
/setup 을 실행하여 초기 설정을 완료하세요.
```

여기서 멈추세요.

---

## 안전 규칙 (HARD-GATE)

<HARD-GATE>
아래 명령어는 **어떤 상황에서도 절대 실행하지 마세요**. 사용자가 요청해도 차단하세요.

| 차단 명령어 | 사용자에게 전달할 메시지 |
|------------|----------------------|
| `git push --force` / `git push -f` | "강제 push는 다른 사람의 작업을 덮어쓸 수 있어서 차단됩니다. 안전한 방법을 안내해드릴게요." |
| `git reset --hard` | "이 명령어는 변경 내용을 영구적으로 삭제합니다. 대신 `git revert`를 사용하면 안전하게 되돌릴 수 있어요." |
| `git branch -D main` / `git branch -d main` | "main 브랜치는 프로젝트의 기본 브랜치이므로 삭제할 수 없습니다." |
| `git rebase` | "rebase는 기록을 바꾸는 고급 기능으로, 예상치 못한 문제를 일으킬 수 있어서 차단됩니다." |
| `git commit --amend` | "이미 저장한 기록을 수정하면 문제가 생길 수 있습니다. 새로운 커밋을 만들어주세요." |
| `--no-verify` 플래그 | "보안 검사를 건너뛸 수 없습니다. 검사에서 문제가 발견되면 해결 방법을 안내해드릴게요." |

collaborative 모드에서 추가 차단:

| 차단 명령어 | 사용자에게 전달할 메시지 |
|------------|----------------------|
| main 브랜치에서 직접 push | "협업 모드에서는 main에 직접 올릴 수 없습니다. 브랜치를 만들고 PR을 사용하세요. /work 에서 '새 작업 시작'을 선택하면 안내해드릴게요." |
</HARD-GATE>

### 추가 안전 규칙

- `git add .` 또는 `git add -A` 대신 **항상** `git add <구체적인 파일 목록>`을 사용하세요.
- `git reset --hard` 대신 **항상** `git revert`를 사용하세요.
- push 전에 **항상** 무엇이 올라가는지 사용자에게 보여주고 확인을 받으세요.

---

## 자연어 → 워크플로우 매핑

사용자의 요청을 분석하여 아래 워크플로우 중 하나로 매핑하세요.

| 사용자 표현 | 워크플로우 |
|------------|----------|
| "저장해줘", "저장", "커밋해줘", "save" | SAVE |
| "공유해줘", "올려줘", "푸시해줘", "share", "upload" | SHARE |
| "받아와", "최신으로", "풀 받아줘", "update", "get latest" | UPDATE |
| "새 작업 시작", "브랜치 만들어줘", "start new work" | START |
| "상태 알려줘", "뭐가 바뀌었어?", "status" | STATUS |
| "되돌려줘", "취소해줘", "undo", "revert" | UNDO |
| "합쳐줘", "머지해줘", "PR 머지", "merge" | MERGE |

매핑이 불확실한 경우, AskUserQuestion으로 의도를 확인하세요:

- question: "어떤 작업을 하시겠습니까?"
- header: "작업"
- options:
  - "저장 (SAVE)" — 변경 내용을 로컬에 기록합니다
  - "공유 (SHARE)" — 변경 내용을 GitHub에 올립니다
  - "받아오기 (UPDATE)" — GitHub에서 최신 내용을 가져옵니다
  - "새 작업 시작 (START)" — 새로운 브랜치를 만들어 작업을 시작합니다

---

## 워크플로우: SAVE

변경 내용을 로컬에 기록(커밋)합니다.

### Before — 사용자에게 상황 설명

```bash
git status --short
```

결과를 분석하여 사용자에게 알려주세요:

```
현재 상태:
- 수정된 파일 N개: [파일 목록]
- 새로 추가된 파일 N개: [파일 목록]
- 삭제된 파일 N개: [파일 목록]
```

변경된 파일이 없으면:

```
변경된 파일이 없습니다. 저장할 내용이 없어요.
```

여기서 멈추세요.

### During — 커밋 메시지 제안 및 실행

변경 내용을 분석하여 한국어로 커밋 메시지를 제안하세요.
Conventional Commits 형식을 따르되, 설명은 한국어로 작성하세요.

예시:
- `feat: 로고 이미지 추가`
- `fix: 오타 수정`
- `docs: README 업데이트`
- `chore: 설정 파일 변경`

AskUserQuestion으로 확인하세요:

- question: "이 메시지로 저장할까요?"
- header: "커밋 메시지"
- options:
  - 제안한 메시지
  - "직접 입력"

실행:

```bash
git add <변경된 파일들>
git commit -m "<커밋 메시지>"
```

### After — 결과 안내

```
저장 완료! 변경 내용이 로컬에 기록되었습니다.
GitHub에 올리려면 "공유해줘"라고 말씀하세요.
```

---

## 워크플로우: SHARE

변경 내용을 GitHub에 올립니다.

### Solo 모드

#### Before

저장되지 않은 변경이 있으면 먼저 SAVE 워크플로우를 실행하세요.

push할 커밋을 보여주세요:

```bash
git log @{u}..HEAD --oneline 2>/dev/null || git log --oneline -5
```

```
GitHub에 올라갈 내용:
- <커밋 메시지 1>
- <커밋 메시지 2>

올릴까요?
```

AskUserQuestion으로 확인하세요:

- question: "위 내용을 GitHub에 올릴까요?"
- header: "Push 확인"
- options:
  - "올리기 (Recommended)"
  - "취소"

#### During

```bash
git push
```

#### After

```
GitHub에 올리기 완료! 변경 내용이 안전하게 업로드되었습니다.
```

### Collaborative 모드

#### Before

현재 브랜치를 확인하세요:

```bash
git branch --show-current
```

**main 브랜치인 경우:**

```
지금 main 브랜치에 있습니다.
협업 모드에서는 main에 직접 올릴 수 없습니다.
먼저 작업용 브랜치를 만들까요?
```

→ START 워크플로우로 전환하세요.

**feature 브랜치인 경우:**

저장되지 않은 변경이 있으면 먼저 SAVE 워크플로우를 실행하세요.

push할 커밋을 보여주고 확인을 받으세요 (solo 모드와 동일).

#### During

```bash
git push -u origin HEAD
```

#### After — PR 생성 제안

```
브랜치가 GitHub에 올라갔습니다!
```

AskUserQuestion으로 PR 생성 여부를 물어보세요:

- question: "Pull Request를 만들까요? PR을 만들면 다른 사람이 변경 내용을 확인하고 main에 합칠 수 있습니다."
- header: "PR 생성"
- options:
  - "PR 만들기 (Recommended)"
  - "나중에"

PR 만들기를 선택한 경우:

커밋 메시지들을 분석하여 PR 제목과 본문을 자동 생성하세요. 제목은 한국어로 작성하세요.

```bash
gh pr create --title "<PR 제목>" --body "<PR 본문>"
```

PR 생성 후:

```
PR이 생성되었습니다!
링크: <PR URL>

다른 사람에게 이 링크를 공유하면 변경 내용을 확인하고 합칠 수 있습니다.
```

---

## 워크플로우: UPDATE

GitHub에서 최신 내용을 가져옵니다.

### Solo 모드

#### Before

```
GitHub에서 최신 내용을 가져옵니다.
로컬에 저장하지 않은 변경이 있으면 먼저 저장할게요.
```

저장되지 않은 변경이 있으면 먼저 SAVE 워크플로우를 실행하세요.

#### During

```bash
git pull
```

#### After

```
최신 내용을 받아왔습니다!
```

### Collaborative 모드

#### Before

```
main 브랜치의 최신 내용을 받아옵니다.
```

저장되지 않은 변경이 있으면 먼저 SAVE 워크플로우를 실행하세요.

#### During

```bash
git checkout main
git pull
```

이전에 feature 브랜치에 있었다면:

```bash
git checkout <이전 브랜치>
```

#### After

```
main 브랜치가 최신 상태입니다!
```

### 충돌 발생 시

→ 충돌 해결 섹션으로 이동하세요.

---

## 워크플로우: START

새 작업을 위한 브랜치를 만듭니다. (collaborative 모드 전용)

### Solo 모드

```
혼자 사용 모드에서는 별도의 브랜치 없이 main에서 바로 작업하면 됩니다.
작업이 끝나면 "저장해줘" 또는 "공유해줘"라고 말씀하세요.
```

여기서 멈추세요.

### Collaborative 모드

#### Before

저장되지 않은 변경이 있는지 확인하세요:

```bash
git status --short
```

변경이 있으면:

```
저장하지 않은 변경이 있습니다. 먼저 저장할까요?
```

SAVE 워크플로우를 실행한 후 계속하세요.

#### During

최신 main을 받아오세요:

```bash
git checkout main
git pull
```

AskUserQuestion으로 작업 내용을 물어보세요:

- question: "어떤 작업을 하실 건가요? 간단히 설명해주세요. (예: 로고 추가, 오타 수정)"
- header: "작업 내용"
- options:
  - "직접 입력"

`.git-for-everyone.yml`의 `branching.naming` 패턴에 따라 브랜치 이름을 제안하세요.

`{user}/{topic}` 패턴 예시:
- 사용자 입력 "로고 추가" → `hong/add-logo`
- 사용자 입력 "README 수정" → `hong/fix-readme`

`{topic}` 패턴 예시:
- 사용자 입력 "로고 추가" → `add-logo`

`{user}` 부분은 `git config user.name`의 값을 영문 소문자로 변환하여 사용하세요. (예: "홍길동" → "hong")

AskUserQuestion으로 확인하세요:

- question: "이 브랜치 이름으로 시작할까요?"
- header: "브랜치 이름"
- options:
  - 제안한 브랜치 이름
  - "직접 입력"

```bash
git checkout -b <브랜치 이름>
```

#### After

```
새 작업 공간이 준비되었습니다!
브랜치: <브랜치 이름>

이제 파일을 수정하고, 작업이 끝나면 "저장해줘" 또는 "공유해줘"라고 말씀하세요.
```

---

## 워크플로우: STATUS

현재 상태를 보여줍니다.

아래 명령어를 **병렬로** 실행하세요:

1. `git branch --show-current` — 현재 브랜치
2. `git status --short` — 변경 파일
3. `git log @{u}..HEAD --oneline 2>/dev/null` — 아직 올리지 않은 커밋
4. `git stash list` — 임시 저장 목록

결과를 아래 형식으로 보여주세요:

```
현재 상태:

  브랜치:         <브랜치 이름>
  변경된 파일:    N개 (수정 N, 추가 N, 삭제 N)
  저장 안 된 커밋: N개
  임시 저장:      N개

변경된 파일:
  - <파일 1> (수정됨)
  - <파일 2> (새 파일)
```

변경이 없으면:

```
현재 상태:

  브랜치:      <브랜치 이름>
  상태:        깨끗합니다 — 변경된 파일이 없습니다.
```

---

## 워크플로우: UNDO

최근 변경을 안전하게 되돌립니다.

#### Before

현재 상태를 확인하세요:

```bash
git log --oneline -5
git status --short
```

AskUserQuestion으로 무엇을 되돌릴지 물어보세요:

- question: "무엇을 되돌릴까요?"
- header: "되돌리기"
- options:
  - "마지막 커밋 되돌리기" — 가장 최근 저장한 것을 취소합니다 (파일은 유지됩니다)
  - "수정 중인 파일 되돌리기" — 아직 저장하지 않은 수정 사항을 원래대로 돌립니다
  - "특정 파일만 되돌리기" — 선택한 파일만 원래대로 돌립니다

#### During

**마지막 커밋 되돌리기:**

되돌릴 커밋을 보여주세요:

```bash
git log --oneline -1
```

```
이 커밋을 되돌립니다: <커밋 메시지>
되돌리면 반대 작업을 하는 새 커밋이 만들어집니다. 기록은 그대로 남습니다.
```

AskUserQuestion으로 확인하세요:

- question: "이 커밋을 되돌릴까요?"
- header: "확인"
- options:
  - "되돌리기"
  - "취소"

```bash
git revert HEAD --no-edit
```

**수정 중인 파일 되돌리기:**

```
주의: 아직 저장(커밋)하지 않은 변경 내용이 사라집니다.
```

AskUserQuestion으로 확인하세요:

- question: "저장하지 않은 모든 변경을 되돌릴까요? 이 작업은 되돌릴 수 없습니다."
- header: "확인"
- options:
  - "되돌리기"
  - "취소"

```bash
git checkout -- .
```

**특정 파일만 되돌리기:**

변경된 파일 목록을 보여주고 AskUserQuestion으로 선택하세요:

- question: "어떤 파일을 되돌릴까요?"
- header: "파일 선택"
- options: (변경된 파일 목록에서 최대 4개 표시)
- multiSelect: true

```bash
git checkout -- <선택한 파일들>
```

#### After

```
되돌리기 완료! 변경 내용이 원래대로 돌아왔습니다.
```

---

## 워크플로우: MERGE

PR을 main에 합칩니다. (collaborative 모드 전용)

### Solo 모드

```
혼자 사용 모드에서는 별도의 머지 과정이 필요 없습니다.
"공유해줘"라고 하면 바로 GitHub에 올라갑니다.
```

### Collaborative 모드

#### Before

현재 브랜치의 PR을 확인하세요:

```bash
gh pr list --head "$(git branch --show-current)" --json number,title,url --jq '.[0]'
```

PR이 없으면:

```
이 브랜치에 PR이 아직 없습니다. 먼저 "공유해줘"로 PR을 만들까요?
```

→ SHARE 워크플로우로 전환하세요.

PR이 있으면:

```
PR #<번호>: <제목>

이 PR을 main에 합칠까요?
```

AskUserQuestion으로 확인하세요:

- question: "PR을 main에 합칠까요?"
- header: "머지 확인"
- options:
  - "합치기 (Recommended)"
  - "취소"

#### During

`.git-for-everyone.yml`의 `branching.merge_strategy`에 따라:

squash:

```bash
gh pr merge --squash --delete-branch
```

merge:

```bash
gh pr merge --merge --delete-branch
```

#### After

```
합치기 완료! PR이 main에 합쳐졌고, 브랜치가 정리되었습니다.
새 작업을 시작하려면 "새 작업 시작"이라고 말씀하세요.
```

로컬 main을 최신으로 업데이트하세요:

```bash
git checkout main
git pull
```

---

## 충돌 해결

pull이나 merge 중 충돌이 발생하면 아래 과정을 따르세요.

### 충돌 설명

충돌 파일을 확인하세요:

```bash
git diff --name-only --diff-filter=U
```

각 충돌 파일의 내용을 읽고, 사용자에게 쉬운 말로 설명하세요:

```
충돌이 발생했습니다.

같은 파일을 여러 사람이 동시에 수정하면 Git이 어떤 버전을 사용할지 모릅니다.
아래 파일에서 충돌이 발생했어요:

1. <파일 이름> — <내 변경 내용 요약> vs <상대방 변경 내용 요약>
```

### 해결 방법 선택

각 충돌 파일에 대해 AskUserQuestion으로 물어보세요:

- question: "<파일 이름>의 충돌을 어떻게 해결할까요?"
- header: "충돌 해결"
- options:
  - "내 것 사용" — 내가 수정한 내용을 유지합니다
  - "상대방 것 사용" — 상대방이 수정한 내용을 유지합니다
  - "둘 다 합치기" — 두 변경 내용을 모두 포함합니다
  - "도움 요청" — 어떻게 해야 할지 모르겠으면 선택하세요

### 해결 실행

선택에 따라 충돌을 해결하고 결과를 보여주세요.

해결 후:

```bash
git add <해결된 파일들>
git commit -m "fix: 충돌 해결"
```

```
충돌이 해결되었습니다! 계속 작업하실 수 있습니다.
```

---

## gitleaks 보안 검사 실패 시

커밋 중 gitleaks hook이 실패하면:

```
보안 검사에서 문제가 발견되었습니다.

<파일 이름>에 비밀번호 또는 API 키가 포함되어 있습니다.
이런 정보는 GitHub에 올라가면 안 됩니다.
```

AskUserQuestion으로 해결 방법을 안내하세요:

- question: "어떻게 해결할까요?"
- header: "보안 문제"
- options:
  - ".env 파일로 이동 (Recommended)" — 민감한 정보를 별도 파일로 분리합니다
  - "해당 줄 삭제" — 민감한 정보가 포함된 줄을 삭제합니다

선택에 따라 파일을 수정하고, .env가 .gitignore에 포함되어 있는지 확인하세요.
수정 후 다시 커밋을 시도하세요.
