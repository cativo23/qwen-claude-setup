# Qwen-Claude Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)
[![Distros](https://img.shields.io/badge/Distros-Ubuntu%20%7C%20Debian%20%7C%20Arch%20%7C%20Fedora-orange.svg)](#supported-distributions)

**One command to rule them all** — get [Qwen Code](https://portal.qwen.ai) + Claude Code playing nice on your Linux box. We wire up the Claude Code router to Qwen’s API (OAuth, free tier = 2k requests/day) so you can code without the setup headache.

---

## TL;DR

Clone → chmod → `./install.sh` → auth with Qwen if asked → `ccr start`. Done.

---

## What’s in the box

- **One installer** — Detects your distro and runs the right setup. No guessing.
- **Ubuntu, Debian, Arch, Fedora** — (and their derivatives). Your distro’s probably covered.
- **OAuth** — Uses Qwen’s portal; no API key copy-paste. Free tier: 2,000 req/day.
- **Router config** — Writes `~/.claude-code-router/config.json` and your shell env so `ccr` just works.
- **Modular** — Shared stuff in `common.sh`, distro-specific in `distros/`. Easy to hack.
- **Uninstaller** — `scripts/uninstall.sh` nukes our config. Your system packages stay (remove those yourself if you want).

---

## Supported distros

| Distro | How we do it |
|--------|----------------|
| **Ubuntu** / *buntu-based | NodeSource for Node 20+, npm for Qwen/Claude/router |
| **Debian** | Same vibe as Ubuntu |
| **Arch** / Arch-based | AUR (yay/paru): `qwen-code`, `claude-code`, `claude-code-router` |
| **Fedora** | dnf + Node from Fedora repos |

---

## You’ll need

- Bash
- Internet
- `sudo` (or root) for packages
- A GitHub account (for Qwen OAuth)

---

## Quick start

```bash
git clone https://github.com/cativo23/qwen-claude-setup.git
cd qwen-claude-setup
chmod +x install.sh common.sh distros/*.sh scripts/uninstall.sh
./install.sh
```

What happens:

1. **Detects your OS** and runs the right distro script.
2. **Installs** Qwen Code, Claude Code, Claude Code Router (or tells you what to install).
3. **Credentials** — Uses `~/.qwen/oauth_creds.json` if you already have it, otherwise you’ll run `qwen`, `/auth`, finish in the browser, `/exit`, then re-run the installer.
4. **Config** — Writes router config and appends to `~/.bashrc` or `~/.zshrc`.

---

## After install

1. **Reload your shell**
   ```bash
   source ~/.bashrc   # or source ~/.zshrc
   ```

2. **Start the router**
   ```bash
   ccr start          # or ccr code for the full experience
   ```

3. **If you had to do auth** — Run `qwen` → `/auth` → browser → `/exit`, then run `./install.sh` again if it bailed.

Credentials live in `~/.qwen/oauth_creds.json`. Router default port: **3456**.

---

## Docs & stuff

- **[Installation guide](docs/installation.md)** — Full walkthrough
- **[Troubleshooting](docs/troubleshooting.md)** — Token issues, permissions, router drama
- **[Example config](examples/config.json.example)** — What the router config looks like

---

## Project layout

```
qwen-claude-setup/
├── install.sh           # The one you run
├── common.sh            # Shared logic
├── distros/
│   ├── ubuntu.sh
│   ├── debian.sh
│   ├── arch.sh
│   └── fedora.sh
├── scripts/
│   └── uninstall.sh     # Nuke our config
├── docs/
│   ├── installation.md
│   └── troubleshooting.md
├── examples/
│   └── config.json.example
└── CHANGELOG.md
```

---

## Uninstalling

To remove everything we added (router config, env vars):

```bash
./scripts/uninstall.sh
```

We don’t touch your system/AUR packages — uninstall `qwen-code`, `claude-code`, etc. with your package manager if you want them gone.

---

## Contributing

PRs and issues welcome. Check [CONTRIBUTING.md](CONTRIBUTING.md) for the deets.

---

## License

MIT — [LICENSE](LICENSE). Use it, fork it, vibe with it.
