# Safe-Git: Claude Code Plugin for Non-Developers

## Problem

Non-developers who use Claude Code need to collaborate on files via Git/GitHub, but Git is dangerous without guardrails. Real pain points observed from training sessions:

- Empty repos have no `main` branch, causing immediate confusion
- GitHub authentication (`gh auth login`) blocks first-time users
- Git terminology blurs together (commit, push, PR all sound similar)
- Claude Code "does too much automatically" — users don't understand what's happening
- API keys and secrets get accidentally committed
- Force push, wrong branch, and merge conflicts cause data loss

## Solution

A Claude Code plugin (`safe-git`) distributed via the `git-for-everyone` marketplace, containing two skills and a repo-level config file:

| Component | Invocation | Purpose |
|-----------|-----------|---------|
| `safe-git:setup` | `/safe-git:setup` | One-time repo initialization |
| `safe-git:work` | `/safe-git:work` | Daily Git operations via natural language |
| `.git-for-everyone.yml` | (read by skills) | Repo-level config that controls skill behavior |

## Marketplace & Plugin Structure

`git-for-everyone` is a **Claude Code marketplace** repo. `safe-git` is a **plugin** within it.

**Installation by users:**
```bash
# Add the marketplace
/plugin marketplace add wo-o/git-for-everyone

# Install the plugin
/plugin install safe-git@git-for-everyone
```

**Directory structure:**
```
git-for-everyone/                            # Marketplace repo
├── .claude-plugin/
│   └── marketplace.json                     # Marketplace manifest
├── plugins/
│   └── safe-git/                            # Plugin root
│       ├── .claude-plugin/
│       │   └── plugin.json                  # Plugin manifest
│       └── skills/
│           ├── setup/
│           │   └── SKILL.md                 # safe-git:setup
│           └── work/
│               └── SKILL.md                 # safe-git:work
├── docs/
│   └── plans/
└── references/
```

**Marketplace manifest** (`.claude-plugin/marketplace.json`):
```json
{
  "name": "git-for-everyone",
  "owner": {
    "name": "Donghoon Lee"
  },
  "metadata": {
    "description": "Claude Code plugins for non-developers to safely use Git/GitHub"
  },
  "plugins": [
    {
      "name": "safe-git",
      "source": "./plugins/safe-git",
      "description": "Safe Git operations for non-developers with natural language support",
      "version": "0.1.0"
    }
  ]
}
```

**Plugin manifest** (`plugins/safe-git/.claude-plugin/plugin.json`):
```json
{
  "name": "safe-git",
  "version": "0.1.0",
  "description": "Safe Git operations for non-developers with natural language support",
  "author": {
    "name": "Donghoon Lee"
  },
  "repository": "https://github.com/wo-o/git-for-everyone",
  "license": "MIT",
  "keywords": ["git", "github", "non-developers", "safety", "collaboration"]
}
```

## Architecture

```
User -> "/safe-git:work" or natural language ("share", "save")
          |
   Skill reads .git-for-everyone.yml from repo root
          |
   Checks mode (solo / collaborative)
          |
   Maps intent -> Git workflow
          |
   Explains each step + confirms with user
          |
   Executes Git commands
          |
   (gitleaks pre-commit hook runs automatically on commit)
```

## Config File: `.git-for-everyone.yml`

Minimal by design. Everything else uses sensible defaults hardcoded in the skill.

```yaml
project:
  name: "Project Name"

# solo: single user | collaborative: multiple users
mode: collaborative

# collaborative mode settings (ignored when mode: solo)
branching:
  naming: "{user}/{topic}"
  merge_strategy: squash
```

### Hardcoded Defaults (not configurable)

| Setting | Default | Rationale |
|---------|---------|-----------|
| Block force push | Always on | Too dangerous for non-developers |
| Block main branch delete | Always on | Catastrophic if done accidentally |
| Block history rewrite | Always on | rebase/amend confuse non-developers |
| Confirm before push | Always on | Users should see what they're sharing |
| gitleaks pre-commit hook | Always installed | Secrets must never leak |
| Commit message language | Korean | Target audience is Korean-speaking |
| Commit message style | Conventional | Consistency across team |

## Skill 1: `safe-git:setup`

### Triggers
- `/safe-git:setup`
- Natural language: "깃 셋업해줘", "레포 만들어줘", "깃허브 설정해줘"

### Steps

```
1. Environment Check
   |- git installed? -> if not, brew install git
   |- gh CLI installed? -> if not, brew install gh
   |- gitleaks installed? -> if not, brew install gitleaks
   |- gh auth status? -> if not authenticated, guide through gh auth login

2. Repository Setup (user choice)
   |- "Create new repo or clone existing?"
   |- New: gh repo create -> initial commit (README.md) -> push
   |   -> Ensures main branch exists from the start
   |- Existing: gh repo clone -> verify main branch exists

3. Mode Selection (interactive)
   |- "Will you use this repo alone or with others?"
   |   -> solo / collaborative
   |- If collaborative:
   |   |- Branch naming pattern confirmation
   |   |- Merge strategy selection

4. Safety Installation
   |- Generate .git-for-everyone.yml
   |- Check/augment .gitignore (.env, credentials, etc.)
   |- Install pre-commit hook (gitleaks)

5. Verification
   |- Print setup summary
```

