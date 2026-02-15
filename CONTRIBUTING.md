# Contributing to Coolify ZimaOS Fix

First off, thank you for considering contributing to this project! It's people like you that make this tool better for the entire ZimaOS and Coolify community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Guidelines](#coding-guidelines)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project follows a simple code of conduct:

- **Be respectful** and considerate in your language and actions
- **Be collaborative** and help others when you can
- **Be patient** with maintainers and contributors
- **Accept constructive criticism** gracefully
- **Focus on what's best** for the community

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title** - Descriptive summary of the issue
- **Environment details** - ZimaOS version, Coolify version, hardware
- **Steps to reproduce** - Detailed steps to reproduce the problem
- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Logs** - Relevant logs from `docker logs zimaos-coolify`
- **Screenshots** - If applicable

**Example Bug Report:**
```markdown
### Bug: Fix script fails with database password error

**Environment:**
- ZimaOS version: 1.2.3
- Coolify version: 4.0.0-beta.379
- Hardware: Raspberry Pi 4

**Steps to reproduce:**
1. Run `sudo bash fix-coolify.sh`
2. Script reaches "Extracting environment variables" step
3. Fails with "Could not extract DB_PASSWORD"

**Expected:** Script should extract password from container
**Actual:** Script exits with error code 1

**Logs:**
```
Error: Could not extract necessary credentials
```

**Additional context:**
Container was manually created, not via App Store
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:

- **Use a clear title** describing the enhancement
- **Provide detailed description** of the suggested change
- **Explain why** this enhancement would be useful
- **List alternatives** you've considered

**Example Enhancement:**
```markdown
### Enhancement: Add support for Coolify 5.x

**Description:**
Add compatibility checks and support for Coolify 5.x when it's released.

**Why:**
Users will want to upgrade to Coolify 5.x when available.

**Implementation ideas:**
- Add version detection
- Support both 4.x and 5.x environment variables
- Provide migration path

**Alternatives:**
- Create separate branch for 5.x support
- Wait until 5.x is stable
```

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Test thoroughly**
5. **Commit with clear messages**
6. **Push to your fork**
7. **Open a Pull Request**

## Getting Started

### Prerequisites

- ZimaOS test environment (VM or physical device)
- Coolify installed
- Basic knowledge of:
  - Bash scripting
  - Docker
  - Linux system administration
  - Git

### Setting Up Development Environment

1. **Fork and clone:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/coolify-zimaos-fix.git
   cd coolify-zimaos-fix
   ```

2. **Create a test branch:**
   ```bash
   git checkout -b test/my-changes
   ```

3. **Set up test environment:**
   ```bash
   # On your ZimaOS test system
   mkdir -p /DATA/coolify-fix-dev
   # Copy your modified scripts here for testing
   ```

## Development Workflow

### Making Changes

1. **Start with an issue** - Create or claim an issue first
2. **Create a branch** - Use descriptive branch names:
   - `feature/add-version-check`
   - `fix/database-password-extraction`
   - `docs/improve-troubleshooting`
   - `test/add-integration-tests`

3. **Make small, focused commits** - One logical change per commit

4. **Test your changes** - Run the test script and manual tests

5. **Update documentation** - Update README, INSTALLATION, etc.

### Branch Naming Convention

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `test/` - Test additions/changes
- `refactor/` - Code refactoring
- `chore/` - Maintenance tasks

## Coding Guidelines

### Bash Script Standards

```bash
#!/bin/bash
#
# Brief description of what this script does
#

set -e  # Exit on error (unless error handling is needed)

# Use meaningful variable names
CONTAINER_NAME="zimaos-coolify"
DATABASE_NAME="coolify"

# Add comments for complex logic
# This extracts the password from the container environment
DB_PASSWORD=$(docker inspect "$CONTAINER_NAME" | grep -oP 'DB_PASSWORD=\K[^"]+')

# Use functions for reusable code
check_container_running() {
    if ! docker ps | grep -q "$1"; then
        echo "Error: Container $1 is not running"
        return 1
    fi
}

# Use color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Success!${NC}"

# Handle errors gracefully
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi
```

