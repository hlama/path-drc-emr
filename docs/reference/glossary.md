---
layout: default
title: Glossary
parent: Reference
nav_order: 2
---

# Glossary

Terms and definitions used in PATH DRC EMR documentation.

---

## A

### Address Hierarchy
A hierarchical structure of geographic locations (country, province, district, etc.) used for patient address entry with cascading dropdowns.

### Air-Gapped
A network security measure where a computer or network is physically isolated from unsecured networks. PATH DRC EMR supports air-gapped installation via Docker image bundles.

---

## B

### Backend
The OpenMRS server component that handles business logic, data storage, and REST APIs. Runs on Tomcat with Java.

### BuildKit
Docker's modern build engine that provides improved caching, parallel builds, and secret handling.

---

## C

### CIEL
Columbia International eHealth Laboratory - a comprehensive medical terminology dictionary used as the primary concept source in OpenMRS implementations.

### Concept
A clinical or administrative term in OpenMRS. Concepts define observations, diagnoses, procedures, and other medical data elements.

### Concept Source
An external terminology system (like CIEL, ICD-10, or SNOMED) that provides standardized concept definitions.

### Content Package
A collection of configuration files (concepts, forms, locations, etc.) that define clinical content for an OpenMRS implementation.

---

## D

### Distribution
A configured OpenMRS package that includes the core platform, modules, and content packages. PATH DRC EMR is a distribution.

### Docker
A platform for developing, shipping, and running applications in containers. PATH DRC EMR runs as Docker containers.

### Docker Compose
A tool for defining and running multi-container Docker applications using a YAML configuration file.

---

## E

### Encounter
A clinical interaction between a patient and healthcare provider(s) at a specific time and location.

### Encounter Type
A classification of encounters (e.g., Registration, Vitals, Consultation) that determines what data can be collected.

### ESM (Extensible Single-Page Module)
The architecture for OpenMRS 3.0 frontend modules built with React and the carbon design system.

---

## F

### Form
A data collection interface used to record clinical information. In OpenMRS 3.0, forms are defined as JSON schemas.

### Frontend
The user interface component of OpenMRS 3.0, built as a Single Page Application (SPA) using React.

---

## G

### Gateway
The nginx reverse proxy that routes requests between the frontend and backend services.

### Global Property
A system-wide configuration setting stored in the OpenMRS database.

### GHCR (GitHub Container Registry)
GitHub's container image registry where PATH DRC EMR Docker images are published.

---

## I

### Identifier Type
A classification for patient IDs (e.g., Medical Record Number, National ID) with validation rules.

### Initializer
An OpenMRS module that loads configuration from files (CSV, JSON, XML) during system startup.

---

## L

### Legacy UI
The traditional OpenMRS user interface based on Spring MVC. Used for some administrative functions.

### Location
A place where clinical services are provided (hospital, clinic, ward, room).

### Location Tag
A label that defines capabilities of a location (Login Location, Visit Location, Admission Location).

---

## M

### MariaDB
The open-source relational database used by PATH DRC EMR (compatible with MySQL).

### Maven
A build automation tool used for Java projects. PATH DRC EMR uses Maven to build distributions.

### Module
A pluggable component that extends OpenMRS functionality (e.g., reporting, billing, laboratory).

---

## N

### nginx
A high-performance web server used as the gateway/reverse proxy in PATH DRC EMR.

---

## O

### O3 (OpenMRS 3.0)
The current generation of OpenMRS with a modern React-based frontend and microfrontend architecture.

### Observation (Obs)
A single piece of clinical data recorded about a patient (e.g., weight, diagnosis, test result).

### OCL (Open Concept Lab)
A cloud-based platform for collaborative concept management. PATH DRC EMR imports concepts from OCL.

### OpenMRS
An open-source electronic medical record platform designed for resource-constrained environments.

---

## P

### Patient Identifier
A unique code used to identify a patient (e.g., medical record number).

### Person Attribute
Additional demographic or administrative data about a person (e.g., phone number, occupation).

### Program
A structured clinical program (e.g., HIV care, TB treatment) with defined workflows and states.

### Provider
A person or organization that provides clinical services. Linked to user accounts for clinical documentation.

---

## R

### Restic
A backup program used by PATH DRC EMR for automated data backups.

### REST API
The web service interface for programmatic access to OpenMRS data.

### Role
A named collection of privileges that can be assigned to users.

---

## S

### SPA (Single Page Application)
A web application that loads a single HTML page and dynamically updates content. OpenMRS 3.0 uses this architecture.

### Site
A specific deployment location with customized configuration (e.g., akram, libikisi).

---

## T

### Tomcat
The Java application server that runs the OpenMRS backend.

---

## U

### UUID (Universally Unique Identifier)
A 36-character identifier used to uniquely identify records across systems.

---

## V

### Visit
A period of time when a patient is receiving care at a location. Contains one or more encounters.

### Visit Type
A classification of visits (e.g., Outpatient, Inpatient).

### Volume (Docker)
A persistent storage mechanism for Docker containers. PATH DRC EMR uses volumes for database and file storage.

---

## W

### Workflow
A sequence of states within a program that a patient progresses through (e.g., Pre-treatment → On Treatment → Completed).

### Workflow State
A specific status within a workflow (e.g., "On Treatment", "Lost to Follow-up").
