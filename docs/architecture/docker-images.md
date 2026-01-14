---
layout: default
title: Docker Images
parent: Architecture
nav_order: 1
---

# Docker Images

Detailed information about each Docker image in the PATH DRC EMR distribution.

---

## Overview

PATH DRC EMR consists of five Docker images that work together to provide a complete EMR system:

| Image | Purpose | Base Image |
|-------|---------|------------|
| `gateway` | Reverse proxy and routing | nginx |
| `frontend` | OpenMRS 3.0 SPA | nginx |
| `backend` | OpenMRS server | openmrs-core |
| `db` | Database | MariaDB 10.11 |
| `backup` | Backup service | restic-compose-backup |

---

## Gateway Image

**Image**: `ghcr.io/path-drc/path-drc-emr-gateway:latest`

The gateway is an nginx reverse proxy that sits in front of the backend and frontend containers, providing a unified interface and handling CORS issues.

### Responsibilities

- Route requests to frontend or backend based on URL path
- Handle CORS headers
- Add security headers (CSP, X-XSS-Protection, X-Content-Type-Options)
- Compress responses with gzip
- Manage proxy settings for forwarded headers

### URL Routing

| Path | Destination |
|------|-------------|
| `/` | Redirects to `/openmrs/spa/` |
| `/openmrs/spa/` | Frontend container |
| `/openmrs/` | Backend container |

### Configuration

The gateway uses environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `FRAME_ANCESTORS` | Allowed frame ancestors for CSP | `'self'` |

---

## Frontend Image

**Image**: `ghcr.io/path-drc/path-drc-emr-frontend:${TAG:-latest}`

The frontend is an nginx container serving the OpenMRS 3.0 Single Page Application with pre-built frontend modules.

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SPA_PATH` | URL path for the SPA | `/openmrs/spa` |
| `API_URL` | Backend API URL | `/openmrs` |
| `SPA_CONFIG_URLS` | Configuration URLs | `/openmrs/spa/openmrs-config.json` |
| `SPA_DEFAULT_LOCALE` | Default language | `fr` |

### Health Check

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/"]
  timeout: 5s
```

### Frontend Modules

The frontend modules are configured in `frontend/spa-build-config.json`. See the repository for the current list of included modules.

---

## Backend Image

**Image**: `ghcr.io/path-drc/path-drc-emr-backend:${TAG:-latest}`

The backend image contains the OpenMRS server with all required modules and configuration.

### Base Image

Built from `openmrs/openmrs-core:2.7.x-amazoncorretto-17`

### Build Process

The backend image supports two build types:

1. **Base Distribution** (`BUILD_TYPE=distro`): Standard distribution with base configuration
2. **Site-Specific** (`BUILD_TYPE=site`): Includes site-specific configuration and metadata

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OMRS_CONFIG_MODULE_WEB_ADMIN` | Enable web admin | `true` |
| `OMRS_CONFIG_AUTO_UPDATE_DATABASE` | Auto-update database | `true` |
| `OMRS_CONFIG_CREATE_TABLES` | Create tables on startup | `true` |
| `OMRS_CONFIG_CONNECTION_SERVER` | Database server | `db` |
| `OMRS_CONFIG_CONNECTION_DATABASE` | Database name | `openmrs` |
| `OMRS_CONFIG_CONNECTION_USERNAME` | Database user | `openmrs` |
| `OMRS_CONFIG_CONNECTION_PASSWORD` | Database password | `openmrs` |

### Volumes

| Volume | Mount Point | Purpose |
|--------|-------------|---------|
| `openmrs-data` | `/openmrs/data` | Application data |
| `openmrs-config-checksums` | `/openmrs/data/configuration_checksums` | Initializer state |
| `openmrs-person-images` | `/openmrs/data/person_images` | Patient photos |
| `openmrs-complex-obs` | `/openmrs/data/complex_obs` | Complex observation data |

### Health Check

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/openmrs"]
  timeout: 5s
```

---

## Database Image

**Image**: `mariadb:10.11.7`

Standard MariaDB image configured for OpenMRS.

### Configuration

The database is started with UTF-8 support:

```bash
mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_general_ci
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MYSQL_DATABASE` | Database name | `openmrs` |
| `MYSQL_USER` | Database user | `openmrs` |
| `MYSQL_PASSWORD` | Database password | `openmrs` |
| `MYSQL_ROOT_PASSWORD` | Root password | `openmrs` |

### Volume

| Volume | Mount Point | Purpose |
|--------|-------------|---------|
| `db-data` | `/var/lib/mysql` | Database files |

### Health Check

```yaml
healthcheck:
  test: 'mysql --user=openmrs --password=openmrs --execute "SHOW DATABASES;"'
  interval: 3s
  timeout: 1s
  retries: 5
```

---

## Backup Image

**Image**: `mekomsolutions/restic-compose-backup:latest`

Automated backup service using Restic for data protection.

### Volumes

| Volume | Mount Point | Purpose |
|--------|-------------|---------|
| Docker socket | `/tmp/docker.sock` (read-only) | Container management |
| Backup path | `/restic_data` | Backup repository |
| `restic-cache` | `/cache` | Restic cache |

### Environment Variables

See [Backup & Restore](../operations/backup-restore) for complete configuration.

---

## Image Tags

### Tag Conventions

| Tag Pattern | Description |
|-------------|-------------|
| `latest` | Latest base distribution |
| `latest-akram` | Latest Akram site-specific build |
| `latest-libikisi` | Latest Libikisi site-specific build |
| `vX.Y.Z` | Specific version release |
| `vX.Y.Z-akram` | Site-specific version release |

### Multi-Architecture Support

Images are built for multiple architectures:
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64)

---

## Building Images Locally

### Base Distribution

```bash
docker compose build
```

### Site-Specific

```bash
TAG=latest-libikisi docker compose build \
  --build-arg BUILD_TYPE=site \
  --build-arg MVN_PROJECT=libikisi
```

See [Building Images](../development/building-images) for more details.

---

## Image Registry

Images are published to GitHub Container Registry:

```
ghcr.io/path-drc/path-drc-emr-gateway
ghcr.io/path-drc/path-drc-emr-frontend
ghcr.io/path-drc/path-drc-emr-backend
```

### Authentication

To pull images, authenticate with GitHub:

```bash
docker login ghcr.io
```

Use your GitHub username and a Personal Access Token with `read:packages` scope.
