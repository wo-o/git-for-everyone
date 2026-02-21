---
name: setup
description: Git과 GitHub 초기 설정을 단계별로 진행합니다. "git 설정", "처음 시작", "SSH 설정", "깃 세팅" 같은 요청에 사용됩니다.
---

# Git 초기 설정 가이드

Git과 GitHub를 처음 사용하기 위한 설정을 단계별로 진행합니다.
이미 완료된 단계는 자동으로 건너뜁니다.

## 상태 수집

아래 6개 명령어를 **모두 병렬로** 실행하세요:

1. `which git` — Git 설치 여부
2. `git config --global user.name` — 사용자 이름
3. `git config --global user.email` — 이메일
4. `test -f ~/.ssh/id_ed25519 && echo "exists" || test -f ~/.ssh/id_rsa && echo "exists" || echo "none"` — SSH 키 존재 여부
5. `ssh -T git@github.com 2>&1` — GitHub SSH 연결 (exit code 1 + "successfully authenticated"이면 성공)
6. `git rev-parse --git-dir 2>/dev/null && echo "repo" || echo "no-repo"` — Git 저장소 여부

## 진행 규칙

- 결과를 분석하여 이미 완료된 단계는 건너뛰세요.
- 첫 번째 미완료 단계부터 순서대로 진행하세요.
- 각 단계를 하나씩 완료한 후 다음 단계로 넘어가세요.
- 사용자 입력이 필요한 단계에서는 반드시 AskUserQuestion을 사용하세요.
- 모든 설명은 한국어로, Git을 처음 쓰는 사용자 눈높이에 맞추세요.

## 단계 1: Git 설치 확인

**완료 조건:** `which git`이 경로를 반환함

미설치인 경우 안내하세요:

```
Git이 설치되어 있지 않습니다.

터미널에서 아래 명령어를 직접 실행하세요:
  xcode-select --install

설치 팝업이 나타나면 "설치" 버튼을 클릭하세요.
설치가 완료되면 다시 /git-onboarding:setup 을 실행해주세요.
```

xcode-select는 GUI 팝업이 필요하므로 Claude가 직접 실행하지 마세요. 안내만 제공하고 이 단계에서 멈추세요.

## 단계 2: 사용자 이름 설정

**완료 조건:** `git config --global user.name`이 비어있지 않음

AskUserQuestion으로 이름을 물어보세요:

- question: "Git에서 사용할 이름을 입력하세요. 커밋 기록에 남는 이름입니다."
- header: "이름"
- options:
  - 현재 시스템 사용자 이름을 기본 옵션으로 제안

이름을 받으면 실행하세요:

```
git config --global user.name "<입력받은 이름>"
```

## 단계 3: 이메일 설정

**완료 조건:** `git config --global user.email`이 비어있지 않음

AskUserQuestion으로 이메일을 물어보세요:

- question: "Git에서 사용할 이메일을 입력하세요. GitHub 계정과 같은 이메일을 권장합니다. 이메일을 공개하고 싶지 않다면 GitHub의 noreply 이메일을 사용할 수 있습니다 (GitHub > Settings > Emails에서 확인)."
- header: "이메일"
- options:
  - "noreply 이메일 사용" — GitHub Settings > Emails에서 제공하는 비공개 이메일 (username@users.noreply.github.com)
  - "직접 입력" — 본인 이메일 주소를 직접 입력

이메일을 받으면 실행하세요:

```
git config --global user.email "<입력받은 이메일>"
```

## 단계 4: SSH 키 생성

**완료 조건:** `~/.ssh/id_ed25519` 또는 `~/.ssh/id_rsa` 파일이 존재함

SSH 키가 없는 경우, AskUserQuestion으로 패스프레이즈 사용 여부를 물어보세요:

- question: "SSH 키에 패스프레이즈(비밀번호)를 설정하시겠습니까?"
- header: "패스프레이즈"
- options:
  - "설정 안 함 (Recommended)" — 간편하게 사용. 개인 컴퓨터에서 권장
  - "설정함" — 보안이 강화되지만 push/pull 때마다 입력 필요

패스프레이즈 없이 생성하는 경우 (단계 3에서 수집한 이메일 사용):

```bash
ssh-keygen -t ed25519 -C "<이메일>" -f ~/.ssh/id_ed25519 -N ""
```

패스프레이즈를 설정하는 경우:
사용자에게 패스프레이즈를 입력받은 후:

```bash
ssh-keygen -t ed25519 -C "<이메일>" -f ~/.ssh/id_ed25519 -N "<패스프레이즈>"
```

키 생성 후 ssh-agent에 등록하세요:

```bash
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
```

## 단계 5: GitHub SSH 연결

**완료 조건:** `ssh -T git@github.com 2>&1` 출력에 "successfully authenticated"가 포함됨

공개 키를 출력하세요:

```bash
cat ~/.ssh/id_ed25519.pub
```

사용자에게 안내하세요:

```
위의 SSH 공개키를 GitHub에 등록해야 합니다.

1. 아래 링크를 브라우저에서 여세요:
   https://github.com/settings/ssh/new

2. Title: 아무 이름 (예: "My Laptop")
3. Key: 위에 출력된 키 전체를 붙여넣기
4. "Add SSH key" 클릭

등록이 완료되면 알려주세요.
```

사용자가 완료를 알리면 연결을 테스트하세요:

```bash
ssh -T git@github.com 2>&1
```

"successfully authenticated" 메시지가 나오면 성공입니다. 실패하면 등록 과정을 다시 안내하세요.

## 단계 6: 저장소 준비

**완료 조건:** `git rev-parse --git-dir`이 성공 (현재 디렉토리가 Git 저장소)

Git 저장소가 아닌 경우, AskUserQuestion으로 방법을 물어보세요:

- question: "현재 디렉토리는 Git 저장소가 아닙니다. 어떻게 시작하시겠습니까?"
- header: "저장소"
- options:
  - "기존 저장소 clone" — GitHub에 이미 있는 저장소를 가져옴
  - "새 저장소 만들기" — 현재 폴더를 Git 저장소로 초기화

clone을 선택한 경우:
저장소 URL을 물어본 후 실행하세요:

```bash
git clone <URL>
```

새 저장소를 선택한 경우:

```bash
git init
```

## 완료 메시지

모든 단계가 완료되면 설정 요약을 출력하세요:

```
Git 초기 설정이 완료되었습니다.

  이름:    <user.name>
  이메일:  <user.email>
  SSH:     연결됨
  저장소:  <현재 디렉토리>

다음 단계: /git-workflow:workflow 를 실행하면 브랜치 생성부터 PR까지 안내합니다.
```
