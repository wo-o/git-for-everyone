---
name: setup
description: Git/GitHub 환경을 처음부터 설정합니다. "깃 셋업해줘", "레포 만들어줘", "깃허브 설정해줘", "처음 시작", "git setup" 같은 요청에 사용됩니다.
---

# Safe-Git 초기 설정

Git과 GitHub 환경을 처음부터 안전하게 설정합니다.
이미 완료된 단계는 자동으로 건너뜁니다.

모든 설명은 한국어로, Git을 처음 쓰는 사용자 눈높이에 맞추세요.

---

## 1단계: 환경 확인

아래 명령어를 **병렬로** 실행하세요:

1. `which git` — Git 설치 여부
2. `which gh` — GitHub CLI 설치 여부
3. `which gitleaks` — gitleaks 설치 여부
4. `gh auth status 2>&1` — GitHub 인증 상태

### 1-1. Git 미설치

```
Git이 설치되어 있지 않습니다.
Git은 파일의 변경 이력을 관리하는 도구입니다.

터미널에서 아래 명령어를 직접 실행하세요:
  xcode-select --install

설치 팝업이 나타나면 "설치" 버튼을 클릭하세요.
설치가 완료되면 다시 /setup 을 실행해주세요.
```

xcode-select는 GUI 팝업이 필요하므로 Claude가 직접 실행하지 마세요. 안내만 제공하고 멈추세요.

### 1-2. gh CLI 미설치

사용자에게 설명하세요:

```
GitHub CLI(gh)가 설치되어 있지 않습니다.
gh는 터미널에서 GitHub 레포지토리를 만들고 관리하는 도구입니다.
지금 설치하겠습니다.
```

실행:

```bash
brew install gh
```

### 1-3. gitleaks 미설치

사용자에게 설명하세요:

```
gitleaks가 설치되어 있지 않습니다.
gitleaks는 코드에 비밀번호나 API 키가 포함되지 않았는지 자동으로 검사하는 도구입니다.
지금 설치하겠습니다.
```

실행:

```bash
brew install gitleaks
```

---

## 2단계: GitHub 인증

**완료 조건:** `gh auth status` 출력에 "Logged in"이 포함됨

인증되지 않은 경우 사용자에게 안내하세요:

```
GitHub에 로그인해야 합니다.
지금부터 로그인 과정을 시작합니다. 웹 브라우저가 열리면 안내에 따라 진행하세요.
```

실행:

```bash
gh auth login --web --git-protocol ssh
```

로그인 완료 후 확인:

```bash
gh auth status
```

"Logged in" 메시지가 나오면 성공입니다.

---

## 3단계: 저장소 설정

**완료 조건:** 현재 디렉토리가 Git 저장소이고 GitHub 리모트가 연결됨

AskUserQuestion으로 물어보세요:

- question: "저장소를 어떻게 준비하시겠습니까?"
- header: "저장소"
- options:
  - "새 저장소 만들기" — GitHub에 새 저장소를 만들고 시작합니다
  - "기존 저장소 clone" — GitHub에 이미 있는 저장소를 가져옵니다

### 새 저장소 만들기

AskUserQuestion으로 저장소 이름을 물어보세요:

- question: "저장소 이름을 입력하세요. GitHub에 이 이름으로 저장소가 만들어집니다."
- header: "이름"
- options:
  - 현재 폴더 이름을 기본 옵션으로 제안

AskUserQuestion으로 공개 여부를 물어보세요:

- question: "저장소를 공개(public)로 만들까요, 비공개(private)로 만들까요?"
- header: "공개 여부"
- options:
  - "비공개 (Recommended)" — 나와 초대한 사람만 볼 수 있습니다
  - "공개" — 누구나 볼 수 있습니다

실행 (비공개 선택 시):

```bash
gh repo create <이름> --private --clone
cd <이름>
```

실행 (공개 선택 시):

```bash
gh repo create <이름> --public --clone
cd <이름>
```

main 브랜치가 존재하도록 초기 커밋을 만드세요:

```bash
echo "# <이름>" > README.md
git add README.md
git commit -m "docs: 프로젝트 시작"
git push -u origin main
```

사용자에게 설명하세요:

```
저장소를 만들고 첫 번째 기록(커밋)을 생성했습니다.
이렇게 하면 main 브랜치가 만들어져서 앞으로의 작업이 원활해집니다.
```

### 기존 저장소 clone

AskUserQuestion으로 저장소 URL 또는 이름을 물어보세요:

- question: "clone할 저장소의 URL 또는 'owner/repo' 형식의 이름을 입력하세요."
- header: "저장소"
- options:
  - "직접 입력"

