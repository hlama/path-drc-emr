---
layout: default
title: Architecture
nav_order: 6
has_children: true
permalink: /architecture
---

# Architecture

This section provides a comprehensive overview of PATH DRC EMR's technical architecture.

## System Overview

PATH DRC EMR is a containerized OpenMRS 3.0 distribution consisting of five main components orchestrated with Docker Compose.

```mermaid
graph TB
    Client[Web Browser] -->|HTTP/HTTPS| Gateway[Gateway<br/>nginx:1.25<br/>Reverse Proxy]
    Gateway -->|/openmrs/spa/*| Frontend[Frontend<br/>nginx:1.25<br/>O3 SPA Bundle]
    Gateway -->|/openmrs/| Backend[Backend<br/>OpenMRS Core 2.7<br/>+ Modules]
    Backend -->|JDBC| DB[(MariaDB 10.11<br/>Database)]
    Backup[Backup Service<br/>Restic] -.->|Scheduled| DB
    Backup -.->|Volume Backup| Backend

    style Client fill:#e1f5ff
    style Gateway fill:#fff4e6
    style Frontend fill:#e8f5e9
    style Backend fill:#e8f5e9
    style DB fill:#fce4ec
    style Backup fill:#f3e5f5
```

---

## Components

### Gateway (nginx)
Reverse proxy routing requests to frontend or backend services. Handles CORS and provides a single entry point.

### Frontend (nginx + O3 SPA)
Serves the OpenMRS 3.0 Single Page Application with pre-built frontend modules.

### Backend (OpenMRS)
OpenMRS server providing the REST API, business logic, and data persistence.

### Database (MariaDB)
Persistent data storage for OpenMRS.

### Backup (Restic)
Automated backup service for data protection.

---

## What's in This Section

- **[Docker Images](docker-images)**: Details of each image
- **[Build Process](build-process)**: How images are built
- **[Gateway](gateway)**: Gateway configuration and routing
- **[Data Model](data-model)**: Data persistence and volumes

---

## Build Architecture

PATH DRC EMR supports two build types:

```mermaid
graph LR
    A[Source Code] --> B[Maven Build]
    B --> C{Build Type}
    C -->|distro| D[Base Distro<br/>:latest]
    C -->|site| E[Site-Specific<br/>:latest-sitename]

    style D fill:#e8f5e9
    style E fill:#e1f5fe
```

---

## Data Persistence

Docker volumes used for data persistence:

| Volume | Purpose | Backed Up |
|--------|---------|-----------|
| `db-data` | MariaDB database files | Yes |
| `openmrs-data` | OpenMRS application data | Yes |
| `openmrs-config-checksums` | Initializer state | Yes |
| `openmrs-person-images` | Patient photos | Yes |
| `openmrs-complex-obs` | Complex observation data | Yes |
| `restic-cache` | Backup cache | No |
