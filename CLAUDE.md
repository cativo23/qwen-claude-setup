# CLAUDE.md

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

Routes Claude Code through Qwen's API on Linux using OAuth authentication. The transformer plugin (`plugins/qwen-transformer.js`) handles API compatibility (e.g., `WebSearch` ↔ `web_search`).

### Key Files

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