실행:

```bash
gh repo clone <URL 또는 owner/repo>
cd <repo-name>
```

main 브랜치가 있는지 확인하세요:

```bash
git branch -a | grep -E "(main|master)"
```

main 브랜치가 없는 경우:

```bash
git checkout -b main
echo "# <repo-name>" > README.md
git add README.md
git commit -m "docs: 프로젝트 시작"
git push -u origin main
```

---

## 4단계: 모드 선택

AskUserQuestion으로 사용 방식을 물어보세요:

- question: "이 저장소를 어떻게 사용하시겠습니까?"
- header: "사용 방식"
- options:
  - "혼자 사용 (solo)" — 나 혼자 파일을 관리합니다. main 브랜치에 바로 저장합니다.
  - "여러 명이 함께 (collaborative)" — 다른 사람과 함께 작업합니다. 브랜치와 PR을 사용합니다.

### collaborative 모드 추가 설정

AskUserQuestion으로 브랜치 이름 패턴을 확인하세요:

- question: "브랜치 이름을 어떤 형식으로 만들까요? 브랜치는 작업 공간을 나누는 역할을 합니다."
- header: "브랜치 이름"
- options:
  - "{user}/{topic} (Recommended)" — 예: hong/add-logo, kim/fix-typo
  - "{topic}" — 예: add-logo, fix-typo

AskUserQuestion으로 머지 전략을 확인하세요:

- question: "브랜치를 합칠 때 어떤 방식을 사용할까요?"
- header: "머지 방식"
- options:
  - "squash (Recommended)" — 여러 기록을 하나로 합쳐서 깔끔하게 정리합니다
  - "merge" — 모든 기록을 그대로 유지합니다

---

## 5단계: 안전장치 설치

사용자에게 설명하세요:

```
안전장치를 설치합니다. 세 가지를 설정합니다:

1. 설정 파일 (.git-for-everyone.yml) — 이 저장소의 사용 규칙을 저장합니다
2. .gitignore 업데이트 — 비밀번호, API 키 같은 민감한 파일이 올라가지 않도록 막습니다
3. gitleaks 훅 설치 — 저장할 때마다 자동으로 보안 검사를 합니다
```

### 5-1. 설정 파일 생성

`.git-for-everyone.yml`을 프로젝트 루트에 생성하세요.

solo 모드:

```yaml
project:
  name: "<프로젝트 이름>"

mode: solo
```

collaborative 모드:

```yaml
project:
  name: "<프로젝트 이름>"

mode: collaborative

branching:
  naming: "<선택한 패턴>"
  merge_strategy: <선택한 전략>
```

### 5-2. .gitignore 업데이트

`.gitignore` 파일이 없으면 생성하고, 있으면 아래 항목이 포함되어 있는지 확인하세요.
누락된 항목만 추가하세요:

```
# Secrets & credentials
.env
.env.*
*.pem
*.key
credentials.json
secrets.yml
```

### 5-3. gitleaks pre-commit hook 설치

`.git/hooks/pre-commit` 파일을 생성하세요:

```bash
#!/bin/sh
# gitleaks pre-commit hook — installed by safe-git
# 커밋할 때마다 비밀번호/API 키가 포함되지 않았는지 검사합니다

if which gitleaks > /dev/null 2>&1; then
    gitleaks git --pre-commit --staged --no-banner
    if [ $? -ne 0 ]; then
        echo ""
        echo "보안 검사 실패: 커밋하려는 파일에 비밀번호나 API 키가 포함되어 있습니다."
        echo ".env 파일로 옮기고 .gitignore에 추가하세요."
        echo ""
        exit 1
    fi
else
    echo "경고: gitleaks가 설치되어 있지 않습니다. brew install gitleaks 로 설치하세요."
fi
```

실행 권한을 부여하세요:

```bash
chmod +x .git/hooks/pre-commit
```

### 5-4. 안전장치 커밋

설치한 파일들을 커밋하세요:

```bash
git add .git-for-everyone.yml .gitignore
git commit -m "chore: safe-git 안전장치 설정"
git push
```

---

## 6단계: 설정 요약

모든 단계가 완료되면 아래 형식으로 출력하세요:

```
설정 완료!

  저장소:     <owner>/<repo-name> (<public/private>)
  사용 방식:  <solo 또는 collaborative>
  브랜치 이름: <패턴> (collaborative인 경우)
  보안:       gitleaks pre-commit hook 활성화

다음: /work 을 실행하여 작업을 시작하세요!
```
