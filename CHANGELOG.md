# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1] - 2026-02-02

### Removed
- Redundant standalone scripts `scripts/setup-qwen-claude-ubuntu.sh` and `scripts/setup-qwen-claude-arch.sh` (logic is in `install.sh` + `distros/` modules).

### Fixed
- README and docs no longer reference removed scripts or non-existent `scripts/setup-qwen-claude-fedora.sh` / `scripts/setup-qwen-claude-debian.sh`.
- Tests no longer expect `docs/configuration.md` or the removed setup scripts; permission and syntax checks updated for current script set.

### Changed
- Documentation: installation is via `./install.sh` only; `scripts/` now only contains `uninstall.sh`.

## [1.0.0] - 2026-02-02

### Added
- Initial release of Qwen-Claude setup scripts
- Support for Ubuntu and Ubuntu-based distributions
- Support for Arch Linux and Arch-based distributions
- Support for Fedora
- Support for Debian
- Unified installer with automatic OS detection
- Modular architecture with shared functions
- Comprehensive documentation
- Contribution guidelines

### Features
- Automatic dependency installation based on distribution
- OAuth token management for Qwen integration
- Claude Code Router configuration
- Environment variable setup
- Onboarding bypass for Claude

### Scripts
- `install.sh` - Unified installer
- `common.sh` - Shared functions
- Distribution-specific modules in `distros/` directory
- `scripts/uninstall.sh` - Cleanup script