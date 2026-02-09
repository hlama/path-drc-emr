---
layout: default
title: CI/CD
parent: Development
nav_order: 3
---

# CI/CD

Continuous Integration and Deployment for PATH DRC EMR.

---

## Overview

PATH DRC EMR uses GitHub Actions for automated builds, testing, and releases. The CI/CD pipeline:

- Validates configuration on pull requests
- Builds and publishes Docker images on merge
- Creates releases with air-gapped bundles on tags

---

## Workflows

### build-test.yml

**Trigger:** Pull requests to main

**Purpose:** Validate changes before merge

```yaml
name: Build and Validate Configuration

on:
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          java-version: '8'
      - name: Build and Test
        run: mvn --batch-mode --activate-profiles distro,validator clean verify
```

**What it checks:**
- Maven build succeeds
- Configuration validation passes
- No syntax errors in Initializer files

### build-and-release.yml

**Trigger:** Push to main, tags, manual dispatch

**Purpose:** Build and publish Docker images

**Jobs:**

1. **get-changed-distributions** - Detect what changed
2. **build-and-release-base** - Build base distribution
3. **build-and-release-sites** - Build site-specific distributions

---

## Change Detection

The workflow uses paths-filter to only build what changed:

```yaml
filters: |
  common: &common
    - ./.github/workflows/build-and-release.yml
    - ./distro/**
    - ./frontend/**
    - ./gateway/**
    - pom.xml
    - Dockerfile
  base:
    - *common
  akram:
    - *common
    - ./sites/akram/**
  libikisi:
    - *common
    - ./sites/libikisi/**
```

This means:
- Changes to `distro/` trigger base and all site builds
- Changes to `sites/akram/` only trigger akram build
- Workflow changes trigger all builds

---

## Build Process

### Base Distribution Build

```yaml
steps:
  - name: Build and push gateway image
    uses: docker/build-push-action@v6
    with:
      context: ./gateway
      platforms: linux/amd64,linux/arm64
      push: true
      tags: |
        ghcr.io/.../gateway:${{ steps.vars.outputs.SHORT_SHA }}
        ghcr.io/.../gateway:latest
        ghcr.io/.../gateway:${{ env.RELEASE_VERSION }}

  - name: Build and push frontend image
    # Similar to gateway

  - name: Build and push backend image
    uses: docker/build-push-action@v6
    with:
      context: .
      secret-files: |
        m2settings=/home/runner/.m2/settings.xml
      build-args: |
        MVN_ARGS=deploy
      tags: |
        ghcr.io/.../backend:latest
```

### Site-Specific Build

```yaml
- name: Build and push backend image
  uses: docker/build-push-action@v6
  with:
    build-args: |
      BUILD_TYPE=site
      MVN_PROJECT=${{ matrix.site }}
      MVN_ARGS=deploy
    tags: |
      ghcr.io/.../backend:latest-${{ matrix.site }}
```

---

## Air-Gapped Bundle Creation

### Process

1. Pull all required images
2. Use docker-compose-air-gapper to create bundle
3. Upload as artifact
4. Attach to release (for tags)

```yaml
- name: Build senzing/docker-compose-air-gapper
  run: |
    docker build -t senzing/docker-compose-air-gapper \
      https://github.com/senzing-garage/docker-compose-air-gapper.git#1.0.7

- name: Generate save-images.sh
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/data \
      -e SENZING_DOCKER_COMPOSE_FILE=/data/docker-compose-normalized.yaml \
      -e SENZING_OUTPUT_FILE=/data/save-images.sh \
      senzing/docker-compose-air-gapper:latest

- name: Save images as tars
  run: ./save-images.sh

- name: Package bundle
  run: |
    mv /home/runner/docker-compose-air-gapper-*.tgz \
      path-drc-emr-images-bundle.tgz
```

---

## Releases

### Creating a Release

1. Create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. Workflow automatically:
   - Builds all images with version tag
   - Creates air-gapped bundles
   - Creates GitHub release with bundles attached

### Release Artifacts

- `path-drc-emr-images-bundle.tgz` - Base images
- `path-drc-emr-images-bundle-akram.tgz` - Akram site images
- `path-drc-emr-images-bundle-libikisi.tgz` - Libikisi site images
- `path-drc-docker-compose.tgz` - Docker Compose files

---

## Secrets and Permissions

### Required Permissions

```yaml
permissions:
  contents: write   # For creating releases
  packages: write   # For pushing images
```

### Secrets Used

| Secret | Purpose |
|--------|---------|
| `GITHUB_TOKEN` | Auto-provided, used for registry auth and releases |

### Maven Authentication

Maven settings are configured for GitHub Packages:

```yaml
- uses: s4u/maven-settings-action@v3.1.0
  with:
    servers: |
      [{
        "id": "path-drc",
        "username": "${{ github.actor }}",
        "password": "${{ secrets.GITHUB_TOKEN }}"
      }]
```

---

## Caching

### Docker Layer Cache

Images use registry-based caching:

```yaml
cache-to: |
  type=registry,ref=ghcr.io/.../backend:latest-cache
cache-from: |
  type=registry,ref=ghcr.io/.../backend:latest-cache
```

### Maven Cache

```yaml
- uses: actions/setup-java@v4
  with:
    cache: 'maven'
```

---

## Multi-Platform Builds

All images are built for both AMD64 and ARM64:

```yaml
- name: Set up QEMU
  uses: docker/setup-qemu-action@v3

- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    platforms: linux/amd64,linux/arm64
```

---

## Manual Dispatch

Trigger builds manually from GitHub UI:

1. Go to Actions tab
2. Select "Build and Publish Docker Images"
3. Click "Run workflow"
4. Select branch

Manual dispatch builds all distributions regardless of changes.

---

## Troubleshooting

### Build Fails

**Check logs in GitHub Actions:**
1. Go to Actions tab
2. Click on failed run
3. Expand failed step

**Common issues:**
- Maven dependency not found - Check GitHub Packages availability
- Docker push fails - Check permissions
- Out of disk space - Check runner resources

### Images Not Updated

**Check if workflow ran:**
- Verify push triggered workflow
- Check paths-filter detected changes

**Force rebuild:**
- Use manual dispatch to rebuild all

### Release Not Created

**Check tag format:**
- Tags should match expected format
- Workflow must be configured for tag triggers

---

## Documentation Workflow

### docs.yml

Builds and deploys documentation to GitHub Pages:

```yaml
name: Deploy Documentation

on:
  push:
    branches: [main]
    paths:
      - 'docs/**'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          working-directory: docs
      - name: Build with Jekyll
        run: bundle exec jekyll build
        working-directory: docs
```

---

## Related

- [Building Images](building-images) - Image build details
- [Local Development](local-development) - Development setup
- [Contributing](contributing) - Contribution guidelines
