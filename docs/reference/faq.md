---
layout: default
title: FAQ
parent: Reference
nav_order: 1
---

# Frequently Asked Questions

Common questions and answers about PATH DRC EMR.

---

## Installation

### What are the minimum system requirements?

**For 1-10 users:**
- Quad-core CPU
- 8 GB RAM
- 100+ GB disk space

**For 10+ users:**
- 8-core CPU
- 16 GB RAM
- 200+ GB disk space

See [Prerequisites](../getting-started/prerequisites) for full details.

### Can I run this on a virtual machine?

Yes, but ensure the VM has dedicated (not shared) resources. Shared resources can cause performance issues. Cloud providers like AWS EC2 work well.

### How long does first startup take?

First startup typically takes 10-20 minutes as the database is initialized and configurations are loaded. Subsequent startups are faster (2-5 minutes).

### Can I install without internet access?

Yes. Use the air-gapped installation bundle which includes all Docker images. See [Offline Installation](../deployment/offline-installation).

---

## Authentication and Users

### What are the default credentials?

| User | Password | Purpose |
|------|----------|---------|
| admin | Admin123 | System administrator |

{: .warning }
> Change default passwords immediately after installation.

### Why can't I access clinical features as admin?

The admin user needs a linked provider account to access clinical features. See [Initial Setup](../getting-started/initial-setup#step-2-configure-admin-user-as-provider).

### How do I create new users?

Use the System Administration module:
1. Navigate to **System Administration → Advanced Administration**
2. Go to **Manage Users**
3. Click **Add User**

See [User Management](../administration/user-management) for details.

### How do I reset a forgotten password?

As an administrator:
1. Go to **System Administration → Advanced Administration → Manage Users**
2. Find the user and click **Edit**
3. Set a new password

---

## Operations

### How do I back up the system?

The backup service runs automatically. Manual backup:

```bash
docker compose exec backup restic backup
```

See [Backups](../operations/backups) for complete documentation.

### How do I restore from backup?

```bash
# List available backups
docker compose exec backup restic snapshots

# Restore specific snapshot
docker compose exec backup restic restore SNAPSHOT_ID --target /restore
```

### How do I update to a new version?

```bash
# Pull latest images
docker compose pull

# Restart services
docker compose up -d
```

For offline environments, download the new image bundle first.

### How do I check system health?

```bash
# Check service status
docker compose ps

# Check backend health
curl http://localhost/openmrs/health/started

# View logs
docker compose logs -f backend
```

---

## Configuration

### How do I change the default language?

Edit the global property `default_locale`:

1. Go to **System Administration → Settings**
2. Find `default_locale`
3. Set to `en` (English) or `fr` (French)

Or update via configuration files in `globalproperties/`.

### How do I add new locations?

Edit `distro/configuration/locations/locations.csv`:

```csv
Uuid,Void/Retire,Name,Description,Parent,Tags
new-uuid,false,New Location,Description,Parent Location,Visit Location
```

Then rebuild and restart, or use Initializer reload.

### How do I customize forms?

Forms are JSON files in `distro/configuration/forms/`. Edit the JSON, rebuild, and restart. See [Metadata Management](../administration/metadata-management#forms).

### How do I add new concepts?

For CIEL concepts, add them via OCL exports. For custom concepts, add to `distro/configuration/concepts/concepts.csv`. See [Metadata Management](../administration/metadata-management#concepts).

---

## Troubleshooting

### Services won't start

**Check logs:**
```bash
docker compose logs backend
docker compose logs db
```

**Check resources:**
```bash
docker stats --no-stream
df -h
```

**Common causes:**
- Insufficient memory
- Port conflicts
- Database connection issues

### Login page shows but login fails

**Check if backend is ready:**
```bash
curl http://localhost/openmrs/health/started
```

If not ready, wait for initialization to complete.

**Check database connectivity:**
```bash
docker compose exec db mysql -u openmrs -popenmrs -e "SELECT 1"
```

### Forms don't load

**Check browser console** for JavaScript errors.

**Verify form configuration:**
```bash
docker compose exec backend ls /openmrs/distribution/configuration/forms/
```

**Check concept UUIDs** in form JSON reference valid concepts.

### Slow performance

**Check resource usage:**
```bash
docker stats --no-stream
```

**Possible solutions:**
- Increase available RAM
- Add more CPU cores
- Check disk I/O performance
- Review database query performance

### Data appears missing after restart

Data is stored in Docker volumes. If volumes were removed (`docker compose down -v`), data is lost.

**Prevention:**
- Never use `-v` flag unless intentionally resetting
- Maintain regular backups

---

## Development

### How do I set up a development environment?

See [Local Development](../development/local-development) for complete setup instructions.

### How do I validate configuration changes?

```bash
mvn -P distro,validator clean verify
```

### How do I build Docker images locally?

```bash
docker compose build
```

For site-specific builds:
```bash
docker compose build backend \
  --build-arg BUILD_TYPE=site \
  --build-arg MVN_PROJECT=akram
```

### How do I contribute changes?

1. Fork the repository
2. Create a feature branch
3. Make and test changes
4. Submit a pull request

See [Contributing](../development/contributing) for guidelines.

---

## Site-Specific

### How do I add a new site?

1. Create site directory under `sites/`
2. Add site-specific POM and configuration
3. Update CI/CD workflow
4. Test and deploy

See [Adding Sites](../administration/adding-sites) for complete guide.

### How do site overrides work?

Site-specific configurations overlay the base distribution. Files in `sites/{site}/` take precedence over `distro/`. This allows customization without modifying shared configuration.

---

## Getting Help

### Where can I get support?

- Check this documentation
- Search existing GitHub issues
- Open a new GitHub issue with details

### How do I report a bug?

Open a GitHub issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs
- Environment details

### Where can I learn more about OpenMRS?

- [OpenMRS Wiki](https://wiki.openmrs.org/)
- [OpenMRS Talk](https://talk.openmrs.org/)
- [OpenMRS 3.0 Documentation](https://o3-docs.openmrs.org/)
