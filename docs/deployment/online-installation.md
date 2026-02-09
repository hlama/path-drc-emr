---
layout: default
title: Online Installation
parent: Deployment
nav_order: 1
---

# Online Installation

Complete guide for installing PATH DRC EMR in environments with internet connectivity.

{: .note }
> For quick testing and evaluation, see [Quick Start](../getting-started/quick-start). This guide covers production deployments.

---

## Prerequisites

Before starting, ensure you have:

### Hardware Requirements

{: .warning }
> These specifications assume a bare metal installation of the OS. Running OpenMRS as a VM on a Windows computer for any production use is **NOT** recommended.

| Usage | CPU | RAM | Disk |
|-------|-----|-----|------|
| **Minimum (1-10 users)** | Quad-core processor | 8 GB | 100+ GB HDD |
| **Recommended (10+ users)** | 8+ cores | 16 GB | 100+ GB RAID |

**Cloud (AWS):**
- Minimum: EC2 t3.medium (1-10 users)
- Recommended: EC2 t3.large or higher (10+ users)

### Software Requirements

- **Operating System**: Ubuntu 20.04+, Debian 11+, or similar Linux distribution
- **Docker**: Version 20.10 or newer
- **Docker Compose**: Version 2.0 or newer

### Network Requirements

- Internet access to `ghcr.io` (GitHub Container Registry)
- Internet access to `github.com` (for downloading files)
- Port 80 available (or configure alternative port)

### Access Requirements

- Root or sudo access on the target system
- GitHub Personal Access Token with `read:packages` scope

See [Prerequisites](../getting-started/prerequisites) for detailed requirements.

---

## Step 1: Prepare the System

### Install Docker

If Docker is not installed, follow the official installation guide for your distribution:

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Verify Docker Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Verify Docker is running
sudo systemctl status docker
```

### Configure Docker (Optional)

Add your user to the docker group to run without sudo:

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

---

## Step 2: Create Project Directory

```bash
# Create directory for PATH DRC EMR
sudo mkdir -p /opt/path-drc-emr
cd /opt/path-drc-emr

# Set ownership (if running as non-root)
sudo chown -R $USER:$USER /opt/path-drc-emr
```

---

## Step 3: Download Configuration Files

Download the required Docker Compose and configuration files:

```bash
# Download docker-compose.yml
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/docker-compose.yml

# Download restore configuration (for backup/restore)
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/docker-compose-restore.yml

# Download environment example
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/.env.example
```

Verify the files were downloaded:

```bash
ls -la
# Should show: docker-compose.yml, docker-compose-restore.yml, .env.example
```

---

## Step 4: Configure Environment Variables

Create and configure the `.env` file:

```bash
# Copy example to .env
cp .env.example .env

# Edit the file
nano .env   # or use your preferred editor
```

### Required Configuration

At minimum, configure these variables:

```bash
# Image tag - use 'latest' for base or 'latest-sitename' for site-specific
TAG=latest

# Backup password - use a strong, unique password
RESTIC_PASSWORD=your-secure-backup-password
```

### Production Configuration

For production, also configure:

```bash
# Database credentials (change from defaults!)
OMRS_DB_USER=openmrs
OMRS_DB_PASSWORD=your-secure-db-password
MYSQL_ROOT_PASSWORD=your-secure-root-password

# Backup schedule (daily at 2 AM)
RESTIC_CRON_SCHEDULE=0 2 * * *

