---
layout: default
title: Metadata Management
parent: Administration
nav_order: 2
---

# Metadata Management

Guide to managing metadata in PATH DRC EMR including concepts, locations, forms, and programs.

---

## Overview

PATH DRC EMR uses the OpenMRS Initializer module to load and manage metadata. Metadata is organized in content packages and loaded during system startup.

Key metadata types:
- **Concepts** - Clinical terminology and codes
- **Locations** - Facility hierarchy and service points
- **Forms** - Data collection forms
- **Programs** - Clinical program definitions
- **Roles & Privileges** - Access control

---

## Content Package Structure

Metadata is organized in content packages following the Initializer structure:

```
openmrs_config/
├── globalproperties/      # System settings
├── locations/             # Location hierarchy
├── locationtags/          # Location tags
├── concepts/              # Custom concepts
├── conceptsources/        # Concept source mappings
├── forms/                 # JSON form definitions
├── programs/              # Program definitions
├── programworkflows/      # Program workflows
├── roles/                 # Role definitions
├── privileges/            # Privilege definitions
├── patientidentifiertypes/# ID type definitions
├── drugs/                 # Drug catalog
├── orderfrequencies/      # Dosing frequencies
└── ocl/                   # Open Concept Lab exports
```

---

## Concepts

### Concept Sources

Concepts are loaded from multiple sources:

| Source | Description |
|--------|-------------|
| CIEL | Columbia International eHealth Laboratory concepts |
| OCL | Open Concept Lab exports |
| Custom | Site-specific concepts |

### Loading Concepts via OCL

OCL (Open Concept Lab) exports are placed in the `ocl/` directory:

```
openmrs_config/ocl/
├── openmrs_CIELImmunizationContent_v11_autoexpand-11.zip
└── openmrs_PD_v7_autoexpand-7.zip
```

These are automatically imported during startup.

### Custom Concepts

For custom concepts not in CIEL/OCL, create CSV files:

```csv
Uuid,Void/Retire,Fully specified name:en,Short name:en,Description:en,Data class,Data type,Answers
uuid-here,false,My Custom Concept,Custom,Description here,Misc,Text,
```

---

## Locations

### Location Hierarchy

Locations are defined in CSV format:

```csv
Uuid,Void/Retire,Name,Description,Parent,Tags
uuid-1,false,Main Hospital,Primary facility,,Login Location;Visit Location
uuid-2,false,OPD,Outpatient Department,Main Hospital,Visit Location
uuid-3,false,IPD,Inpatient Department,Main Hospital,Visit Location;Admission Location
```

### Location Tags

Location tags define capabilities:

| Tag | Purpose |
|-----|---------|
| Login Location | Where users can log in |
| Visit Location | Where visits can occur |
| Admission Location | Where patients can be admitted |
| Transfer Location | Valid for patient transfers |

### Adding Locations

1. Edit `locations/locations.csv`
2. Add new row with appropriate parent
3. Assign relevant tags
4. Restart services or use Initializer API

---

## Forms

### Form Definitions

Forms are defined in JSON following the OpenMRS 3.0 form schema:

```
openmrs_config/forms/
├── registration.json
├── vitals.json
├── consultation.json
└── ...
```

### Form Structure

```json
{
  "name": "Vitals",
  "version": "1.0",
  "published": true,
  "uuid": "form-uuid-here",
  "processor": "EncounterFormProcessor",
  "pages": [
    {
      "label": "Vitals",
      "sections": [
        {
          "label": "Vital Signs",
          "questions": [
            {
              "label": "Weight",
              "type": "obs",
              "id": "weight",
              "questionOptions": {
                "concept": "5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "rendering": "number"
              }
            }
          ]
        }
      ]
    }
  ]
}
```

### Form Best Practices

- Use CIEL concept UUIDs when available
- Version forms for tracking changes
- Test forms in development before production

---

## Programs

### Program Definitions

Programs are defined in CSV:

```csv
Uuid,Void/Retire,Name,Description,Concept
uuid-here,false,HIV Program,HIV care and treatment,concept-uuid
```

### Program Workflows

