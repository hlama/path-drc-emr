---
layout: default
title: Local Development
parent: Development
nav_order: 1
---

# Local Development

Guide to setting up a local development environment for PATH DRC EMR.

---

## Overview

This guide covers setting up a development environment for:
- Testing configuration changes
- Developing custom modules
- Contributing to the distribution

---

## Prerequisites

### Required Software

- **Git**: Version control
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Java**: JDK 17 (for backend development)
- **Maven**: 3.8+ (for building)
- **Node.js**: 18+ (for frontend development)

### GitHub Access

You need a GitHub Personal Access Token with `read:packages` scope for:
- Pulling Docker images
- Downloading Maven dependencies from GitHub Packages

---

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/path-drc/path-drc-emr.git
cd path-drc-emr
```

### Configure Maven Settings

Create or update `~/.m2/settings.xml`:

```xml
<settings>
  <servers>
    <server>
      <id>path-drc</id>
      <username>YOUR_GITHUB_USERNAME</username>
      <password>YOUR_GITHUB_TOKEN</password>
    </server>
  </servers>
</settings>
```

### Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Edit as needed
nano .env
```

---

## Running Locally

### Option 1: Pull Pre-Built Images

Fastest way to get started:

```bash
# Login to GitHub Container Registry
docker login ghcr.io

# Pull images
docker compose pull

# Start services
docker compose up -d
```

### Option 2: Build Locally

For testing local changes:

```bash
# Build all images
docker compose build

# Start services
docker compose up -d
```

### Option 3: Build Specific Site

```bash
# Build site-specific distribution
docker compose build \
  --build-arg BUILD_TYPE=site \
  --build-arg MVN_PROJECT=akram

# Start
docker compose up -d
```

---

## Development Workflows

### Backend Development

For changes to the distribution configuration:

```bash
# Make changes to distro/ or sites/

# Rebuild backend
docker compose build backend

# Restart
docker compose up -d backend

# Watch logs
docker compose logs -f backend
```

### Frontend Development

For frontend configuration changes:

```bash
# Edit frontend/config/config.json

# Rebuild frontend
docker compose build frontend

# Restart
docker compose up -d frontend
```

### Configuration Changes

For Initializer configuration changes:

```bash
# Edit files in distro/configuration/

# Rebuild and restart
docker compose build backend
docker compose restart backend

# Or trigger Initializer reload
curl -X POST http://localhost/openmrs/ws/rest/v1/initializer/reload \
  -u admin:Admin123
```

---

## Project Structure

```
path-drc-emr/
├── distro/                 # Base distribution
│   ├── pom.xml
│   ├── distro.properties   # Module versions
│   └── configuration/      # Initializer configs
├── sites/                  # Site-specific builds
│   ├── akram/
│   └── libikisi/
├── frontend/               # Frontend assets
│   ├── Dockerfile
│   ├── config/
│   └── assets/
├── gateway/                # nginx configuration
│   ├── Dockerfile
│   └── default.conf.template
├── docker-compose.yml      # Service definitions
├── Dockerfile              # Backend image
└── pom.xml                 # Parent POM
```

---

## Useful Commands

### Service Management

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# Restart specific service
docker compose restart backend

# View logs
docker compose logs -f backend

# Shell access
docker compose exec backend bash
docker compose exec db mysql -u openmrs -popenmrs openmrs
```

### Building

```bash
# Build all images
docker compose build

# Build without cache
docker compose build --no-cache

# Build specific service
docker compose build backend

# Maven build (outside Docker)
mvn -P distro clean package
```

### Cleanup

```bash
# Remove containers
docker compose down

# Remove containers and volumes (WARNING: deletes data)
docker compose down -v

# Remove all project images
docker compose down --rmi all

# Clean Docker system
docker system prune
```

---

## Debugging

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend

# Last 100 lines
docker compose logs --tail 100 backend

# With timestamps
docker compose logs -t backend
```

### Database Access

```bash
# MySQL shell
docker compose exec db mysql -u openmrs -popenmrs openmrs

# Run query
docker compose exec db mysql -u openmrs -popenmrs openmrs \
  -e "SELECT * FROM users LIMIT 5;"
```

### Container Shell

```bash
# Backend container
docker compose exec backend bash

# Check files
docker compose exec backend ls -la /openmrs/distribution/
```

### Health Checks

```bash
# Check service status
docker compose ps

# Check backend health
curl http://localhost/openmrs/health/started

# Check session
curl http://localhost/openmrs/ws/rest/v1/session
```

---

## Testing

### Validate Configuration

```bash
# Run configuration validator
mvn -P distro,validator clean verify
```

### Build Test

```bash
# Test pull request build
mvn -P distro clean package
```

### Integration Testing

```bash
# Start fresh environment
docker compose down -v
docker compose up -d

# Wait for startup
while [[ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost/openmrs/login.htm)" != "200" ]]; do
    sleep 10
done

# Run tests...
```

---

## Common Issues

### Build Fails

**Maven dependency issues:**
```bash
# Check Maven settings
cat ~/.m2/settings.xml

# Clear cache and retry
rm -rf ~/.m2/repository/org/path
mvn -P distro clean package
```

### Container Won't Start

**Check logs:**
```bash
docker compose logs backend
```

**Check resources:**
```bash
docker stats --no-stream
df -h
```

### Slow Startup

First startup takes time for database initialization. Watch logs:
```bash
docker compose logs -f backend | grep -i "started\|error"
```

---

## IDE Setup

### IntelliJ IDEA

1. Open project as Maven project
2. Configure JDK 17
3. Import Maven settings from `~/.m2/settings.xml`

### VS Code

Recommended extensions:
- Docker
- Java Extension Pack
- XML Tools
- YAML

---

## Related

- [Building Images](building-images) - Image build details
- [CI/CD](ci-cd) - Automated builds
- [Contributing](contributing) - Contribution guidelines
