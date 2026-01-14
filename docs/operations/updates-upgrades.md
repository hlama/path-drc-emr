---
layout: default
title: Updates & Upgrades
parent: Operations
nav_order: 6
---

# Updates & Upgrades

Guide to updating and upgrading PATH DRC EMR installations.

---

## Overview

This guide covers:
- Routine updates (same version, new images)
- Version upgrades (new OpenMRS or module versions)
- Rollback procedures
- Best practices for safe updates

---

## Update vs Upgrade

| Type | Description | Risk Level | Downtime |
|------|-------------|------------|----------|
| **Update** | Pull latest images, same version | Low | 5-15 minutes |
| **Upgrade** | New version with schema changes | Medium-High | 15-60 minutes |
| **Hotfix** | Emergency patch | Low-Medium | 5-15 minutes |

---

## Before Any Update

### Pre-Update Checklist

- [ ] Review release notes for breaking changes
- [ ] Create full backup
- [ ] Verify backup completed successfully
- [ ] Notify users of planned maintenance
- [ ] Have rollback plan ready
- [ ] Test in staging environment if possible

### Create Backup

**Critical:** Always backup before updating.

```bash
# Trigger manual backup
docker compose exec backup restic backup

# Verify backup completed
docker compose exec backup restic snapshots

# Note the snapshot ID for potential rollback
```

### Check Current Version

```bash
# Check current image versions
docker compose images

# Check OpenMRS version
curl -s http://localhost/openmrs/ws/rest/v1/session | grep version
```

---

## Routine Updates

### Online Installation Updates

For systems with internet access:

```bash
# Navigate to project directory
cd /opt/path-drc-emr

# Pull latest images
docker compose pull

# Review what will change
docker compose images

# Stop services
docker compose down

# Start with new images
docker compose up -d

# Monitor startup
docker compose logs -f backend
```

### Verify Update Success

```bash
# Check all services are healthy
docker compose ps

# Verify application is accessible
curl -sf http://localhost/openmrs/spa > /dev/null && echo "OK" || echo "FAILED"

# Check for errors in logs
docker compose logs --since 5m | grep -i error
```

---

## Offline Installation Updates

For air-gapped systems without internet:

### Step 1: Download New Bundle (On Internet Machine)

```bash
# Get latest release URL
RELEASE_URL=$(curl -s https://api.github.com/repos/path-drc/path-drc-emr/releases/latest | grep "browser_download_url.*images-bundle.tgz" | cut -d '"' -f 4)

# Download bundle
curl -L -O "$RELEASE_URL"
```

### Step 2: Transfer to Target System

Copy `path-drc-emr-images-bundle.tgz` to the target system via USB drive or local network.

### Step 3: Apply Update

```bash
# Navigate to project directory
cd /opt/path-drc-emr

# Create backup before updating
docker compose exec backup restic backup

# Stop services
docker compose down

# Extract new images
tar -xzf path-drc-emr-images-bundle.tgz

# Load images
./load-images.sh

# Start services
docker compose up -d

# Monitor startup
docker compose logs -f backend
```

---

## Version Upgrades

Major version upgrades may include database schema changes and require additional steps.

### Check for Schema Changes

Review release notes for:
- Database migrations
- New required modules
- Deprecated features
- Breaking changes

### Upgrade Procedure

```bash
# 1. Create backup
docker compose exec backup restic backup

# 2. Export current database (additional safety)
docker compose exec db mysqldump -u openmrs -popenmrs openmrs > pre-upgrade-$(date +%Y%m%d).sql

# 3. Update environment if needed
nano .env  # Update TAG or other variables

# 4. Pull/load new images
docker compose pull  # or load from bundle

# 5. Stop services
docker compose down

# 6. Start with new version
docker compose up -d

# 7. Monitor migration
docker compose logs -f backend
```

### Post-Upgrade Verification

```bash
# Check services status
docker compose ps

# Verify database migrations completed
docker compose logs backend | grep -i "migration\|liquibase\|update"

# Test key functionality:
# - Login
# - Patient search
# - Form submission
# - Reports
```

---

## Rollback Procedures

### Quick Rollback (Same Session)

If issues are discovered immediately after update:

```bash
# Stop current containers
docker compose down

# List available images
docker images | grep path-drc

# Specify previous version
TAG=previous-version docker compose up -d
```

### Rollback to Backup

For more serious issues requiring data rollback:

```bash
# Stop all services
docker compose down

# List available snapshots
docker compose -f docker-compose.yml -f docker-compose-restore.yml run --rm restore restic snapshots

# Restore specific snapshot
docker compose -f docker-compose.yml -f docker-compose-restore.yml run --rm restore

# Restart services
docker compose up -d
```

### Emergency Rollback

If normal rollback fails:

```bash
# Stop everything
docker compose down

# Remove volumes (WARNING: Data loss if backup restore fails)
docker compose down -v

# Start fresh with previous version
TAG=previous-version docker compose up -d

# Restore from backup
docker compose -f docker-compose.yml -f docker-compose-restore.yml run --rm restore
```

---

## Update Strategies

### Recommended Approach

1. **Test First**
   - If possible, test updates in a non-production environment
   - Use backup data to create test instance

2. **Schedule Maintenance Window**
   - Update during low-usage periods
   - Notify users in advance
   - Plan for worst-case duration

3. **Have Support Ready**
   - Keep team members available during update
   - Have contact information for escalation

### Rolling Updates (Future)

{: .note }
> Currently, PATH DRC EMR requires full restart for updates. Rolling updates may be supported in future versions.

---

## Monitoring Updates

### During Update

```bash
# Watch all container status
watch -n 2 docker compose ps

# Follow backend logs for startup progress
docker compose logs -f backend

# Watch for specific events
docker compose logs -f 2>&1 | grep -E "(Started|Error|Failed|Complete)"
```

### Post-Update Monitoring

Continue monitoring for several hours after update:

```bash
# Check for delayed errors
docker compose logs --since 1h | grep -i error

# Monitor resource usage
docker stats

# Watch application logs
docker compose logs -f backend
```

---

## Specific Component Updates

### Gateway Updates

Usually safe, minimal impact:

```bash
docker compose pull gateway
docker compose up -d gateway
```

### Frontend Updates

Usually safe, may need cache clear:

```bash
docker compose pull frontend
docker compose up -d frontend
```

Inform users to clear browser cache if issues occur.

### Backend Updates

Higher risk, may include schema changes:

```bash
# Always backup first
docker compose exec backup restic backup

# Update
docker compose pull backend
docker compose up -d backend
docker compose logs -f backend
```

### Database Updates

Highest risk, proceed with caution:

```bash
# Full backup essential
docker compose exec db mysqldump -u openmrs -popenmrs openmrs > full-backup-$(date +%Y%m%d).sql

# Update
docker compose pull db
docker compose up -d db

# Verify
docker compose exec db mysql -u openmrs -popenmrs -e "SELECT 1;"
```

---

## Automated Updates

{: .warning }
> Automated updates are not recommended for production systems. Always review changes and test before applying.

### Notification Script

Create a script to check for updates:

```bash
#!/bin/bash
# check-updates.sh

cd /opt/path-drc-emr

# Check for new images
docker compose pull --dry-run 2>&1 | grep -q "Downloaded" && {
    echo "Updates available for PATH DRC EMR"
    # Send notification (configure as needed)
}
```

Add to cron for daily checks:

```bash
0 8 * * * /opt/path-drc-emr/check-updates.sh | mail -s "Update Check" admin@example.com
```

---

## Troubleshooting Updates

### Update Fails to Pull Images

**Authentication error:**
```bash
docker logout ghcr.io
docker login ghcr.io
```

**Network issues:**
```bash
curl -I https://ghcr.io
```

### Services Won't Start After Update

**Check logs:**
```bash
docker compose logs backend | tail -50
```

**Check for version mismatch:**
```bash
docker compose images
```

**Rollback if needed:**
```bash
TAG=previous-version docker compose up -d
```

### Database Migration Fails

**Check migration logs:**
```bash
docker compose logs backend | grep -i "liquibase\|migration\|upgrade"
```

**Possible solutions:**
1. Wait - some migrations take time
2. Check disk space
3. Review specific error message
4. Rollback and seek support

### Frontend Shows Old Version

**Clear browser cache:**
- Hard refresh: Ctrl+Shift+R
- Clear all cached data

**Verify new version deployed:**
```bash
docker compose exec frontend ls -la /usr/share/nginx/html
```

---

## Best Practices

### Documentation

- Keep a log of all updates with dates and versions
- Document any issues encountered and solutions
- Save release notes for reference

### Testing

- Test updates in staging environment when possible
- Have test scripts for critical functionality
- Verify backup restore works before major updates

### Communication

- Notify users before planned maintenance
- Provide estimated downtime
- Communicate when update is complete

### Timing

- Schedule updates during low-usage periods
- Avoid updates during critical reporting periods
- Allow buffer time for unexpected issues

---

## Quick Reference

```bash
# Check for updates (online)
docker compose pull --dry-run

# Apply update
docker compose pull && docker compose down && docker compose up -d

# Verify update
docker compose ps
docker compose logs --since 5m | grep -i error

# Rollback
docker compose down
TAG=previous-version docker compose up -d

# Full update with backup
docker compose exec backup restic backup && \
  docker compose pull && \
  docker compose down && \
  docker compose up -d && \
  docker compose logs -f backend
```

---

## Related

- [Backup & Restore](backup-restore) - Data protection
- [Monitoring](monitoring) - System monitoring
- [Troubleshooting](troubleshooting) - Common issues
- [Offline Installation](../deployment/offline-installation) - Air-gapped updates
