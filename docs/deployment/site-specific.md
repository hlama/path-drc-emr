---
layout: default
title: Site-Specific Builds
parent: Deployment
nav_order: 3
---

# Site-Specific Builds

Deploy PATH DRC EMR with pre-configured settings for specific facilities.

---

## Overview

Site-specific builds include pre-configured metadata and settings for particular healthcare facilities.

## Available Sites

### Akram (Centre Hospitalier Akram)
- Image tag: `latest-akram`
- Pre-configured location hierarchy

### Libikisi (Libikisi Health Facility)
- Image tag: `latest-libikisi`
- Pre-configured location hierarchy

---

## Using Site-Specific Images

### Building Locally

```bash
TAG=latest-libikisi docker compose build \
  --build-arg BUILD_TYPE=site \
  --build-arg MVN_PROJECT=libikisi
```

### Running

```bash
TAG=latest-libikisi docker compose up -d
```

---

## Creating New Sites

See [Adding Sites](../administration/adding-sites) for instructions on creating new site-specific builds.
