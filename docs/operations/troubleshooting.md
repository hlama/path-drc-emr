---
layout: default
title: Troubleshooting
parent: Operations
nav_order: 5
---

# Troubleshooting

Common issues and solutions for PATH DRC EMR.

---

## Overview

This guide covers common problems you may encounter with PATH DRC EMR and provides solutions. Issues are organized by category:

- [Startup Issues](#startup-issues)
- [Login Problems](#login-problems)
- [Performance Issues](#performance-issues)
- [Database Issues](#database-issues)
- [Backup Problems](#backup-problems)
- [Frontend Issues](#frontend-issues)
- [Container Problems](#container-problems)

---

## Quick Diagnostics

Run these commands to quickly assess system health:

```bash
# Check all container status
docker compose ps

# Check for recent errors
docker compose logs --since 1h 2>&1 | grep -i error

# Check disk space
df -h

# Check memory usage
docker stats --no-stream

# Verify backend is responding
curl -s http://localhost/openmrs/ws/rest/v1/session
```

---

## Startup Issues

### Backend Container Keeps Restarting

**Symptoms:**
- Backend shows "Restarting" in `docker compose ps`
- Application not accessible

**Common Causes and Solutions:**

1. **Database not ready yet**

   On first startup, the database takes time to initialize:
   ```bash
   # Wait and watch logs
   docker compose logs -f backend
   ```
   Look for "Waiting for database" messages. First startup can take 5-10 minutes.

2. **Out of memory**

   ```bash
   # Check memory usage
   docker stats --no-stream

   # Check for OOM in logs
   docker compose logs backend | grep -i "out of memory"
   ```

   Solution: Increase available memory or reduce heap size in environment variables.

3. **Database connection failed**

   ```bash
   # Check database is running
   docker compose ps db

   # Check database logs
   docker compose logs db

   # Test connection
   docker compose exec db mysql -u openmrs -popenmrs -e "SELECT 1;"
   ```

   Solution: Verify database credentials in `.env` match.

4. **Corrupted data volume**

   ```bash
   # Check for database errors
   docker compose logs db | grep -i "error\|corrupt"
   ```

   Solution: May need to restore from backup.

### Database Container Won't Start

**Symptoms:**
- Database shows "Exit" status
- Backend fails waiting for database

**Solutions:**

1. **Check logs for specific error:**
   ```bash
   docker compose logs db
   ```

2. **Permission issues:**
   ```bash
   # Check volume permissions
   docker compose exec db ls -la /var/lib/mysql
   ```

3. **Disk space full:**
   ```bash
   df -h
   docker system df
   ```

   Free space by cleaning unused Docker resources:
   ```bash
   docker system prune
   ```

4. **Port conflict:**
   ```bash
   sudo lsof -i :3306
   ```

### Frontend Container Not Healthy

**Symptoms:**
- Frontend shows "unhealthy" status
- Blank page in browser

**Solutions:**

1. **Check nginx configuration:**
   ```bash
   docker compose logs frontend
   ```

2. **Verify assets are served:**
   ```bash
   docker compose exec gateway curl -sf http://frontend/
   ```

---

## Login Problems

### Cannot Log In with Correct Credentials

**Check if account exists and is not retired:**
```bash
docker compose exec db mysql -u openmrs -popenmrs openmrs -e \
  "SELECT username, retired FROM users WHERE username = 'admin';"
```

**Reset admin password:**
```bash
docker compose exec db mysql -u openmrs -popenmrs openmrs -e \
  "UPDATE users SET password = '4a1750c8607d25e4d30019c8e7c5d774bf1c3c1e1c9d3cc1c7c1e2e1a3b5c7d9', salt = 'abc123' WHERE username = 'admin';"
```

{: .note }
> After resetting password in the database, the temporary password will be `Admin123`. Change it immediately after logging in.

### "Session expired" Errors

**Symptoms:**
- Users frequently logged out
- "Session expired" messages

**Solutions:**

1. **Check session timeout settings** in OpenMRS admin
2. **Verify time synchronization** between server and clients
3. **Check for proxy/load balancer issues** with session affinity

### Account Locked

Accounts may be locked after multiple failed login attempts:

```bash
# Check if account is locked
docker compose exec db mysql -u openmrs -popenmrs openmrs -e \
  "SELECT username, user_id FROM users WHERE username = 'username';"

# Unlock by resetting login attempts (if such tracking exists)
```

---

## Performance Issues

### Slow Page Loads

**Diagnostics:**

```bash
# Check resource usage
docker stats --no-stream

# Check for slow queries
docker compose logs backend | grep -i "slow query"

# Check database performance
docker compose exec db mysql -u openmrs -popenmrs -e "SHOW PROCESSLIST;"
```

**Solutions:**

1. **Increase memory allocation:**

   Edit `.env`:
   ```bash
   OMRS_JAVA_MEMORY_OPTS=-Xmx2g -Xms1g
   ```

   Then restart:
   ```bash
   docker compose down && docker compose up -d
   ```

2. **Optimize database:**
   ```bash
   docker compose exec db mysql -u openmrs -popenmrs openmrs -e "OPTIMIZE TABLE obs, encounter, patient;"
   ```

3. **Check disk I/O:**
   ```bash
   iostat -x 1 5
   ```

   Consider moving to SSD storage if disk is bottleneck.

### High Memory Usage

```bash
# Check container memory
docker stats --no-stream

# Check host memory
free -h
```

**Solutions:**

1. **Limit container memory** in docker-compose.yml:
   ```yaml
   backend:
     deploy:
       resources:
         limits:
           memory: 4G
   ```

2. **Reduce Java heap size** if system has limited RAM

3. **Restart containers** to free memory:
   ```bash
   docker compose restart backend
   ```

### High CPU Usage

```bash
# Identify high-CPU container
docker stats --no-stream

# Check what's running in backend
docker compose exec backend ps aux
```

**Common causes:**
- Database query optimization needed
- Large report generation
- Initial module loading (temporary)

---

## Database Issues

### Database Connection Errors

**Symptoms:**
- "Cannot connect to database" in logs
- Backend fails to start

**Diagnostics:**
```bash
# Check database is running
docker compose ps db

# Check database logs
docker compose logs db

# Test connection from backend
docker compose exec backend mysql -h db -u openmrs -popenmrs -e "SELECT 1;"
```

**Solutions:**

1. **Restart database:**
   ```bash
   docker compose restart db
   ```

2. **Check credentials match** in `.env`

3. **Check database health:**
   ```bash
   docker compose exec db mysql -u root -p -e "SHOW STATUS LIKE 'Uptime';"
   ```

### Database Too Many Connections

```bash
# Check current connections
docker compose exec db mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"

# Check max connections
docker compose exec db mysql -u root -p -e "SHOW VARIABLES LIKE 'max_connections';"
```

**Solution:** Increase max_connections or investigate connection leaks.

### Corrupted Tables

**Symptoms:**
- Error messages about table crashes
- Data inconsistencies

**Repair tables:**
```bash
# Check tables
docker compose exec db mysqlcheck -u root -p --check openmrs

# Repair if needed
docker compose exec db mysqlcheck -u root -p --repair openmrs
```

---

## Backup Problems

### Backup Fails to Run

**Check backup container:**
```bash
docker compose ps backup
docker compose logs backup
```

**Common issues:**

1. **Repository not initialized:**
   ```bash
   docker compose exec backup restic init
   ```

2. **Wrong password:**
   Verify `RESTIC_PASSWORD` in `.env` matches repository password.

3. **Disk full:**
   ```bash
   df -h
   ```

### Backup Takes Too Long

**Solutions:**

1. **Check backup size:**
   ```bash
   docker compose exec backup restic stats
   ```

2. **Increase backup frequency** to reduce incremental size

3. **Check network** if backing up to remote location

### Cannot Restore Backup

**Diagnostics:**
```bash
# List available snapshots
docker compose exec backup restic snapshots

# Check specific snapshot
docker compose exec backup restic ls <snapshot-id>
```

**Common issues:**
- Wrong password
- Corrupted repository
- Missing snapshot

See [Backup & Restore](backup-restore) for detailed restore procedures.

---

## Frontend Issues

### Blank Page or Loading Forever

**Diagnostics:**
```bash
# Check frontend container
docker compose ps frontend

# Check frontend logs
docker compose logs frontend

# Verify assets are accessible
docker compose exec gateway curl -I http://frontend/
```

**Solutions:**

1. **Clear browser cache** and hard refresh (Ctrl+Shift+R)

2. **Check backend is fully started:**
   ```bash
   docker compose logs backend | grep "OpenMRS Platform has started"
   ```

3. **Check for JavaScript errors** in browser developer console

### "404 Not Found" Errors

**Check gateway routing:**
```bash
docker compose logs gateway
docker compose exec gateway cat /etc/nginx/conf.d/default.conf
```

**Verify services are running:**
```bash
docker compose ps
```

### Forms Not Loading

**Check backend API:**
```bash
curl -u admin:Admin123 http://localhost/openmrs/ws/rest/v1/form
```

**Check for module errors:**
```bash
docker compose logs backend | grep -i "form\|error"
```

---

## Container Problems

### Container Exits Immediately

**Get exit code and logs:**
```bash
docker compose ps -a
docker compose logs <service-name>
```

**Common exit codes:**
- `0`: Normal exit
- `1`: General error
- `137`: Out of memory (OOM killed)
- `143`: SIGTERM received

### Cannot Exec Into Container

**Error:** "Container is not running"

**Solution:**
```bash
# Check container status
docker compose ps

# Start container if stopped
docker compose up -d <service-name>
```

### Disk Space Issues

**Check Docker disk usage:**
```bash
docker system df
docker system df -v
```

**Clean up:**
```bash
# Remove unused containers, networks, images
docker system prune

# Also remove unused volumes (careful - data loss!)
docker system prune --volumes

# Remove old images
docker image prune -a
```

### Network Connectivity Issues

**Check Docker network:**
```bash
docker network ls
docker network inspect path-drc-emr_default
```

**Test container-to-container connectivity:**
```bash
docker compose exec gateway ping backend
docker compose exec backend ping db
```

---

## Log Analysis

### Finding Relevant Logs

```bash
# All errors from last hour
docker compose logs --since 1h 2>&1 | grep -i error

# Backend errors
docker compose logs backend 2>&1 | grep -i "error\|exception\|fail"

# Database errors
docker compose logs db 2>&1 | grep -i "error\|warning"

# Specific time range
docker compose logs --since "2024-01-15T09:00:00" --until "2024-01-15T10:00:00"
```

### Common Error Messages

| Error Message | Likely Cause | Solution |
|---------------|--------------|----------|
| "Connection refused" | Service not running | Start the service |
| "Out of memory" | Insufficient RAM | Increase memory limit |
| "Disk full" | No disk space | Free up space |
| "Permission denied" | Wrong file permissions | Fix permissions |
| "Module failed to start" | Module error | Check module compatibility |

---

## Getting Help

### Information to Gather

When seeking help, collect:

1. **System information:**
   ```bash
   docker --version
   docker compose version
   uname -a
   df -h
   free -h
   ```

2. **Container status:**
   ```bash
   docker compose ps
   ```

3. **Recent logs:**
   ```bash
   docker compose logs --since 1h > logs.txt
   ```

4. **Configuration (redact passwords):**
   ```bash
   cat .env | grep -v PASSWORD
   ```

### Resources

- [OpenMRS Talk](https://talk.openmrs.org/) - Community forum
- [OpenMRS Wiki](https://wiki.openmrs.org/) - Documentation
- Project issues tracker - Report bugs

---

## Quick Reference

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart backend

# View logs
docker compose logs -f

# Check status
docker compose ps

# Clean restart
docker compose down && docker compose up -d

# Check disk space
df -h && docker system df

# Check memory
docker stats --no-stream

# Database shell
docker compose exec db mysql -u openmrs -popenmrs openmrs
```

---

## Related

- [Monitoring](monitoring) - System monitoring
- [Backup & Restore](backup-restore) - Data protection
- [User Management](user-management) - User issues
