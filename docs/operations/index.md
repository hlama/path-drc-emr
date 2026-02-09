---
layout: default
title: Operations
nav_order: 4
has_children: true
permalink: /operations
---

# Operations

This section covers day-to-day operations, maintenance, and troubleshooting of PATH DRC EMR.

## Overview

Operating PATH DRC EMR involves regular monitoring, backups, user management, and occasional updates. This guide is designed for system operators and administrators responsible for keeping the EMR running smoothly.

## What's in This Section

### [Backup & Restore](backup-restore)
Configure automated backups, perform manual backups, restore from snapshots, manage backup retention.

### [Monitoring](monitoring)
Check system health, monitor logs, track disk space, identify performance issues.

### [Updates & Upgrades](updates-upgrades)
Update to new versions, apply content package updates, perform database migrations.

### [User Management](user-management)
Create user accounts, assign roles and privileges, manage provider accounts.

### [Troubleshooting](troubleshooting)
Solutions for service startup failures, database issues, frontend problems.

---

## Quick Reference

### Checking Service Status

```bash
# View all running services
docker compose ps

# Check specific service logs
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f db
```

### Restarting Services

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart backend
```

### Accessing the System

- **OpenMRS 3.0 Interface**: http://localhost/openmrs/spa
- **Legacy Admin UI**: http://localhost/openmrs
- **Default Credentials**: `admin` / `Admin123`

---

## System Health Checklist

- [ ] All Docker containers are running
- [ ] Application is accessible via web browser
- [ ] Users can log in successfully
- [ ] Database connections are stable
- [ ] Recent backup completed successfully
- [ ] Disk space is adequate (>20% free)
- [ ] No critical errors in logs

---

## Getting Help

1. **Check the logs**: `docker compose logs <service-name>`
2. **Review troubleshooting guide**: [Troubleshooting](troubleshooting)
3. **Search existing issues**: [GitHub Issues](https://github.com/path-drc/path-drc-emr/issues)
4. **Ask the community**: [OpenMRS Talk](https://talk.openmrs.org)