# Backup retention
RESTIC_KEEP_DAILY=7
RESTIC_KEEP_WEEKLY=4
RESTIC_KEEP_MONTHLY=12
RESTIC_KEEP_YEARLY=3
```

See [Environment Variables](environment-variables) for complete reference.

---

## Step 5: Authenticate with GitHub Container Registry

Create a GitHub Personal Access Token if you don't have one:

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "PATH DRC EMR deployment")
4. Select scope: `read:packages`
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again)

Log in to the container registry:

```bash
docker login ghcr.io
```

When prompted:
- **Username**: Your GitHub username
- **Password**: Your Personal Access Token (not your GitHub password)

Verify authentication:

```bash
# Should succeed without errors
docker pull ghcr.io/path-drc/path-drc-emr-gateway:latest
```

---

## Step 6: Pull Docker Images

Download all required images:

```bash
# Pull all images defined in docker-compose.yml
docker compose pull
```

This downloads approximately 2-3 GB of data. The time depends on your internet connection.

### For Site-Specific Installation

If deploying a site-specific build (e.g., Akram or Libikisi):

```bash
# Set the TAG and pull
TAG=latest-akram docker compose pull

# Or for Libikisi
TAG=latest-libikisi docker compose pull
```

---

## Step 7: Start Services

Start all services in the background:

```bash
docker compose up -d
```

### Monitor Startup

The first startup takes several minutes as OpenMRS initializes the database:

```bash
# Watch all logs
docker compose logs -f

# Or watch specific service
docker compose logs -f backend
```

**Look for these indicators:**
- Database: "ready for connections"
- Backend: "OpenMRS Platform has started"
- Frontend: Container is healthy

### Check Service Status

```bash
docker compose ps
```

All services should show "running" status.

---

## Step 8: Verify Installation

### Access the Application

Open a web browser and navigate to:

- **OpenMRS 3.0 Interface**: `http://your-server-ip/openmrs/spa`
- **Legacy Admin UI**: `http://your-server-ip/openmrs`

### Default Credentials

- **Username**: `admin`
- **Password**: `Admin123`

{: .warning }
> **Security**: Change the default password immediately after first login!

### Verify Components

1. **Login**: Verify you can log in with default credentials
2. **Dashboard**: Confirm the home page loads
3. **Patient Search**: Try searching for patients
4. **Metadata**: Verify locations and concepts are loaded

---

## Step 9: Post-Installation Configuration

Complete the initial setup:

1. **Change admin password** - Critical security step
2. **Configure admin as provider** - Required for clinical functions
3. **Create user accounts** - For your staff
4. **Verify backup is running** - Check backup logs

See [Initial Setup](../getting-started/initial-setup) for detailed instructions.

---

## Troubleshooting

### Backend Container Keeps Restarting

This is often normal during first startup. Wait 5-10 minutes for database initialization.

If it persists:
```bash
docker compose logs backend | tail -50
```

Common causes:
- Database not ready yet
- Memory constraints
- Configuration errors

### Cannot Pull Images

Verify authentication:
```bash
docker logout ghcr.io
docker login ghcr.io
```

Check network connectivity:
```bash
curl -I https://ghcr.io
```

### Port 80 Already in Use

Check what's using port 80:
```bash
sudo lsof -i :80
```

Either stop the conflicting service or modify `docker-compose.yml` to use a different port.

### Out of Disk Space

Check available space:
```bash
df -h
```

Clean up Docker resources:
```bash
docker system prune -a
```

---

## Security Considerations

### For Production Deployments

1. **Change all default passwords**:
   - Admin user password
   - Database passwords in `.env`
   - Backup password

2. **Configure HTTPS**:
   - Use a reverse proxy (nginx, Traefik) with SSL certificates
   - Consider Let's Encrypt for free certificates

3. **Restrict network access**:
   - Use firewall rules to limit access
   - Consider VPN for remote access

4. **Enable backups**:
   - Configure automated backups
   - Test restore procedures
   - Store backups off-site

5. **Monitor the system**:
   - Set up log monitoring
   - Configure alerts for failures

---

## Next Steps

- [Initial Setup](../getting-started/initial-setup) - Complete first-time configuration
- [Backup & Restore](../operations/backup-restore) - Configure backups
- [User Management](../operations/user-management) - Create user accounts
- [Monitoring](../operations/monitoring) - Set up monitoring

---

## Quick Reference

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Restart services
docker compose restart

# Check status
docker compose ps

# Update images
docker compose pull && docker compose up -d
```
