---
layout: default
title: Customization
parent: Administration
nav_order: 3
---

# Customization

Guide to customizing PATH DRC EMR frontend and backend behavior.

---

## Overview

PATH DRC EMR can be customized at multiple levels:

- **Frontend configuration** - UI appearance and behavior
- **Backend properties** - System settings and features
- **Branding** - Logo, colors, and themes
- **Extensions** - Additional functionality

---

## Frontend Configuration

### SPA Configuration

The OpenMRS 3.0 frontend is configured via `config.json`:

```
frontend/config/config.json
```

### Configuration Schema

```json
{
  "@openmrs/esm-patient-chart-app": {
    "visitDiagnosesConceptUuid": "concept-uuid",
    "offlineVisitTypeUuid": "visit-type-uuid"
  },
  "@openmrs/esm-patient-registration-app": {
    "fieldConfigurations": {
      "name": {
        "displayMiddleName": true,
        "displayCapturePhoto": true
      }
    }
  }
}
```

### Common Frontend Settings

| Module | Setting | Description |
|--------|---------|-------------|
| `esm-patient-registration-app` | `fieldConfigurations` | Registration form fields |
| `esm-patient-chart-app` | `visitDiagnosesConceptUuid` | Diagnosis concept |
| `esm-home-app` | `buttons` | Home page quick actions |

---

## Backend Global Properties

### Setting Global Properties

Global properties are defined in `globalproperties/` XML files:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<globalProperties>
  <globalProperty>
    <property>locale.allowed.list</property>
    <value>en, fr</value>
    <description>Allowed locales</description>
  </globalProperty>
</globalProperties>
```

### Key Global Properties

| Property | Description | Example |
|----------|-------------|---------|
| `locale.allowed.list` | Supported languages | `en, fr` |
| `default_locale` | Default language | `fr` |
| `patient.identifier.regex` | ID format validation | `[A-Z0-9]+` |
| `visits.autoCloseVisitTimeout` | Visit auto-close hours | `24` |

### Changing Properties at Runtime

```bash
# Via Legacy Admin UI
# Administration → Maintenance → Settings

# Via REST API
curl -X POST http://localhost/openmrs/ws/rest/v1/systemsetting/property.name \
  -H "Content-Type: application/json" \
  -u admin:Admin123 \
  -d '{"value": "new-value"}'
```

---

## Branding

### Logo

The billing logo is included in the Docker image:

```
frontend/assets/logo.png
```

To customize:
1. Replace `frontend/assets/logo.png` with your logo
2. Rebuild the frontend image

### Colors and Theme

Theme customization is done via frontend configuration:

```json
{
  "@openmrs/esm-styleguide": {
    "Brand color #1": "#005d5d",
    "Brand color #2": "#007d79"
  }
}
```

---

## Internationalization (i18n)

### Supported Languages

PATH DRC EMR supports:
- English (en)
- French (fr)

### Adding Translations

Frontend translations are managed in the frontend modules. Backend translations are in message bundles.

### Locale Configuration

```xml
<globalProperty>
  <property>locale.allowed.list</property>
  <value>en, fr</value>
</globalProperty>
<globalProperty>
  <property>default_locale</property>
  <value>fr</value>
</globalProperty>
```

---

## Feature Toggles

### Enabling/Disabling Features

Features can be toggled via configuration:

```json
{
  "@openmrs/esm-appointments-app": {
    "enabled": true
  },
  "@openmrs/esm-dispensing-app": {
    "enabled": false
  }
}
```

### Module-Level Control

Disable modules by not including them in the distribution or by retiring them in the admin UI.

---

## Service Queues

### Queue Configuration

Service queues are configured via global properties:

```xml
<globalProperty>
  <property>queue.service.concepts</property>
  <value>concept-uuid-1,concept-uuid-2</value>
</globalProperty>
```

### Queue Types

| Queue Type | Use Case |
|------------|----------|
| Triage | Initial patient assessment |
| Consultation | Doctor consultations |
| Lab | Laboratory services |
| Pharmacy | Medication dispensing |

---

## Billing Configuration

### Payment Modes

Payment modes are defined in `paymentmodes/`:

```csv
Uuid,Void/Retire,Name,Description,Sort order
uuid-1,false,Cash,Cash payment,1
uuid-2,false,Insurance,Insurance payment,2
```

### Billable Items

Configure billable services and items through the billing module configuration.

---

## Address Hierarchy

### Address Template

Define address fields in `address-template.xml`:

```xml
<org.openmrs.layout.address.AddressTemplate>
  <nameMappings>
    <entry>
      <string>stateProvince</string>
      <string>Province</string>
    </entry>
    <entry>
      <string>countyDistrict</string>
      <string>District</string>
    </entry>
  </nameMappings>
  <elementDefaults>
    <entry>
      <string>country</string>
      <string>DRC</string>
    </entry>
  </elementDefaults>
</org.openmrs.layout.address.AddressTemplate>
```

### Address Hierarchy Data

Address hierarchy entries are loaded via the Address Hierarchy module from CSV files.

---

## Making Changes Persistent

### Configuration Files (Recommended)

For changes that should persist across deployments:

1. Modify files in the content package
2. Rebuild and redeploy

### Database Changes

For immediate changes via Admin UI:

1. Make changes in Legacy Admin
2. Document changes
3. Add to configuration files later

{: .warning }
> Database-only changes are lost when volumes are recreated. Always back up and document changes.

---

## Testing Customizations

### Local Testing

```bash
# Build with changes
docker compose build

# Start services
docker compose up -d

# Verify changes
docker compose logs -f backend
```

### Configuration Validation

```bash
# Validate Initializer configurations
mvn -P distro,validator clean verify
```

---

## Related

- [Metadata Management](metadata-management) - Concepts, locations, forms
- [Adding Sites](adding-sites) - Site-specific customization
- [Environment Variables](../deployment/environment-variables) - Runtime configuration
