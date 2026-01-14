---
layout: default
title: Administration
nav_order: 5
has_children: true
permalink: /administration
---

# Administration

This section covers advanced configuration, customization, and administration of PATH DRC EMR for site administrators.

## Overview

Site administrators are responsible for configuring PATH DRC EMR for specific facilities, managing metadata, and customizing the system to meet local requirements.

## Administrator vs Operator

**Operators** focus on:
- Running and monitoring the system
- User management
- Backups and restores
- Troubleshooting issues

**Administrators** additionally handle:
- Adding new sites/facilities
- Customizing metadata
- Modifying system configuration
- Managing content packages
- Branding and customization

---

## What's in This Section

### [Adding Sites](adding-sites)
Create new site configurations, set up site-specific builds, configure location hierarchies.

### [Metadata Management](metadata-management)
Work with content packages, use the Initializer module, deploy metadata changes.

### [Customization](customization)
Customize the frontend interface, configure modules, apply branding.

---

## Site-Specific Builds

PATH DRC EMR supports site-specific builds with pre-configured metadata:

**Akram** (Centre Hospitalier Akram)
- Image tag: `latest-akram`
- Pre-configured location hierarchy

**Libikisi** (Libikisi Health Facility)
- Image tag: `latest-libikisi`
- Pre-configured location hierarchy

See [Adding Sites](adding-sites) for creating new site-specific builds.

---

## Content Package

PATH DRC EMR uses the [openmrs-content-path-drc](https://github.com/path-drc/openmrs-content-path-drc) content package for metadata management.

See [Metadata Management](metadata-management) for details.
