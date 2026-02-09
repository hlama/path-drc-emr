---
layout: default
title: Offline Installation
parent: Deployment
nav_order: 2
---

# Offline Installation

Complete guide for installing PATH DRC EMR in air-gapped environments without internet connectivity.

---

## Overview

For environments without internet access, PATH DRC EMR provides pre-packaged Docker image bundles that can be transferred to the target system and loaded locally. This approach is ideal for:

- Remote healthcare facilities with limited connectivity
- Secure environments that prohibit internet access
- Locations with unreliable internet connections
- Deployments in areas with bandwidth constraints

---

## Prerequisites

### On the Download Machine (Internet Required)

- Internet access to download image bundles
- Web browser or command-line tools (curl, wget)
- Sufficient disk space (~5 GB for the bundle)
- Method to transfer files (USB drive, portable hard drive, local network)

### On the Target Machine (No Internet Required)

{: .warning }
> These specifications assume a bare metal installation of the OS. Running OpenMRS as a VM on a Windows computer for any production use is **NOT** recommended.

| Usage | CPU | RAM | Disk |
|-------|-----|-----|------|
| **Minimum (1-10 users)** | Quad-core processor | 8 GB | 100+ GB HDD |
| **Recommended (10+ users)** | 8+ cores | 16 GB | 100+ GB RAID |

- **Operating System**: Ubuntu 20.04+, Debian 11+, or similar Linux distribution
- **Docker**: Version 20.10 or newer (must be pre-installed)
- **Docker Compose**: Version 2.0 or newer (must be pre-installed)

{: .note }
> Docker and Docker Compose must be installed on the target machine before the offline installation. Install these while the machine has internet access, or use offline Docker installation packages.

---

## Step 1: Download the Image Bundle

### Option A: Download from GitHub Releases

