---
layout: default
title: Getting Started
nav_order: 2
has_children: true
permalink: /getting-started
---

# Getting Started

This section will help you get PATH DRC EMR up and running for the first time.

## Overview

PATH DRC EMR can be deployed in different ways depending on your needs:
- **Quick Start**: For testing and evaluation (requires internet)
- **Online Installation**: For production deployment with internet connectivity
- **Offline Installation**: For air-gapped environments without internet

## Prerequisites

Before you begin, ensure you have:
- A Linux server or virtual machine (Ubuntu 20.04+ recommended)
- Docker and Docker Compose installed
- Sufficient hardware resources (see [Prerequisites](prerequisites))
- GitHub account with access token (for online installations)

## What's in This Section

- **[Prerequisites](prerequisites)**: Hardware, software, and network requirements
- **[Quick Start](quick-start)**: Fastest path to running the system (for testing)
- **[Initial Setup](initial-setup)**: First-time configuration after installation

## Decision Guide

**I want to test/evaluate PATH DRC EMR**
: Follow the [Quick Start](quick-start) guide

**I'm deploying for production use**
: Check [Prerequisites](prerequisites) first, then choose [Online](../deployment/online-installation) or [Offline](../deployment/offline-installation) installation

**I need to configure a specific site**
: See [Site-Specific Builds](../deployment/site-specific)

---

## Next Steps

Once you've reviewed the prerequisites, continue to:
- [Quick Start](quick-start) for immediate testing
- [Deployment Guide](../deployment/) for production installation
