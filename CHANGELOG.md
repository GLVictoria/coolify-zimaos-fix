# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Automatic update checker
- Support for Coolify 5.x (when released)
- Web-based configuration tool
- Docker Compose alternative installation method

## [1.0.0] - 2026-02-15

### Added
- Initial release of Coolify ZimaOS fix
- Automated fix script (`fix-coolify.sh`)
- Test verification script (`test-fix.sh`)
- Comprehensive README documentation
- Installation guide (INSTALLATION.md)
- Quick start guide (QUICK-START.md)
- Contributing guidelines (CONTRIBUTING.md)
- MIT License
- GitHub issue templates
- Pull request template

### Fixed
- Read-only filesystem error when running Coolify on ZimaOS
- Database server SSH private key configuration (ID 0 → ID 4)
- BASE_CONFIG_PATH now correctly set to `/DATA/coolify`

### Features
- Automatic backup of existing configuration
- Password extraction from existing container
- Container recreation with correct environment variables
- Six-point verification test suite
- Colored terminal output for better UX
- Detailed error messages and troubleshooting

### Documentation
- Complete technical explanation of the issue
- Manual fix instructions as alternative
- Troubleshooting guide with common scenarios
- Persistence notes and update instructions
- Contributing guidelines for developers

## [0.1.0] - 2026-02-14

### Added
- Initial development version
- Basic fix script prototype
- Manual fix documentation

---

## Legend

- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security improvements

## Links

- [Latest Release](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/releases/latest)
- [All Releases](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/releases)
- [Compare Versions](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/compare)
