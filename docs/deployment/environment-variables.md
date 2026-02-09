---
layout: default
title: Environment Variables
parent: Deployment
nav_order: 4
---

# Environment Variables

Complete reference for all PATH DRC EMR environment variables.

---

## Quick Setup

Create a `.env` file in the project root by copying the example:

```bash
cp .env.example .env
```

Edit the file to set your specific values.

---

## Core Configuration

### Docker Image Tags

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `TAG` | Docker image tag for frontend/backend | `latest` | `latest-akram` |

---

## Database Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `OMRS_DB_USER` | Database username | `openmrs` |
| `OMRS_DB_PASSWORD` | Database password | `openmrs` |
| `MYSQL_ROOT_PASSWORD` | MySQL root password | `openmrs` |

{: .warning }
> **Security**: Change the default database passwords for production deployments!

---

## Backend Configuration

These variables are set in docker-compose.yml but can be overridden:

| Variable | Description | Default |
|----------|-------------|---------|
| `OMRS_CONFIG_MODULE_WEB_ADMIN` | Enable web admin module | `true` |
| `OMRS_CONFIG_AUTO_UPDATE_DATABASE` | Auto-update database on startup | `true` |
| `OMRS_CONFIG_CREATE_TABLES` | Create tables if not exist | `true` |
| `OMRS_CONFIG_CONNECTION_SERVER` | Database server hostname | `db` |
| `OMRS_CONFIG_CONNECTION_DATABASE` | Database name | `openmrs` |

---

## Frontend Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `SPA_PATH` | URL path for the SPA | `/openmrs/spa` |
| `API_URL` | Backend API URL | `/openmrs` |
| `SPA_CONFIG_URLS` | Configuration file URL | `/openmrs/spa/openmrs-config.json` |
| `SPA_DEFAULT_LOCALE` | Default language | `fr` |

---

## Volume Paths

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENMRS_CONFIG_CHECKSUMS_PATH` | Initializer checksums | `openmrs-config-checksums` |
| `OPENMRS_PERSON_IMAGES_PATH` | Patient/person photos | `openmrs-person-images` |
| `OPENMRS_COMPLEX_OBS_PATH` | Complex observations | `openmrs-complex-obs` |

---

## Backup Configuration

### Repository Settings

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `RESTIC_REPOSITORY` | Backup repository URL | `/restic_data` | `s3:s3.amazonaws.com/bucket` |
| `RESTIC_PASSWORD` | Repository encryption password | `password` | (use strong password) |
| `BACKUP_PATH` | Local directory for backups | `./openmrs_backup` | `/mnt/backups` |

{: .warning }
> **Security**: Use a strong, unique password for `RESTIC_PASSWORD` and store it securely!

### Schedule Settings

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `RESTIC_CRON_SCHEDULE` | Backup schedule (cron format) | `*/5 * * * *` | `0 2 * * *` |
| `RESTIC_LOG_LEVEL` | Logging verbosity | `info` | `debug` |

### Retention Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `RESTIC_KEEP_DAILY` | Daily snapshots to keep | `7` |
| `RESTIC_KEEP_WEEKLY` | Weekly snapshots to keep | `4` |
| `RESTIC_KEEP_MONTHLY` | Monthly snapshots to keep | `12` |
| `RESTIC_KEEP_YEARLY` | Yearly snapshots to keep | `3` |

### Restore Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `RESTIC_RESTORE_SNAPSHOT` | Snapshot ID or tag to restore | `latest` |

---

## Gateway Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `FRAME_ANCESTORS` | CSP frame-ancestors directive | `'self'` |

---

## Cloud Backup Storage

For cloud storage backends, additional variables may be required:

### Amazon S3

```bash
RESTIC_REPOSITORY=s3:s3.amazonaws.com/your-bucket
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
```

### Azure Blob Storage

```bash
RESTIC_REPOSITORY=azure:your-container:/
AZURE_ACCOUNT_NAME=your-account-name
AZURE_ACCOUNT_KEY=your-account-key
```

### Google Cloud Storage

```bash
RESTIC_REPOSITORY=gs:your-bucket:/
GOOGLE_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```

---

## Example .env File

Here's a complete example for production:

```bash
# Docker image tag
TAG=latest-akram

# Database (change these for production!)
OMRS_DB_USER=openmrs
OMRS_DB_PASSWORD=your-secure-password
MYSQL_ROOT_PASSWORD=your-secure-root-password

# Backup configuration
RESTIC_REPOSITORY=/restic_data
RESTIC_PASSWORD=your-secure-backup-password
RESTIC_CRON_SCHEDULE=0 2 * * *
BACKUP_PATH=./openmrs_backup

# Retention
RESTIC_KEEP_DAILY=7
RESTIC_KEEP_WEEKLY=4
RESTIC_KEEP_MONTHLY=12
RESTIC_KEEP_YEARLY=3
RESTIC_LOG_LEVEL=info

# Restore (only used during restore)
RESTIC_RESTORE_SNAPSHOT=latest
```

---

## Cron Schedule Format

The `RESTIC_CRON_SCHEDULE` uses standard cron format:

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6)
│ │ │ │ │
* * * * *
```

**Examples:**
- `0 2 * * *` - Daily at 2:00 AM
- `0 */6 * * *` - Every 6 hours
- `0 3 * * 0` - Weekly on Sunday at 3:00 AM
- `*/5 * * * *` - Every 5 minutes (default, for testing)

---

## Applying Changes

After modifying `.env`, restart the affected services:

```bash
# Restart all services
docker compose down && docker compose up -d

# Or restart specific service
docker compose restart backend
docker compose restart backup
```

---

## Related

- [Backup & Restore](../operations/backup-restore) - Backup configuration details
- [Docker Images](../architecture/docker-images) - Image configuration
