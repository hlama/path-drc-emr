---
layout: default
title: Adding Sites
parent: Administration
nav_order: 1
---

# Adding Sites

Guide to creating site-specific distributions for PATH DRC EMR.

---

## Overview

PATH DRC EMR supports site-specific builds that allow each facility to have customized configurations while sharing a common base distribution. Current sites include:

- **akram** - Akram facility configuration
- **libikisi** - Libikisi facility configuration

Site-specific builds include:
- Custom location hierarchies
- Site-specific forms and workflows
- Tailored concept sets
- Custom branding (if needed)

---

## Architecture

```
path-drc-emr/
├── distro/                    # Base distribution (shared by all sites)
│   ├── pom.xml
│   └── distro.properties
├── sites/
│   ├── akram/                 # Akram site-specific
│   │   ├── pom.xml
│   │   ├── distro.properties
│   │   └── src/main/assembly/
│   └── libikisi/              # Libikisi site-specific
│       ├── pom.xml
│       ├── distro.properties
│       └── src/main/assembly/
└── pom.xml                    # Parent POM with site profiles
```

Site builds inherit from the base distribution and add site-specific content packages.

---

## Creating a New Site

### Step 1: Create Site Directory

```bash
mkdir -p sites/newsite/src/main/assembly
```

### Step 2: Create Site POM

Create `sites/newsite/pom.xml`:

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.path.drc.omrs</groupId>
    <artifactId>distro-emr</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <relativePath>../../</relativePath>
  </parent>

  <artifactId>distro-emr-configuration-newsite</artifactId>
  <name>DRC Distribution NewSite</name>
  <packaging>pom</packaging>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <distro.baseDir>${project.build.directory}/${project.artifactId}</distro.baseDir>
    <distro.openmrsConfigDir>${distro.baseDir}/openmrs_config</distro.openmrsConfigDir>
    <distro.openmrsCoreDir>${distro.baseDir}/openmrs_core</distro.openmrsCoreDir>
    <distro.openmrsModulesDir>${distro.baseDir}/openmrs_modules</distro.openmrsModulesDir>
    <distro.spaDir>${distro.baseDir}/spa</distro.spaDir>
    <distro.spaConfigDir>${distro.baseDir}/spa_config</distro.spaConfigDir>

    <path-drc-distro.version>${project.version}</path-drc-distro.version>
    <newsite-content.version>1.0.0-SNAPSHOT</newsite-content.version>
  </properties>

  <dependencies>
    <!-- Base distribution -->
    <dependency>
      <groupId>org.path.drc.omrs</groupId>
      <artifactId>distro-emr-configuration</artifactId>
      <version>${path-drc-distro.version}</version>
      <scope>provided</scope>
      <type>zip</type>
    </dependency>
    <!-- Site-specific content package -->
    <dependency>
      <groupId>org.openmrs.content</groupId>
      <artifactId>path.drc-newsite</artifactId>
      <version>${newsite-content.version}</version>
      <scope>provided</scope>
      <type>zip</type>
    </dependency>
  </dependencies>

  <build>
    <!-- Same build configuration as other sites -->
  </build>
</project>
```

### Step 3: Create distro.properties

Create `sites/newsite/distro.properties`:

```properties
name=PATH DRC EMR - NewSite
version=${project.version}

# Inherit from base distribution
war.openmrs=${openmrs-core.version}

# Include site-specific content
content.path.drc-newsite=${newsite-content.version}
```

### Step 4: Create Assembly Descriptor

Create `sites/newsite/src/main/assembly/assembly.xml`:

```xml
<assembly xmlns="http://maven.apache.org/ASSEMBLY/2.1.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/ASSEMBLY/2.1.0
                              http://maven.apache.org/xsd/assembly-2.1.0.xsd">
  <id>distro</id>
  <formats>
    <format>zip</format>
  </formats>
  <includeBaseDirectory>false</includeBaseDirectory>
  <fileSets>
    <fileSet>
      <directory>${project.build.directory}/sdk-distro/web</directory>
      <outputDirectory>/</outputDirectory>
    </fileSet>
  </fileSets>
</assembly>
```

### Step 5: Add Profile to Parent POM

Add the new site profile to the root `pom.xml`:

```xml
<profile>
  <id>newsite</id>
  <modules>
    <module>sites/newsite</module>
  </modules>
</profile>
```

### Step 6: Update CI/CD Workflow

Add the new site to `.github/workflows/build-and-release.yml`:

```yaml
# In the paths-filter section
newsite:
  - *common
  - ./sites/newsite/**
```

---

## Site Content Package

Each site typically has an associated content package hosted on GitHub Packages. This content package contains:

- Location hierarchy definitions
- Forms specific to the site
- Concept sets and mappings
- Program workflows
- Global properties

### Content Package Structure

```
openmrs-content-path-drc-newsite/
├── configuration/
│   ├── globalproperties/
│   ├── locations/
│   ├── concepts/
│   ├── forms/
│   └── programs/
└── pom.xml
```

See the [openmrs-content-path-drc](https://github.com/path-drc/openmrs-content-path-drc) repository for examples.

---

## Building Site-Specific Images

### Local Build

```bash
# Build the site
docker compose build --build-arg BUILD_TYPE=site --build-arg MVN_PROJECT=newsite

# Run
docker compose up -d
```

### Using Pre-Built Images

Site-specific images are tagged with the site name:

```bash
# Pull site-specific images
TAG=latest-newsite docker compose pull

# Run with site tag
TAG=latest-newsite docker compose up -d
```

---

## Deploying a Site

### Environment Configuration

Set the appropriate tag in `.env`:

```bash
TAG=latest-newsite
```

### Site-Specific Bundles

For offline installation, site-specific bundles are generated:

- `path-drc-emr-images-bundle-newsite.tgz`
- `path-drc-docker-compose-newsite.tgz`

These are available from [GitHub Releases](https://github.com/path-drc/path-drc-emr/releases).

---

## Best Practices

### Keep Base Configuration Shared

- Put common configurations in the base `distro/` directory
- Only add site-specific overrides in `sites/sitename/`

### Version Content Packages

- Use semantic versioning for content packages
- Test content package updates before deployment

### Test Before Deployment

```bash
# Build and test locally
docker compose build --build-arg BUILD_TYPE=site --build-arg MVN_PROJECT=newsite
docker compose up -d
# Verify functionality
```

### Document Site Differences

- Maintain documentation of what's unique to each site
- Document any site-specific workflows or forms

---

## Troubleshooting

### Build Fails for New Site

**Check Maven settings:**
```bash
mvn -P newsite clean verify
```

**Verify content package is available:**
```bash
mvn dependency:resolve -P newsite
```

### Site Images Not Found

Ensure the site is added to the CI/CD workflow and has been built:

```bash
docker pull ghcr.io/path-drc/path-drc-emr-backend:latest-newsite
```

### Content Not Loading

Check that the site's content package includes the correct location hierarchy and that all dependencies are properly configured.

---

## Related

- [Site-Specific Builds](../deployment/site-specific) - Deployment guide
- [Build Process](../architecture/build-process) - Technical details