### Output Example
```
Setup complete!

Repo: wo-o/my-project (private)
Mode: collaborative
Branch pattern: {user}/{topic}
Security: gitleaks pre-commit hook active

Next: use /safe-git:work to start working!
```

## Skill 2: `safe-git:work`

### Triggers
- `/safe-git:work` (explicit)
- Natural language: "저장해줘", "공유해줘", "받아와", "새 작업 시작", "상태 알려줘", "되돌려줘", "합쳐줘"
- Git terms: "커밋해줘", "푸시해줘", "풀 받아줘", "브랜치 만들어줘", "PR 만들어줘", "머지해줘"

### Natural Language -> Git Mapping

| Natural Language | Solo Mode | Collaborative Mode |
|-----------------|-----------|-------------------|
| "save" / "store" | add + commit | add + commit |
| "share" / "upload" | add + commit + push | add + commit + push + create PR |
| "update" / "get latest" | pull | checkout main + pull |
| "start new work" | (unnecessary) | pull + create branch + checkout |
| "show status" | status summary | status + remote state |
| "undo" / "revert" | revert (with confirmation) | revert (with confirmation) |
| "merge" | (unnecessary) | PR merge |

### Workflow: Save

```
1. git status
2. Explain: "3 files modified: [list]"
3. Suggest commit message in Korean
4. User confirms -> git add [specific files] + git commit
5. (gitleaks pre-commit hook runs)
6. "Saved locally!"
```

### Workflow: Share

```
[Solo]
1. Run Save workflow
2. git push
3. "Uploaded to GitHub!"

[Collaborative]
1. Check current branch
   |- If main: "You're on main. Create a branch first?"
   |- If feature branch: continue
2. Run Save workflow
3. git push
4. "Create a PR?"
   |- Yes: auto-generate title/body -> gh pr create -> show link
   |- No: "Push completed."
```

### Workflow: Start New Work

```
[Collaborative only]
1. Check uncommitted changes -> save first if any
2. git checkout main + git pull
3. "What will you work on?" -> user describes task
4. Suggest branch name based on naming pattern
5. git checkout -b [branch-name]
6. "New workspace ready!"
```

### Workflow: Conflict Resolution

```
1. Detect conflict during pull/merge
2. Explain: who changed what, in plain language
3. Present options: keep mine / keep theirs / combine / ask for help
4. User selects -> resolve -> explain result
```

### Safety Guards (all workflows)

Blocked actions (always, regardless of mode):

| Action | Block Message |
|--------|--------------|
| `git push --force` | "Force push can overwrite teammates' work" |
| `git reset --hard` | "This permanently deletes changes" |
| Delete main branch | "Main branch cannot be deleted" |
| History rewrite (rebase, amend) | "History changes can cause problems" |
| `--no-verify` flag | "Security checks cannot be skipped" |

Additional blocks in collaborative mode:

| Action | Block Message |
|--------|--------------|
| Direct push to main | "Use a branch + PR for safe collaboration" |

### Key Design Principle: Explain Everything

Every Git operation is accompanied by:
- **Before**: What will happen and why
- **During**: What's being done (in plain language)
- **After**: What the result is and what to do next

This addresses the #1 pain point: "Claude does too much, I don't know what's happening."

## Security: gitleaks Integration

- Installed during `safe-git:setup`
- Runs as pre-commit hook on every commit
- If secrets detected:
  1. Commit is blocked
  2. Skill explains which file contains the secret
  3. Suggests how to remove it (e.g., move to .env, add to .gitignore)
- Cannot be bypassed (skill never uses `--no-verify`)

## Scenarios from Real User Feedback

| User Pain Point | How Safe-Git Addresses It |
|----------------|--------------------------|
| "Main branch doesn't exist" (Hong, RJ) | Setup creates initial commit to ensure main exists |
| "GitHub login keeps failing" (Ahn) | Setup verifies gh auth and guides through login |
| "I don't know what's happening" (Lee, Kim) | Every step includes explanation |
| "Need collaboration rules as a skill" (Kim Doa) | .git-for-everyone.yml = collaboration rules |
| "API keys leaked to repo" (Lee) | gitleaks pre-commit hook blocks secrets |
| "Terms all sound the same" (Kim Eunhee) | Natural language mapping, no jargon required |

## Out of Scope

- GitHub branch protection rules (requires paid plan for private repos)
- CI/CD pipeline configuration
- Code review workflows (PR review is optional per design)
- Multi-repo management
- Git LFS for large files
