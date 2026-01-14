---
layout: default
title: Contributing
parent: Development
nav_order: 4
---

# Contributing

Guide to contributing to PATH DRC EMR.

---

## Overview

PATH DRC EMR welcomes contributions from the community. This guide covers how to contribute effectively.

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- Git installed and configured
- GitHub account with repository access
- Development environment set up (see [Local Development](local-development))
- Familiarity with OpenMRS concepts

### Fork and Clone

```bash
# Fork the repository on GitHub, then clone
git clone https://github.com/YOUR_USERNAME/path-drc-emr.git
cd path-drc-emr

# Add upstream remote
git remote add upstream https://github.com/path-drc/path-drc-emr.git
```

---

## Contribution Workflow

### 1. Create a Branch

```bash
# Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name
```

### Branch Naming

Use descriptive branch names:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feature/` | New functionality | `feature/add-lab-results` |
| `fix/` | Bug fixes | `fix/patient-search-error` |
| `config/` | Configuration changes | `config/update-forms` |
| `docs/` | Documentation updates | `docs/update-readme` |

### 2. Make Changes

- Follow existing code patterns and conventions
- Keep changes focused and minimal
- Test changes locally before committing

### 3. Validate Changes

```bash
# Run configuration validation
mvn -P distro,validator clean verify

# Test Docker build
docker compose build

# Test locally
docker compose up -d
```

### 4. Commit Changes

Write clear commit messages:

```bash
git add .
git commit -m "Add lab results form for HIV program

- Add new form definition in forms/
- Update form mappings in encountertypes/
- Add required concepts to concepts.csv"
```

**Commit Message Guidelines:**

- First line: Brief summary (50 chars max)
- Blank line
- Body: Detailed explanation if needed
- Reference related issues: `Fixes #123`

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## Pull Request Guidelines

### PR Description

Include in your PR description:

- **What**: Brief summary of changes
- **Why**: Motivation for the change
- **How**: Implementation approach
- **Testing**: How you tested the changes

### PR Template

```markdown
## Summary
Brief description of changes.

## Changes
- Change 1
- Change 2

## Testing
- [ ] Ran configuration validation
- [ ] Built Docker images locally
- [ ] Tested in local environment

## Related Issues
Fixes #123
```

### Review Process

1. Automated CI checks run on PR
2. Maintainers review the code
3. Address feedback and update PR
4. PR is merged after approval

---

## Types of Contributions

### Configuration Changes

Most contributions involve configuration updates:

- **Forms**: JSON form definitions in `distro/configuration/forms/`
- **Concepts**: Custom concepts in `distro/configuration/concepts/`
- **Locations**: Location hierarchy in `distro/configuration/locations/`
- **Settings**: Global properties in `distro/configuration/globalproperties/`

### Site-Specific Content

For site-specific contributions:

1. Place files in appropriate `sites/{site}/` directory
2. Follow existing structure
3. Test with site-specific build

See [Adding Sites](../administration/adding-sites) for details.

### Documentation

Documentation contributions are welcome:

- Fix typos and clarify existing docs
- Add missing documentation
- Update outdated information

Documentation lives in the `docs/` directory.

### Bug Reports

When reporting bugs:

1. Check existing issues first
2. Provide clear reproduction steps
3. Include relevant logs
4. Specify environment details

---

## Code Standards

### Configuration Files

**CSV Files:**
- Use consistent column ordering
- Include all required columns
- Use meaningful UUIDs (not sequential)

**JSON Files:**
- Follow existing formatting
- Validate JSON syntax
- Use CIEL concepts when available

**XML Files:**
- Maintain proper indentation
- Include XML declarations
- Validate against schemas

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Concepts | Descriptive English names | `Lab Result - Viral Load` |
| Forms | PascalCase | `VitalsForm.json` |
| Locations | Proper case | `Main Hospital` |
| Files | kebab-case | `patient-registration.csv` |

---

## Testing Your Changes

### Configuration Validation

```bash
# Validate all configuration
mvn -P distro,validator clean verify
```

### Local Testing

```bash
# Build images
docker compose build

# Start environment
docker compose up -d

# Watch logs for errors
docker compose logs -f backend
```

### Manual Testing

After startup:

1. Log in at `http://localhost/openmrs/spa`
2. Verify your changes work as expected
3. Check for console errors
4. Test affected workflows

---

## Continuous Integration

### Automated Checks

Pull requests trigger:

- Maven build validation
- Configuration validation
- Docker image build test

### CI Requirements

PRs must pass:

- All automated checks
- Code review by maintainer

---

## Getting Help

### Resources

- [OpenMRS Wiki](https://wiki.openmrs.org/)
- [OpenMRS Talk](https://talk.openmrs.org/)
- [Initializer Documentation](https://github.com/mekomsolutions/openmrs-module-initializer)

### Questions

For questions about contributing:

1. Check existing documentation
2. Search closed issues and PRs
3. Open a discussion on GitHub

---

## Related

- [Local Development](local-development) - Development setup
- [Building Images](building-images) - Image build process
- [CI/CD](ci-cd) - Automated workflows
