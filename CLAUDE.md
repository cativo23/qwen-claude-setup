# CLAUDE.md

> ⚠️ **This project is archived.** This documentation is kept for reference purposes only.

> Quick reference for Claude Code working with qwen-claude-setup

## Quick Reference

| Action | Command |
|--------|---------|
| Install | `./install.sh` |
| Uninstall | `./scripts/uninstall.sh` |
| Start router | `ccr start` |
| Full experience | `ccr code` |
| Restart router | `ccr restart` |
| Check usage | `./scripts/check_qwen_usage.sh` |
| Re-authenticate | `qwen` → `/auth` → browser → `/exit` |

**Router port**: `3456` • **Free tier**: 2,000 requests/day

---

## Project Overview

This is a Linux shell script-based project that integrates Qwen AI's free-tier API with Claude Code. It routes Claude Code through Qwen's API on Linux using OAuth authentication. The transformer plugin (`plugins/qwen-transformer.js`) handles API compatibility (e.g., `WebSearch` ↔ `web_search`).

### Key Components

| File | Purpose |
|------|---------|
| `install.sh` | Unified installer, detects distro |
| `common.sh` | Shared functions (OAuth, config, utils) |
| `distros/` | Distribution-specific scripts |
| `plugins/qwen-transformer.js` | API compatibility transformer |
| `.claude-code-router/config.json` | Router configuration (generated) |
| `~/.qwen/oauth_creds.json` | OAuth credentials |

### Supported Distros

Ubuntu, Debian, Arch Linux, Fedora (and their derivatives)

---

## Technical Solutions

### Special Feature: Transformer Plugin
The project includes a sophisticated JavaScript transformer (`plugins/qwen-transformer.js`) that solves a critical compatibility issue:
- **Problem**: Claude CLI sends tools in PascalCase (`WebSearch`) but Qwen expects snake_case (`web_search`)
- **Solution**: The transformer acts as middleware to convert between formats in both directions
- **Additional Feature**: Adds system prompt reminders to help Qwen use its tools effectively

### OAuth Token Management
- Extracts tokens from `~/.qwen/oauth_creds.json`
- Handles systems with or without `jq` for JSON parsing
- Implements proper JSON escaping for security

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Token expired | Run `qwen` → `/auth`, then `./install.sh` |
| Web search not working | Ensure `plugins/qwen-transformer.js` is loaded |
| Router not starting | Check port 3456 availability |
| Missing credentials | Run `./install.sh` (triggers auth if needed) |

---

## Commits & Workflow

### Commit Format

```
<gitmoji> <type>(scope): <description>
```

**Gitmoji**: `🐛` fix • `✨` feat • `📝` docs • `🔥` remove • `🔧` config • `🚀` deploy • `⚡` perf

**Types**: `feat` • `fix` • `docs` • `style` • `refactor` • `test` • `chore`

**Breaking changes**: Use `feat!:` or `fix!:`

### GitFlow (Condensed)

1. **Feature**: `develop` → `feature/name` → PR → `develop`
2. **Release**: `develop` → `release/vX.Y.Z` → update CHANGELOG → PR → `main`
3. **Post-release**: PR `main` → `develop` to sync

```bash
# Feature
git checkout -b feature/name develop
# ... work ...
gh pr create --base develop

# Release
git checkout -b release/vX.Y.Z develop
# Update CHANGELOG.md
gh pr create --base main --title "Release vX.Y.Z"
gh pr merge <pr-number> --admin --merge

# Post-release sync
gh pr create --base develop --head main --title "Sync main to develop"
```

---

## Versioning

**SemVer**: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward-compatible)
- **PATCH**: Bug fixes, docs

### CHANGELOG.md Format

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature

### Fixed
- Bug fix
```

Categories: `Added` • `Changed` • `Deprecated` • `Removed` • `Fixed` • `Security`

---

## Automated Releases

GitHub Actions (`.github/workflows/release.yml`) automatically:
1. Extracts version from `CHANGELOG.md`
2. Creates git tag `vX.Y.Z`
3. Generates GitHub release

**Note**: Triggered on push to `main`/`master`

---

## Token Efficiency & Performance

To save tokens and optimize performance, follow these rules:

1. **Be Concise**: Provide brief explanations. Avoid repeating instructions.
2. **Limit Git Logs**: When checking history, always use `git log -n 5` or `git log -n 10`. Never read the full history.
3. **Selective Reading**: Only read the files strictly necessary for the current task.
4. **Context Management**: If a conversation becomes too long, suggest starting a new one with `claude --new`.
5. **Batch Edits**: When possible, use `multi_replace_file_content` to make multiple changes in a single tool call.
6. **Avoid Redundancy**: Do not re-read files you have already seen in the current session unless they have changed.
7. **Search Smart**: Use `grep_search` or `find_by_name` to locate specific code instead of exploring the directory tree.
