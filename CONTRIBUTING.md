# Contributing to Coolify ZimaOS Fix

First off, thank you for considering contributing to this project! It's people like you that make this tool better for the entire ZimaOS and Coolify community.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed**
- **Explain which behavior you expected to see instead**
- **Include logs and error messages**

**Bug Report Template:**

```markdown
**Environment:**
- ZimaOS Version:
- Coolify Version:
- Docker Version:

**Steps to Reproduce:**
1.
2.
3.

**Expected Behavior:**


**Actual Behavior:**


**Logs:**
```
docker logs zimaos-coolify --tail 50
```


**Additional Context:**

```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List any alternative solutions you've considered**

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Make your changes**
4. **Test thoroughly** on ZimaOS
5. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
6. **Push to the branch** (`git push origin feature/AmazingFeature`)
7. **Open a Pull Request**

#### Pull Request Guidelines

- Follow the existing code style
- Add comments to complex logic
- Update documentation as needed
- Test your changes thoroughly
- Keep commits focused and atomic
- Write clear commit messages

**Commit Message Format:**

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Example:**
```
feat: add backup verification step to fix-coolify.sh

- Verify backup file was created successfully
- Add rollback option if user wants to restore
- Display backup location to user

Closes #123
```

## Development Setup

### Prerequisites

- ZimaOS installed
- Coolify installed (even if broken)
- Docker and docker-compose
- SSH access to your ZimaOS system
- Basic knowledge of Bash scripting

### Testing Your Changes

1. **Test on a clean Coolify installation**
   ```bash
   # Your test commands here
   ```

2. **Test the fix scripts**
   ```bash
   bash scripts/fix-coolify.sh
   bash scripts/fix-ssh-key.sh
   bash scripts/test-fix.sh
   ```

3. **Verify all use cases**
   - Fresh installation
   - After ZimaOS update
   - After Coolify update
   - With existing deployments

### Code Style Guidelines

**Bash Scripts:**
- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Add comments for complex logic
- Use meaningful variable names
- Quote variables: `"$VAR"` not `$VAR`
- Use functions for reusable code
- Add colored output for user feedback

**Example:**
```bash
#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function to display success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Main logic
main() {
    local config_path="/DATA/coolify"

    if [ -d "$config_path" ]; then
        success "Directory exists"
    else
        echo -e "${RED}Error: Directory not found${NC}"
        exit 1
    fi
}

main "$@"
```

**Documentation:**
- Use Markdown format
- Include code examples
- Add table of contents for long docs
- Use clear, concise language
- Include screenshots if helpful

## Project Structure

```
coolify-zimaos-fix/
├── README.md              # Main documentation
├── INDEX.md               # Quick reference
├── LICENSE                # MIT License
├── CONTRIBUTING.md        # This file
├── .gitignore            # Git ignore rules
├── scripts/              # Executable scripts
│   ├── fix-coolify.sh    # Filesystem fix
│   ├── fix-ssh-key.sh    # SSH key fix
│   └── test-fix.sh       # Verification tests
├── docs/                 # Detailed documentation
│   ├── SSH-KEY-FIX.md    # SSH troubleshooting
│   └── FIXES-APPLIED.md  # Fix history
└── .github/              # GitHub configuration
    └── workflows/        # CI/CD workflows
```

## Areas Needing Help

### High Priority
- [ ] GitHub Actions for automated testing
- [ ] Support for different Coolify versions
- [ ] ZimaOS version compatibility matrix
- [ ] Backup and restore functionality
- [ ] Logging improvements

### Medium Priority
- [ ] Web interface for running fixes
- [ ] Automated fix detection
- [ ] Docker Compose validation
- [ ] Configuration migration tool
- [ ] Performance optimizations

### Low Priority
- [ ] Internationalization (i18n)
- [ ] Custom notification hooks
- [ ] Statistics and analytics
- [ ] Plugin system for custom fixes

## Testing

### Manual Testing Checklist

- [ ] Fresh Coolify installation
- [ ] Read-only filesystem fix works
- [ ] SSH key fix works
- [ ] Verification tests pass
- [ ] Docker containers all healthy
- [ ] Web interface accessible
- [ ] Deployments work correctly
- [ ] After system reboot
- [ ] After Coolify restart

### Automated Testing

Coming soon: GitHub Actions for automated testing.

## Documentation

When updating documentation:

1. **Keep it up to date** - Update docs when changing code
2. **Be clear and concise** - Avoid jargon when possible
3. **Include examples** - Show don't just tell
4. **Test your examples** - Make sure code samples work
5. **Update the changelog** - Track all changes

## Questions?

Feel free to:
- Open an issue for discussion
- Start a GitHub Discussion
- Join the ZimaOS community forum

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing! 🎉