Workflows define states within programs:

```csv
Uuid,Void/Retire,Program,Concept,Name
uuid-here,false,HIV Program,workflow-concept-uuid,Treatment Status
```

### Program Workflow States

```csv
Uuid,Void/Retire,Workflow,Concept,Initial,Terminal
state-uuid,false,Treatment Status,on-treatment-concept,true,false
state-uuid-2,false,Treatment Status,completed-concept,false,true
```

---

## Roles and Privileges

### Role Definitions

Roles are defined in `roles/roles.csv`:

```csv
Uuid,Void/Retire,Role name,Description,Inherited roles,Privileges
uuid-here,false,Organizational: Doctor,Physician role,Provider,Get Patients;Edit Patients;...
```

### Adding Privileges to Roles

To persist role changes across deployments:

1. Edit the appropriate roles CSV file:
   - `roles_core-demo.csv` - Core organizational roles
   - `roles_stockmanagement.csv` - Stock management roles

2. Add or modify the privilege assignments

3. Commit changes to the content package

{: .note }
> Changes made through the admin UI are stored in the database but not persisted to configuration files. For permanent changes, update the CSV files.

---

## Patient Identifier Types

### Defining ID Types

```csv
Uuid,Void/Retire,Name,Description,Format,Required,Location behavior,Uniqueness behavior,Validator
uuid-here,false,OpenMRS ID,Primary ID,,[A-Z0-9]+,true,NOT_USED,UNIQUE,
```

### Auto-Generation

ID generation options are configured in `autogenerationoptions/`:

```csv
Uuid,Identifier type,Location,Identifier source,Manual entry enabled,Auto generation enabled
uuid-here,OpenMRS ID,,Sequential Generator,true,true
```

---

## Drugs

### Drug Catalog

Drugs are defined in `drugs/drugs.csv`:

```csv
Uuid,Void/Retire,Name,Description,Concept drug,Concept,Combination,Dosage form,Maximum daily dose,Minimum daily dose,Strength
uuid-here,false,Paracetamol 500mg,Acetaminophen tablet,paracetamol-concept-uuid,drug-concept-uuid,false,Tablet,4000,500,500mg
```

### Order Frequencies

Define dosing frequencies in `orderfrequencies/`:

```csv
Uuid,Void/Retire,Frequency per day,Concept
uuid-here,false,1,once-daily-concept
uuid-here-2,false,2,twice-daily-concept
```

---

## Making Changes

### Development Workflow

1. Make changes in the content package repository
2. Build and test locally
3. Create pull request
4. After merge, changes will be included in next build

### Immediate Changes (Database)

For urgent changes, use the Legacy Admin UI:

1. Navigate to **System Administration**
2. Make changes through the UI
3. Document the change for later inclusion in config files

{: .warning }
> Database changes are lost if you recreate volumes. Always add changes to configuration files for persistence.

### Initializer Reload

To reload configurations without restarting:

```bash
# Access the Initializer API
curl -X POST http://localhost/openmrs/ws/rest/v1/initializer/reload \
  -u admin:Admin123
```

---

## Validation

### Validate Configuration

The build process includes configuration validation:

```bash
mvn -P distro,validator clean verify
```

This checks:
- CSV format validity
- Concept references
- Location hierarchy integrity
- Form schema compliance

### Common Validation Errors

| Error | Cause | Solution |
|-------|-------|----------|
| Missing concept | Referenced concept doesn't exist | Add concept or fix UUID |
| Invalid parent | Location parent not found | Check location hierarchy |
| Duplicate UUID | Same UUID used twice | Generate new UUID |

---

## Backups

Metadata stored in configuration files is versioned in Git. Database-stored metadata should be backed up:

```bash
# Backup database
docker compose exec backup restic backup

# Export specific metadata
docker compose exec db mysqldump -u openmrs -popenmrs openmrs \
  --tables concept concept_name location > metadata_backup.sql
```

---

## Related

- [Adding Sites](adding-sites) - Site-specific metadata
- [Customization](customization) - Frontend customization
- [Initial Setup](../getting-started/initial-setup) - First-time setup
