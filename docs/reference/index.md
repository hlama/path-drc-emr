---
layout: default
title: Reference
nav_order: 8
has_children: true
permalink: /reference
---

# Reference

Quick reference materials, terminology, and external resources.

## What's in This Section

### [FAQ](faq)
Frequently asked questions about PATH DRC EMR.

### [Glossary](glossary)
Definitions of terms used throughout the documentation.

### [External Resources](external-resources)
Links to related documentation and resources.

---

## Quick Links

### Official Resources
- **PATH DRC EMR Repository**: [github.com/path-drc/path-drc-emr](https://github.com/path-drc/path-drc-emr)
- **Content Package**: [github.com/path-drc/openmrs-content-path-drc](https://github.com/path-drc/openmrs-content-path-drc)

### OpenMRS Resources
- **OpenMRS Wiki**: [wiki.openmrs.org](https://wiki.openmrs.org)
- **OpenMRS Talk**: [talk.openmrs.org](https://talk.openmrs.org)

### Technical Documentation
- **Docker Documentation**: [docs.docker.com](https://docs.docker.com)
- **Restic Backup**: [restic.readthedocs.io](https://restic.readthedocs.io)
- **Initializer Module**: [github.com/mekomsolutions/openmrs-module-initializer](https://github.com/mekomsolutions/openmrs-module-initializer)

---

## Command Reference

### Docker Compose Commands

```bash
docker compose up -d          # Start services
docker compose down           # Stop services
docker compose logs -f        # View logs
docker compose restart        # Restart services
docker compose ps             # View status
docker compose pull           # Pull images
docker compose build          # Build images
```

### Service Access

- **OpenMRS 3.0 SPA**: `http://localhost/openmrs/spa`
- **Legacy Admin UI**: `http://localhost/openmrs`
- **Default credentials**: `admin` / `Admin123`

---

## Environment Variable Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `TAG` | Docker image tag | `latest` or `latest-akram` |
| `RESTIC_REPOSITORY` | Backup repository path | `/backup` |
| `RESTIC_PASSWORD` | Backup encryption password | `your-secure-password` |
| `CRON_SCHEDULE` | Backup schedule | `0 2 * * *` |

See [Environment Variables](../deployment/environment-variables) for complete reference.
