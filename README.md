# git-for-everyone

Git safety plugins for Claude Code.

## Plugins

### git-guardrail

PreToolUse hook that blocks dangerous remote Git operations while leaving local commands unrestricted.

**Blocked operations:**

| Operation | Example | Suggestion |
|---|---|---|
| Force push | `git push --force` | Use `--force-with-lease` |
| Push to protected branch | `git push origin main` | Create a feature branch and open a PR |
| Push via refspec | `git push origin HEAD:main` | Create a feature branch and open a PR |
| Admin merge | `gh pr merge --admin` | Remove `--admin` flag |
| Repo deletion | `gh repo delete` | Run manually outside Claude |

**Allowed operations:**

All local git commands — `reset --hard`, `clean -f`, `checkout .`, `branch -D`, etc.

## Install

```
/plugin marketplace add https://github.com/wo-o/git-for-everyone.git
/plugin install git-guardrail
```

## License

MIT
