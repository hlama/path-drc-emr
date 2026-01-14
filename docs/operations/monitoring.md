---
layout: default
title: Monitoring
parent: Operations
nav_order: 2
---

# Monitoring

Guide to monitoring system health, viewing logs, and tracking performance of PATH DRC EMR.

---

## Overview

Effective monitoring helps ensure PATH DRC EMR runs smoothly and allows you to identify issues before they impact users. This guide covers:

- Checking service status
- Viewing and analyzing logs
- Monitoring system resources
- Health checks and alerts

---

## Service Status

### Check All Services

```bash
docker compose ps
```

**Expected output:**
```
NAME                    STATUS              PORTS
path-drc-emr-backend    Up (healthy)        8080/tcp
path-drc-emr-db         Up (healthy)        3306/tcp
path-drc-emr-frontend   Up (healthy)        80/tcp
path-drc-emr-gateway    Up                  0.0.0.0:80->80/tcp
path-drc-emr-backup     Up
```

### Service Health States

| Status | Meaning | Action |
|--------|---------|--------|
| Up (healthy) | Running and passing health checks | None needed |
| Up | Running but no health check defined | Normal for some services |
| Up (unhealthy) | Running but failing health checks | Investigate logs |
| Restarting | Container is restarting | Check logs for errors |
| Exited | Container has stopped | Restart or investigate |

### Check Specific Service

```bash
# Check backend status
docker compose ps backend

# Check database status
docker compose ps db
```

---

## Viewing Logs

### All Services

```bash
# View all logs (recent)
docker compose logs

# Follow logs in real-time
docker compose logs -f

# View last 100 lines
docker compose logs --tail 100
```

### Specific Services

```bash
# Backend logs
docker compose logs backend
docker compose logs -f backend

# Database logs
docker compose logs db

# Frontend logs
docker compose logs frontend

# Gateway logs
docker compose logs gateway

# Backup service logs
docker compose logs backup
```

### Filter by Time

```bash
# Logs from last hour
docker compose logs --since 1h

# Logs from specific time
docker compose logs --since "2024-01-15T10:00:00"

# Logs until specific time
docker compose logs --until "2024-01-15T12:00:00"
```

### Save Logs to File

```bash
# Save all logs
docker compose logs > logs-$(date +%Y%m%d).txt

# Save specific service logs
docker compose logs backend > backend-logs-$(date +%Y%m%d).txt
```

---

## Key Log Messages

### Backend (OpenMRS)

**Successful Startup:**
```
INFO - OpenMRS Platform has started
```

**Module Loading:**
```
INFO - Starting module: <module-name>
INFO - Module <module-name> started
```

**Errors to Watch:**
```
ERROR - Failed to start module
ERROR - Database connection failed
WARN - Slow query detected
```

### Database (MariaDB)

**Successful Startup:**
```
[Note] mysqld: ready for connections
```

**Connection Issues:**
```
[Warning] Aborted connection
[ERROR] Can't connect to MySQL server
```

### Frontend

**Successful Startup:**
```
nginx: ready to accept connections
```

### Backup Service

**Successful Backup:**
```
Backup completed successfully
snapshot <id> saved
```

**Backup Errors:**
```
ERROR: backup failed
repository locked
```

---

## System Resources

### Docker Resource Usage

```bash
# Real-time resource usage
docker stats

# One-time snapshot
docker stats --no-stream
```

**Key Metrics:**
- **CPU %**: Should typically be under 80% sustained
- **MEM USAGE / LIMIT**: Memory consumption vs limit
- **NET I/O**: Network traffic
- **BLOCK I/O**: Disk read/write

### Disk Space

```bash
# Overall disk usage
df -h

# Docker disk usage
docker system df

# Detailed Docker disk usage
docker system df -v
```

### Check Volume Sizes

```bash
# List volumes with sizes
docker system df -v | grep -A 100 "Local Volumes"
```

---

## Health Checks

### Built-in Health Checks

PATH DRC EMR includes health checks for critical services:

**Backend:**
```bash
curl -f http://localhost:8080/openmrs
```

**Frontend:**
```bash
curl -f http://localhost/
```