1. Visit the [PATH DRC EMR Releases](https://github.com/path-drc/path-drc-emr/releases) page
2. Find the latest release
3. Download the `path-drc-emr-images-bundle.tgz` file

### Option B: Download via Command Line

On a machine with internet access:

```bash
# Get the latest release URL
RELEASE_URL=$(curl -s https://api.github.com/repos/path-drc/path-drc-emr/releases/latest | grep "browser_download_url.*images-bundle.tgz" | cut -d '"' -f 4)

# Download the bundle
curl -L -O "$RELEASE_URL"
```

### For Site-Specific Bundles

Site-specific bundles may be available:
- `path-drc-emr-images-bundle-akram.tgz`
- `path-drc-emr-images-bundle-libikisi.tgz`

Download the appropriate bundle for your facility.

---

## Step 2: Download Configuration Files

Also download the configuration files:

```bash
# Download docker-compose.yml
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/docker-compose.yml

# Download restore configuration
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/docker-compose-restore.yml

# Download environment example
curl -O https://raw.githubusercontent.com/path-drc/path-drc-emr/main/.env.example
```

---

## Step 3: Transfer Files to Target System

Transfer the following files to the target (air-gapped) system:

1. `path-drc-emr-images-bundle.tgz` (~4-5 GB)
2. `docker-compose.yml`
3. `docker-compose-restore.yml`
4. `.env.example`

### Transfer Methods

**USB Drive:**
```bash
# On download machine - copy to USB
cp path-drc-emr-images-bundle.tgz /media/usb-drive/
cp docker-compose.yml docker-compose-restore.yml .env.example /media/usb-drive/

# On target machine - copy from USB
cp /media/usb-drive/* /opt/path-drc-emr/
```

**Secure Copy (if local network available):**
```bash
scp path-drc-emr-images-bundle.tgz user@target-server:/opt/path-drc-emr/
scp docker-compose.yml docker-compose-restore.yml .env.example user@target-server:/opt/path-drc-emr/
```

---

## Step 4: Prepare Target System

On the target (air-gapped) machine:

### Create Project Directory

```bash
sudo mkdir -p /opt/path-drc-emr
cd /opt/path-drc-emr

# Set ownership
sudo chown -R $USER:$USER /opt/path-drc-emr
```

### Verify Docker Installation

```bash
# Check Docker is installed and running
docker --version
docker compose version
sudo systemctl status docker
```

If Docker is not installed, you'll need to install it using offline packages for your distribution.

---

## Step 5: Extract and Load Images

### Extract the Bundle

```bash
cd /opt/path-drc-emr

# Extract the bundle
tar -xzf path-drc-emr-images-bundle.tgz
```

This creates a directory with image files and a loading script.

### Load Images into Docker

```bash
# Run the load script
./load-images.sh
```

The script will load each Docker image. This may take several minutes.

### Verify Images Are Loaded

```bash
docker images | grep path-drc
```

You should see images for:
- `ghcr.io/path-drc/path-drc-emr-gateway`
- `ghcr.io/path-drc/path-drc-emr-frontend`
- `ghcr.io/path-drc/path-drc-emr-backend`

Plus the standard MariaDB and backup images.

---

## Step 6: Configure Environment Variables

Create and configure the `.env` file:

```bash
cp .env.example .env
nano .env   # or use your preferred editor
```

### Required Configuration

```bash
# Image tag - must match the loaded images
TAG=latest

# Backup password - use a strong password
RESTIC_PASSWORD=your-secure-backup-password
```

### Production Configuration

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

## Step 7: Start Services

Start all services:

```bash
docker compose up -d
```

### Monitor Startup

Watch the logs during first startup:

```bash
# Watch backend initialization
docker compose logs -f backend
```

First startup takes several minutes as the database initializes and metadata loads.

**Look for:**
- "OpenMRS Platform has started"
- All containers showing "running" in `docker compose ps`

---

## Step 8: Verify Installation

### Check Service Status

```bash
docker compose ps
```

All services should show "running" status.

### Access the Application

Open a web browser on the local network:

- **OpenMRS 3.0 Interface**: `http://server-ip/openmrs/spa`
- **Legacy Admin UI**: `http://server-ip/openmrs`

### Default Credentials

- **Username**: `admin`
- **Password**: `Admin123`

{: .warning }
> **Security**: Change the default password immediately!

---

## Step 9: Post-Installation

Complete the initial setup:

1. **Change admin password**
2. **Configure admin as provider**
3. **Create user accounts**
4. **Verify backup configuration**

See [Initial Setup](../getting-started/initial-setup) for detailed instructions.

---

## Updating an Offline Installation

To update an air-gapped installation:

1. **Download new bundle** on a machine with internet access
2. **Transfer to target** using USB or local network
3. **Stop services**: `docker compose down`
4. **Load new images**: `./load-images.sh`
5. **Start services**: `docker compose up -d`
6. **Verify**: Check logs and test functionality

---

## Backup Considerations for Offline Systems

### Local Backup Storage

For air-gapped systems, configure local backup storage:

```bash
RESTIC_REPOSITORY=/restic_data
BACKUP_PATH=/opt/path-drc-emr/backups
```

### Off-Site Backup Transfer

Periodically transfer backups to off-site storage:

```bash
# Copy backup directory to USB
cp -r /opt/path-drc-emr/backups /media/usb-drive/backups-$(date +%Y%m%d)
```

### Backup Rotation

Implement manual rotation for off-site backups:
- Keep weekly backups for current month
- Keep monthly backups for current year
- Keep yearly backups indefinitely

---

## Troubleshooting

### Images Fail to Load

**Error**: "Error loading image"

```bash
# Check the image file
file path-drc-emr-backend.tar

# Try loading manually
docker load < path-drc-emr-backend.tar
```

### Container Won't Start

**Error**: "image not found"

Verify the TAG matches loaded images:
```bash
# List available images
docker images | grep path-drc

# Update .env to match
TAG=latest
```

### Database Initialization Fails

Check available disk space:
```bash
df -h
```

Check container logs:
```bash
docker compose logs db
```

### Frontend Shows Blank Page

Wait for backend to fully initialize:
```bash
docker compose logs -f backend
# Look for "OpenMRS Platform has started"
```

---

## Clean Up After Installation

After successful installation, you can remove the bundle files to free disk space:

```bash
# Remove the bundle (keep images loaded in Docker)
rm path-drc-emr-images-bundle.tgz
rm -rf extracted-images/  # if applicable

# Keep these files
# - docker-compose.yml
# - docker-compose-restore.yml
# - .env
```

---

## Quick Reference

```bash
# Extract bundle
tar -xzf path-drc-emr-images-bundle.tgz

# Load images
./load-images.sh

# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Check status
docker compose ps

# List loaded images
docker images | grep path-drc
```

---

## Next Steps

- [Initial Setup](../getting-started/initial-setup) - Complete first-time configuration
- [Backup & Restore](../operations/backup-restore) - Configure local backups
- [User Management](../operations/user-management) - Create user accounts
- [Troubleshooting](../operations/troubleshooting) - Common issues and solutions
