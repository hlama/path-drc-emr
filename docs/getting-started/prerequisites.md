---
layout: default
title: Prerequisites
parent: Getting Started
nav_order: 1
---

# Prerequisites

Before installing PATH DRC EMR, ensure your system meets the following requirements.

---

## Hardware Requirements

We recommend selecting your hardware based on real-world needs, such as the number of concurrent users or expected patient records.

{: .warning }
> These specifications assume a bare metal installation of the OS. Running OpenMRS as a VM on a Windows computer for any production use is **NOT** recommended.

### Minimum Requirements (1-10 Users)

| Resource | Requirement |
|----------|-------------|
| CPU | Quad-core or higher desktop-class processor |
| RAM | 8 GB |
| Disk Space | 100+ GB HDD |
| Network | Internet connectivity (for online installation) |

### Recommended Requirements (10+ Users)

| Resource | Requirement |
|----------|-------------|
| CPU | 8 cores or higher |
| RAM | 16 GB |
| Disk Space | 100+ GB in RAID configuration |
| Backup | Dedicated backup facilities |

### Cloud Requirements (AWS)

| Usage | Instance Type | Notes |
|-------|---------------|-------|
| Minimum (1-10 users) | EC2 t3.medium | Basic deployment |
| Recommended (10+ users) | EC2 t3.large or higher | 8GB RAM, more processors |

{: .note }
> Scale up based on number of concurrent users. For high-traffic facilities, consider t3.xlarge or dedicated instances.

---

## Software Requirements

### Required Software

**Docker**
- Version: 20.10 or newer
- Installation: [docs.docker.com/engine/install](https://docs.docker.com/engine/install/)

**Docker Compose**
- Version: 2.0 or newer
- Typically included with Docker Desktop
- Linux: Install separately following [docs.docker.com/compose/install](https://docs.docker.com/compose/install/)

### Operating System

**Supported:**
- Ubuntu 20.04 LTS or newer
- Debian 11 or newer
- RHEL/CentOS 8 or newer
- Other modern Linux distributions with Docker support

{: .warning }
> Windows is not recommended for production deployments. Use Linux for all production installations.

---

## Network Requirements

### For Online Installation

- **Stable internet connectivity** required
- **Outbound HTTPS (443)** access to:
  - `ghcr.io` (GitHub Container Registry)
  - `github.com` (for downloading files)

### For Offline Installation

- No internet required on target system
- Download on internet-connected machine, transfer via USB or local network
- See [Offline Installation](../deployment/offline-installation) for details

---

## Access Requirements

### GitHub Personal Access Token

For online installation, you need a GitHub Personal Access Token (classic) with `read:packages` scope:

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Give it a descriptive name (e.g., "PATH DRC EMR deployment")
4. Select scope: `read:packages`
5. Click **Generate token**
6. **Copy the token immediately** (you won't see it again)

{: .note }
> The token is used for both Docker image pulls and Maven builds. Keep it secure.

### System Access

- Root or sudo access on the target system
- Ability to run Docker commands

---

## Verification Commands

Before proceeding with installation, verify your system is ready:

### Check Docker

```bash
# Verify Docker is installed
docker --version
# Expected: Docker version 20.10.x or newer

# Verify Docker is running
sudo systemctl status docker

# Verify you can run Docker commands
docker run hello-world
```

### Check Docker Compose

```bash
# Verify Docker Compose
docker compose version
# Expected: Docker Compose version v2.x.x or newer
```

### Check System Resources

```bash
# Check available disk space (need 100+ GB)
df -h

# Check available memory (need 8+ GB)
free -h

# Check CPU cores
nproc
```

### Check Network (Online Installation)

```bash
# Test connectivity to GitHub Container Registry
curl -I https://ghcr.io

# Test connectivity to GitHub
curl -I https://github.com
```

---

## Verification Checklist

Before proceeding with installation, verify:

- [ ] Server/VM meets minimum hardware requirements (quad-core, 8GB RAM, 100GB disk)
- [ ] Operating system is Linux-based (Ubuntu, Debian, RHEL, etc.)
- [ ] Docker is installed and running: `docker --version`
- [ ] Docker Compose is installed: `docker compose version`
- [ ] Sufficient disk space available: `df -h`
- [ ] Network connectivity as required for installation type
- [ ] GitHub Personal Access Token created (online installation only)
- [ ] Root or sudo access available

---

## Installation Options

Once prerequisites are met, choose your installation method:

| Method | Use Case | Requirements |
|--------|----------|--------------|
| [Quick Start](quick-start) | Testing and evaluation | Internet access |
| [Online Installation](../deployment/online-installation) | Production with internet | Stable internet |
| [Offline Installation](../deployment/offline-installation) | Air-gapped environments | Pre-downloaded bundle |

---

## Next Steps

- **Quick evaluation?** → [Quick Start](quick-start)
- **Production deployment with internet?** → [Online Installation](../deployment/online-installation)
- **Air-gapped environment?** → [Offline Installation](../deployment/offline-installation)