**Database:**
```bash
mysql --user=openmrs --password=openmrs --execute "SHOW DATABASES;"
```

### Manual Health Verification

```bash
# Check backend is responding
docker compose exec gateway curl -s http://backend:8080/openmrs/ws/rest/v1/session

# Check database connectivity
docker compose exec db mysql -u openmrs -popenmrs -e "SELECT 1;"

# Check frontend is serving files
docker compose exec gateway curl -s http://frontend/ | head -5
```

### Application Health Endpoint

```bash
# Check OpenMRS REST API
curl http://localhost/openmrs/ws/rest/v1/session
```

Expected response includes session information if the server is healthy.

---

## Monitoring Checklist

### Daily Checks

- [ ] All services showing "Up" or "Up (healthy)"
- [ ] No error messages in recent logs
- [ ] Backup completed successfully (check backup logs)
- [ ] Disk space adequate (>20% free)
- [ ] Application accessible via browser

### Weekly Checks

- [ ] Review backup history
- [ ] Check disk space trends
- [ ] Review any warning messages in logs
- [ ] Verify database connections are stable
- [ ] Test login functionality

### Monthly Checks

- [ ] Review system resource usage trends
- [ ] Test backup restore (on test system if available)
- [ ] Check for available updates
- [ ] Review and archive old logs
- [ ] Verify backup retention policy is working

---

## Common Monitoring Commands

### Quick Health Check Script

Create a script `check-health.sh`:

```bash
#!/bin/bash

echo "=== PATH DRC EMR Health Check ==="
echo ""

echo "Service Status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}"
echo ""

echo "Disk Usage:"
df -h / | tail -1
echo ""

echo "Docker Disk Usage:"
docker system df --format "table {{.Type}}\t{{.Size}}\t{{.Reclaimable}}"
echo ""

echo "Recent Errors (last hour):"
docker compose logs --since 1h 2>&1 | grep -i error | tail -10
echo ""

echo "Backend Status:"
if docker compose exec -T gateway curl -sf http://backend:8080/openmrs > /dev/null; then
    echo "  Backend: OK"
else
    echo "  Backend: FAILED"
fi

echo "Frontend Status:"
if docker compose exec -T gateway curl -sf http://frontend/ > /dev/null; then
    echo "  Frontend: OK"
else
    echo "  Frontend: FAILED"
fi
```

Run it:
```bash
chmod +x check-health.sh
./check-health.sh
```

---

## Alerting

### Simple Log Monitoring

Create a cron job to check for errors:

```bash
# Edit crontab
crontab -e

# Add this line (checks every hour)
0 * * * * cd /opt/path-drc-emr && docker compose logs --since 1h 2>&1 | grep -i error >> /var/log/path-drc-errors.log
```

### Email Alerts (requires mail setup)

```bash
#!/bin/bash
ERRORS=$(docker compose logs --since 1h 2>&1 | grep -i error)
if [ ! -z "$ERRORS" ]; then
    echo "$ERRORS" | mail -s "PATH DRC EMR Errors" admin@example.com
fi
```

---

## Troubleshooting with Logs

### Backend Won't Start

```bash
# Check startup sequence
docker compose logs backend | grep -E "(ERROR|WARN|Starting|Started)"

# Look for database connection issues
docker compose logs backend | grep -i database

# Check for memory issues
docker compose logs backend | grep -i "out of memory"
```

### Database Issues

```bash
# Check database logs
docker compose logs db

# Check for connection errors
docker compose logs db | grep -i "connect"

# Check for disk space issues
docker compose logs db | grep -i "disk\|space"
```

### Slow Performance

```bash
# Check for slow queries
docker compose logs backend | grep -i "slow query"

# Check resource usage
docker stats --no-stream

# Check database connections
docker compose exec db mysql -u root -p -e "SHOW PROCESSLIST;"
```

---

## Log Rotation

Docker logs can grow large. Configure log rotation in `/etc/docker/daemon.json`:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
```

Restart Docker after changes:
```bash
sudo systemctl restart docker
```

---

## Related

- [Troubleshooting](troubleshooting) - Common issues and solutions
- [Backup & Restore](backup-restore) - Backup monitoring
- [Updates & Upgrades](updates-upgrades) - System updates
