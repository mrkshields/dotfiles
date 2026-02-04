# dotfiles

My cross-functional config of tmux, vim, fish, and more,
for work and home, Mac OSX, Debian.

## Debian/Ubuntu

Run `./setup-debian`

## MacOS

Run `./setup-macos`

## Development

This repository uses [pre-commit](https://pre-commit.com/) to validate changes.

### Setup
```bash
pip install pre-commit
pre-commit install
```

### Usage
```bash
# Run all hooks on all files
pre-commit run --all-files

# Run on staged files only
pre-commit run
```

### Configured Hooks
- Shell script validation (shellcheck)
- Fish syntax checking
- Python linting (flake8)
- YAML linting (yamllint)
- Markdown linting
- Vim script linting
- Trailing whitespace/EOF fixes
- Secret detection (gitleaks)
- Conventional commit messages
