---
layout: default
title: Testing
parent: Development
nav_order: 5
---

# Testing

Guide to testing PATH DRC EMR configurations and deployments.

---

## Overview

Testing ensures configuration changes work correctly and don't break existing functionality. This guide covers:

- Configuration validation
- Local testing
- Integration testing
- CI/CD testing

---

## Configuration Validation

### Running the Validator

The Initializer validator checks configuration files for errors:

```bash
mvn -P distro,validator clean verify
```

### What Gets Validated

| Type | Checks |
|------|--------|
| CSV files | Format, required columns, data types |
| JSON forms | Schema compliance, concept references |
| Concepts | UUID format, required fields |
| Locations | Parent references, tag validity |

### Common Validation Errors

**Missing concept reference:**
```
ERROR: Concept with UUID 'invalid-uuid' not found
```
Fix: Verify concept UUID exists in OCL or concepts.csv

**Invalid CSV format:**
```
ERROR: Column 'Name' is required but missing
```
Fix: Add required column to CSV file

**Duplicate UUID:**
```
ERROR: UUID 'xxx' is already used by another entity
```
Fix: Generate a new unique UUID

---

## Local Testing

### Quick Test Cycle

```bash
# 1. Make configuration changes

# 2. Validate configuration
mvn -P distro,validator clean verify

# 3. Rebuild backend
docker compose build backend

# 4. Restart services
docker compose up -d backend

# 5. Check logs
docker compose logs -f backend
```

### Full Test Cycle

For comprehensive testing:

```bash
# Stop and remove existing environment
docker compose down -v

# Build all images
docker compose build

# Start fresh
docker compose up -d

# Wait for startup
./wait-for-startup.sh

# Run tests...
```

### Wait for Startup Script

Create a helper script:

```bash
#!/bin/bash
# wait-for-startup.sh

echo "Waiting for OpenMRS to start..."
while [[ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost/openmrs/login.htm)" != "200" ]]; do
    echo "Still waiting..."
    sleep 10
done
echo "OpenMRS is ready!"
```

---

## Testing Specific Components

### Testing Forms

1. Create or modify form JSON
2. Rebuild and restart backend
3. Navigate to patient chart
4. Open the form
5. Verify fields render correctly
6. Submit test data
7. Verify data saves correctly

### Testing Concepts

1. Add concept to configuration
2. Rebuild and restart
3. Search for concept in admin UI
4. Verify concept details
5. Test concept in forms if applicable

### Testing Locations

1. Add location to configuration
2. Rebuild and restart
3. Verify location appears in location selector
4. Test location tags (login, visit, etc.)

### Testing Programs

1. Add program definition
2. Rebuild and restart
3. Enroll test patient in program
4. Verify workflow states work
5. Test program reports if applicable

---

## Integration Testing

### API Testing

Test REST API endpoints:

```bash
# Test authentication
curl -u admin:Admin123 \
  http://localhost/openmrs/ws/rest/v1/session

# Test patient search
curl -u admin:Admin123 \
  "http://localhost/openmrs/ws/rest/v1/patient?q=test"

# Test concept lookup
curl -u admin:Admin123 \
  "http://localhost/openmrs/ws/rest/v1/concept/concept-uuid"
```

### Database Verification

Verify data in database:

```bash
# Connect to database
docker compose exec db mysql -u openmrs -popenmrs openmrs

# Check concepts loaded
SELECT COUNT(*) FROM concept;

# Check locations
SELECT name FROM location WHERE retired = 0;

# Check forms
SELECT name, version FROM form WHERE retired = 0;
```

---

## Site-Specific Testing

### Building Site Distribution

```bash
# Build specific site
docker compose build backend \
  --build-arg BUILD_TYPE=site \
  --build-arg MVN_PROJECT=akram
```

### Testing Site Overrides

1. Verify base configuration loads
2. Verify site-specific overrides apply
3. Check site-specific content appears
4. Test site-specific workflows

---

## CI/CD Testing

### Pull Request Checks

PRs automatically run:

```yaml
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

### Manual CI Trigger

Trigger full build manually:

1. Go to Actions tab on GitHub
2. Select "Build and Publish Docker Images"
3. Click "Run workflow"
4. Select branch to build

---

## Debugging Test Failures

### Log Analysis

```bash
# View backend logs
docker compose logs backend

# Filter for errors
docker compose logs backend 2>&1 | grep -i error

# Watch logs in real-time
docker compose logs -f backend
```

### Common Issues

**Startup timeout:**
- Check database connectivity
- Verify sufficient resources
- Review Initializer logs

**Form not loading:**
- Check form JSON syntax
- Verify concept UUIDs
- Check browser console for errors

**Concept not found:**
- Verify concept is in OCL or concepts.csv
- Check UUID format
- Ensure OCL files are in correct location

### Initializer Logs

Check Initializer-specific logs:

```bash
docker compose logs backend 2>&1 | grep -i initializer
```

---

## Test Data

### Creating Test Patients

Use the registration form or API:

```bash
curl -X POST http://localhost/openmrs/ws/rest/v1/patient \
  -H "Content-Type: application/json" \
  -u admin:Admin123 \
  -d '{
    "person": {
      "names": [{"givenName": "Test", "familyName": "Patient"}],
      "gender": "M",
      "birthdate": "1990-01-01"
    },
    "identifiers": [{
      "identifier": "TEST001",
      "identifierType": "identifier-type-uuid",
      "location": "location-uuid"
    }]
  }'
```

### Cleanup Test Data

```bash
# Reset database (WARNING: destroys all data)
docker compose down -v
docker compose up -d
```

---

## Performance Testing

### Startup Time

Monitor startup duration:

```bash
time docker compose up -d
# Then wait for health check
time ./wait-for-startup.sh
```

### Resource Usage

Check resource consumption:

```bash
docker stats --no-stream
```

---

## Related

- [Local Development](local-development) - Development setup
- [CI/CD](ci-cd) - Automated pipelines
- [Troubleshooting](../reference/faq) - Common issues