### Code Style

- **Indentation**: 4 spaces (not tabs)
- **Line length**: Max 100 characters
- **Comments**: Explain why, not what
- **Error handling**: Always handle potential errors
- **Variables**: Use uppercase for constants, lowercase for local variables
- **Quoting**: Always quote variables: `"$VARIABLE"`

### Script Structure

```bash
#!/bin/bash
#
# Script description
#

# 1. Shebang and description
# 2. Safety settings
set -e

# 3. Constants
readonly CONTAINER_NAME="zimaos-coolify"

# 4. Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 5. Functions
function cleanup() {
    # Cleanup code
}

function main() {
    # Main logic
}

# 6. Trap for cleanup
trap cleanup EXIT

# 7. Main execution
main "$@"
```

## Commit Guidelines

### Commit Message Format

```
type(scope): short description

Longer description if needed. Explain what and why, not how.

Fixes #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions/changes
- `refactor`: Code refactoring
- `style`: Code style changes (formatting)
- `chore`: Maintenance tasks

**Examples:**

```
feat(script): add Coolify version detection

Add automatic detection of Coolify version to ensure
compatibility before running the fix.

Fixes #45
```

```
fix(database): handle missing password gracefully

The script now provides a helpful error message when
the database password cannot be extracted, instead of
failing silently.

Fixes #67
```

```
docs(readme): improve troubleshooting section

Add more common error scenarios and their solutions
based on user feedback.
```

## Pull Request Process

### Before Submitting

1. ✅ Update documentation if needed
2. ✅ Add/update tests
3. ✅ Test on actual ZimaOS system
4. ✅ Update CHANGELOG.md
5. ✅ Ensure all commits follow guidelines
6. ✅ Rebase on latest main branch

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Tested on ZimaOS
- [ ] Test script passes
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] CHANGELOG.md updated

## Related Issues
Fixes #123

## Screenshots (if applicable)
```

### Review Process

1. A maintainer will review your PR within 1 week
2. Address any requested changes
3. Once approved, a maintainer will merge it
4. Your contribution will be credited in the next release!

## Testing

### Running Tests

```bash
# Run the test script
/DATA/coolify-fix/test-fix.sh

# Manual tests
docker ps | grep coolify
docker exec zimaos-coolify env | grep BASE_CONFIG_PATH
curl http://localhost:8000
```

### Test Checklist

- [ ] Fresh Coolify installation
- [ ] After ZimaOS update
- [ ] With existing deployments
- [ ] Container recreation
- [ ] Different Coolify versions (if applicable)
- [ ] Error conditions (missing passwords, etc.)

### Writing Tests

When adding new functionality, add tests to `test-fix.sh`:

```bash
# Test N: Check new feature
echo "N. Checking new feature..."
if [[ condition ]]; then
    echo "   ✅ PASS: Feature works"
else
    echo "   ❌ FAIL: Feature doesn't work"
fi
```

## Documentation

### What to Document

- **New features** - How to use them
- **Bug fixes** - What was fixed and how
- **Configuration changes** - What changed and why
- **Breaking changes** - Migration guide

### Documentation Style

- **Be clear and concise**
- **Use examples**
- **Include screenshots** when helpful
- **Keep it updated**
- **Test your instructions**

### Files to Update

When making changes, update relevant files:

- `README.md` - Main documentation
- `INSTALLATION.md` - Installation steps
- `QUICK-START.md` - Quick reference
- Code comments - Inline documentation

## Recognition

Contributors will be recognized in:

- README.md Contributors section
- Release notes
- Commit history

## Questions?

- 💬 Open a [Discussion](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/discussions)
- 🐛 Create an [Issue](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/issues)
- 📧 Contact maintainers (see README.md)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

**Thank you for contributing!** 🎉

Every contribution, no matter how small, helps improve this tool for everyone.
