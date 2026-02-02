# Qwen-Claude Setup

**One-command setup for Qwen Code + Claude Code** on Linux. Configures the Claude Code router to use [Qwen](https://portal.qwen.ai) (OAuth) so you can use Claude Code with Qwen’s API tier.

---

## Table of contents

- [Features](#features)
- [Supported distributions](#supported-distributions)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Documentation](#documentation)
- [Project structure](#project-structure)
- [Uninstalling](#uninstalling)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Unified installer** — Single entry point; auto-detects your distribution and runs the right setup
- **Multi-distro** — Ubuntu, Debian, Arch, Fedora (and derivatives)
- **OAuth integration** — Uses Qwen portal OAuth; free tier: 2,000 requests/day
- **Router configuration** — Generates Claude Code Router config and env vars
- **Modular scripts** — Shared logic in `common.sh`, distro-specific steps in `distros/`
- **Uninstaller** — Clean removal of config and environment changes

---

## Supported distributions

| Distribution | Notes |
|-------------|--------|
| **Ubuntu** / Ubuntu-based | Uses NodeSource for Node.js 20+; installs npm packages |
| **Debian** | Same approach as Ubuntu |
| **Arch Linux** / Arch-based | Uses AUR (yay/paru); `qwen-code`, `claude-code`, `claude-code-router` |
| **Fedora** | Uses dnf and Node.js from Fedora repos |

---

## Requirements

- Bash
- Internet access
- Sudo (or root) for installing packages
- A GitHub account (for Qwen OAuth)

---

## Quick start

```bash
git clone https://github.com/cativo23/qwen-claude-setup.git
cd qwen-claude-setup
chmod +x install.sh common.sh distros/*.sh scripts/uninstall.sh
./install.sh
```

The installer will:

1. Detect your OS and run the matching distro script  
2. Install Qwen Code, Claude Code, and Claude Code Router (or prompt you to install dependencies)  
3. Use existing Qwen credentials from `~/.qwen/oauth_creds.json`, or prompt you to run `qwen` and complete `/auth`  
4. Write `~/.claude-code-router/config.json` and add the needed variables to your shell RC (`~/.bashrc` or `~/.zshrc`)

---

## Configuration

After installation:

1. **Reload your shell**
   ```bash
   source ~/.bashrc   # or source ~/.zshrc
   ```

2. **Start the router**
   ```bash
   ccr start          # or ccr code for all-in-one
   ```

3. **If you had to authenticate:** run `qwen`, then `/auth`, complete the browser flow, then `/exit`. Re-run `./install.sh` if the script had stopped for auth.

Credentials are stored in `~/.qwen/oauth_creds.json`. The router listens on port **3456** by default.

---

## Documentation

- **[Installation guide](docs/installation.md)** — Step-by-step install and verification  
- **[Troubleshooting](docs/troubleshooting.md)** — Token issues, permissions, router problems  
- **[Example config](examples/config.json.example)** — Sample Claude Code Router config  

---

## Project structure

```
qwen-claude-setup/
├── install.sh           # Unified installer (run this)
├── common.sh            # Shared functions and constants
├── distros/
│   ├── ubuntu.sh
│   ├── debian.sh
│   ├── arch.sh
│   └── fedora.sh
├── scripts/
│   └── uninstall.sh     # Remove config and env changes
├── docs/
│   ├── installation.md
│   └── troubleshooting.md
├── examples/
│   └── config.json.example
└── CHANGELOG.md
```

---

## Uninstalling

To remove router config, env vars, and related setup:

```bash
./scripts/uninstall.sh
```

This does **not** uninstall system/AUR packages (e.g. `qwen-code`, `claude-code`); remove those with your package manager if desired.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines and code style.

---

## License

MIT — see [LICENSE](LICENSE) for details.
