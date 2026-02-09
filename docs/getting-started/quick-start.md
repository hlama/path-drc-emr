---
layout: default
title: Quick Start
parent: Getting Started
nav_order: 2
---

# Quick Start

Get PATH DRC EMR running quickly for testing and evaluation purposes.

{: .warning }
> This quick start is intended for **testing and evaluation only**. For production deployments, see the [Deployment Guide](../deployment/).

---

## Overview

This guide will help you get PATH DRC EMR running in under 15 minutes using pre-built Docker images.

**What you'll need:**
- A system meeting [Prerequisites](prerequisites)
- Stable internet connectivity
- GitHub Personal Access Token with `read:packages` scope

**Two installation methods:**
1. **Pull published images (recommended)** - Faster, no build required
2. **Build locally** - Only if you need to test local code changes

---

## Method 1: Pull Published Images (Recommended)

This method is recommended unless you have made local changes to the code that you want to test.

### Step 1: Create Project Directory

```bash
mkdir path-drc-emr
cd path-drc-emr
```

### Step 2: Download Required Files

```bash
# Download docker-compose.yml
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/docker-compose.yml

# Download restore configuration (for backup/restore)
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/docker-compose-restore.yml

# Download environment variables example
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/.env.example
```

### Step 3: Configure Environment

```bash
# Create .env from example
cp .env.example .env
```

Edit `.env` and set at minimum:

```bash
TAG=latest
RESTIC_PASSWORD=changeme
```

### Step 4: Authenticate with GitHub

```bash
docker login ghcr.io
```

When prompted:
- **Username**: Your GitHub username
- **Password**: Your GitHub Personal Access Token (not your GitHub password)

### Step 5: Pull Docker Images

```bash
docker compose pull
```

### Step 6: Start Services

```bash
docker compose up -d
```

---

## Method 2: Build Locally

{: .note }
> This method is only recommended if you need to test local code changes. Building requires a good internet connection to download dependencies.

### Step 1: Clone Repository

```bash
git clone https://github.com/path-drc/path-drc-emr.git
cd path-drc-emr
```

### Step 2: Configure Maven Settings

Since the content package is hosted on GitHub Packages, configure your Maven settings. See [GitHub Packages Maven Configuration](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-apache-maven-registry).

### Step 3: Build and Run

```bash
docker compose build
docker compose up -d
```

---

## Verify Installation

### Check Container Status

```bash
docker compose ps
```

All containers should show "running" or "healthy" status.

### Monitor Startup Progress

The first startup takes several minutes as the database initializes:

```bash
docker compose logs -f backend
```

Look for: **"OpenMRS Platform has started"**

### Wait for System Ready

You can use this script to wait until the system is fully ready:

```bash
while [[ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost/openmrs/login.htm)" != "200" ]]; do
    echo "Waiting for OpenMRS to start..."
    sleep 10
done
echo "OpenMRS is ready!"
```

Alternatively, check the health endpoint:

```bash
curl -v http://localhost/openmrs/health/started
```

---

## Access the Application

Once startup is complete:

- **OpenMRS 3.0 Interface**: [http://localhost/openmrs/spa](http://localhost/openmrs/spa)
- **Legacy Admin UI**: [http://localhost/openmrs](http://localhost/openmrs)

### Default Credentials

- **Username**: `admin`
- **Password**: `Admin123`

{: .warning }
> **Change the default password immediately** for any production use!

---

## Troubleshooting Quick Start

### Backend Container Keeps Restarting

This can happen during first startup. The backend waits for the database to initialize:

```bash
# Check backend logs
docker compose logs backend
```

If you see "Waiting for database" messages, wait a few more minutes.

### Error on First Access

If you see an error when accessing the application:

1. Restart the backend service:
   ```bash
   docker compose down backend
   docker compose up backend
   ```

2. Try accessing the application again

### Cannot Pull Images

Verify your GitHub authentication:

```bash
docker logout ghcr.io
docker login ghcr.io
```

Ensure your Personal Access Token has `read:packages` scope.

---

## Useful Commands

```bash
# Check service status
docker compose ps

# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f backend

# Restart all services
docker compose restart

# Restart specific service
docker compose restart backend

# Stop all services
docker compose down

# Stop and remove volumes (WARNING: deletes data!)
docker compose down -v
```

---

## Next Steps

After getting the system running:

1. **[Initial Setup](initial-setup)** - Complete first-time configuration
   - Change admin password
   - Configure admin as provider
   - Create user accounts

2. **[Deployment Guide](../deployment/)** - For production deployments
   - Online installation
   - Offline installation
   - Environment configuration

3. **[Backup & Restore](../operations/backup-restore)** - Set up backups
