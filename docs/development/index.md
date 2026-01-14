---
layout: default
title: Development
nav_order: 7
has_children: true
permalink: /development
---

# Development

This section covers development workflows, building images locally, and contributing to PATH DRC EMR.

## Overview

PATH DRC EMR is an open-source project built on OpenMRS. This guide will help you set up a development environment and contribute effectively.

## What's in This Section

### [Local Development](local-development)
Set up your development environment, configure Maven, run locally.

### [Building Images](building-images)
Build Docker images locally for base or site-specific distributions.

### [CI/CD](ci-cd)
GitHub Actions workflows, automated builds, release process.

### [Contributing](contributing)
Code style guidelines, pull request process, documentation requirements.

### [Testing](testing)
Test locally, validate metadata changes, test Docker builds.

---

## Quick Start for Developers

### Prerequisites

- Git, Docker 20.10+, Docker Compose 2.0+
- Maven 3.6+ (for local builds)
- Java JDK 8 (for backend development)
- GitHub Personal Access Token

### Clone and Build

```bash
git clone https://github.com/path-drc/path-drc-emr.git
cd path-drc-emr

# Build base distribution
docker compose build

# Or build site-specific
TAG=latest-libikisi docker compose build \
  --build-arg BUILD_TYPE=site \
  --build-arg MVN_PROJECT=libikisi
```

### Run Locally

```bash
docker compose up -d

# View logs
docker compose logs -f backend
```

### Access the Application

- **OpenMRS 3.0**: http://localhost/openmrs/spa
- **Legacy UI**: http://localhost/openmrs
- **Credentials**: `admin` / `Admin123`

---

## Repository Structure

```
path-drc-emr/
├── .github/workflows/     # CI/CD
├── distro/               # Base distribution config
├── sites/                # Site-specific configs
├── frontend/             # Frontend configuration
├── gateway/              # Gateway nginx config
├── Dockerfile            # Main Dockerfile
├── docker-compose.yml    # Service orchestration
└── pom.xml              # Root Maven POM
```
