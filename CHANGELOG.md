# Changelog

All notable changes to this project will be documented in this file.

## [1.0.5] - 2026-02-02

### Changed
- Unified Debian and Ubuntu setup process to simplify maintenance
- Updated install.sh to map both Ubuntu and Debian to the same script
- Removed redundant ubuntu.sh script

## [1.0.4] - 2026-02-02

### Added
- Test script to verify GitHub Action release workflow functionality
- Automated release workflow that extracts version from CHANGELOG.md

## [1.0.3] - 2026-02-02

### Added
- Custom Qwen transformer to support Web Search in `claude` CLI.
- Automatic deployment of the Qwen transformer plugin during installation.
- Injected system prompt reminder to improve Qwen's tool usage efficiency.

### Changed
- Refactored `common.sh` to handle transformer plugin copying and configuration.
- Unified transformer registration in `config.json`.

## [1.0.2] - 2026-02-02

### Fixed
- Corrected `ANTHROPIC_BASE_URL` by removing the redundant `/v1` suffix, resolving 404 errors.

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