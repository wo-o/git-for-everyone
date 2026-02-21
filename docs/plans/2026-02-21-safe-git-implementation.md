# Safe-Git Plugin Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a Claude Code marketplace (`git-for-everyone`) containing the `safe-git` plugin with two skills: `setup` and `work`.

**Architecture:** The `git-for-everyone` repo is a Claude Code marketplace with `.claude-plugin/marketplace.json`. Inside `plugins/safe-git/`, the plugin has its own `.claude-plugin/plugin.json` and two skills under `skills/`. Users add the marketplace, install the plugin, then invoke `safe-git:setup` for initial configuration and `safe-git:work` for daily Git operations.

**Tech Stack:** Claude Code plugin (SKILL.md format), Git, GitHub CLI (`gh`), gitleaks

---

### Task 1: Create marketplace and plugin scaffold

**Files:**
- Create: `.claude-plugin/marketplace.json`
- Create: `plugins/safe-git/.claude-plugin/plugin.json`

**Step 1: Create marketplace manifest**

Create `.claude-plugin/marketplace.json`:

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

**Step 2: Create plugin manifest**

Create `plugins/safe-git/.claude-plugin/plugin.json`:

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

**Step 3: Create skill directories**

```bash
mkdir -p plugins/safe-git/skills/setup
mkdir -p plugins/safe-git/skills/work
```

**Step 4: Commit**

```bash
git add .claude-plugin/ plugins/safe-git/.claude-plugin/
git commit -m "chore: scaffold marketplace and safe-git plugin"
```

---

### Task 2: Write `setup` skill (safe-git:setup)

**Files:**
- Create: `plugins/safe-git/skills/setup/SKILL.md`

**Step 1: Write SKILL.md**

Write the full content of `plugins/safe-git/skills/setup/SKILL.md`. The skill handles:

1. Environment check (git, gh, gitleaks installation via brew)
2. GitHub authentication (gh auth login)
3. Repository setup (create new or clone existing, ensure main branch exists)
4. Mode selection (solo vs collaborative, branch naming, merge strategy)
5. Safety installation (.git-for-everyone.yml, .gitignore, gitleaks pre-commit hook)
6. Setup summary output

Key details:
- Frontmatter: `name: setup`, description with Korean triggers
- Every step explains what's happening to the user
- Main branch guaranteed via initial commit on empty repos
- gitleaks pre-commit hook script installed at `.git/hooks/pre-commit`
- .gitignore augmented with .env, *.pem, *.key, credentials.json, secrets.yml

See design doc Section "Skill 1: safe-git:setup" for full specification.

**Step 2: Commit**

```bash
git add plugins/safe-git/skills/setup/SKILL.md
git commit -m "feat: add setup skill for repo initialization"
```

---

### Task 3: Write `work` skill (safe-git:work)

**Files:**
- Create: `plugins/safe-git/skills/work/SKILL.md`

**Step 1: Write SKILL.md**

Write the full content of `plugins/safe-git/skills/work/SKILL.md`. The skill handles:

1. Entry checks (git repo?, config file exists?, current state)
2. Natural language -> workflow mapping (SAVE, SHARE, UPDATE, START, STATUS, UNDO, MERGE)
3. Each workflow with step-by-step explanations
4. Safety guards (HARD-GATE blocking dangerous commands)
5. Conflict resolution with plain-language explanation
6. Learning mode (Git term explanations with everyday analogies)

Key details:
- Frontmatter: `name: work`, description with Korean triggers + git terms
- HARD-GATE: never execute force push, hard reset, main delete, rebase, amend, --no-verify
- Always use `git add [specific files]` instead of `git add .`
- Always use `git revert` instead of `git reset --hard`
- Collaborative mode: block direct push to main, suggest branch + PR
- Every operation has Before/During/After explanations

See design doc Section "Skill 2: safe-git:work" for full specification.

**Step 2: Commit**

```bash
git add plugins/safe-git/skills/work/SKILL.md
git commit -m "feat: add work skill for daily git operations"
```

---

### Task 4: Validate and push

**Step 1: Verify structure**

```bash
# Expected:
# .claude-plugin/marketplace.json
# plugins/safe-git/.claude-plugin/plugin.json
# plugins/safe-git/skills/setup/SKILL.md
# plugins/safe-git/skills/work/SKILL.md
```

**Step 2: Validate plugin**

```bash
cd plugins/safe-git && claude plugin validate .
```

**Step 3: Push to remote**

```bash
git push origin main
```

**Step 4: Test installation**

```bash
# Add marketplace
/plugin marketplace add wo-o/git-for-everyone

# Install plugin
/plugin install safe-git@git-for-everyone
```

**Step 5: Manual smoke test**

1. `/safe-git:setup` — should start environment check
2. `/safe-git:work` — should read .git-for-everyone.yml
3. "저장해줘" — should trigger SAVE workflow
4. "force push 해줘" — should be blocked
