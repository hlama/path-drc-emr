---
layout: default
title: Initial Setup
parent: Getting Started
nav_order: 3
---

# Initial Setup

Complete the initial configuration after installing PATH DRC EMR.

---

## Overview

After installation, you need to complete several configuration steps before the system is ready for use:

1. Change the default admin password
2. Configure the admin user as a provider
3. Create user accounts for staff
4. Verify metadata loaded correctly
5. Configure backups

---

## Step 1: Change Default Password

{: .warning }
> **Critical Security Step**: Change the default admin password immediately!

1. Log in with default credentials:
   - **Username**: `admin`
   - **Password**: `Admin123`
2. Navigate to your user settings
3. Change to a strong, unique password
4. Log out and log back in to verify

---

## Step 2: Configure Admin User as Provider

By default, only the admin user account is created. However, the admin user is **not immediately available to test all clinical features** because it lacks a provider account.

To enable full functionality for the admin user:

1. Log in as admin (`admin` / `Admin123`)
2. Click on **App Menu** (top-right hamburger menu)
3. Click **System Administration**
4. Go to **Manage Users**
5. Search for "admin" and click on the result
6. Check the box **Create a Provider account for this user**
7. Scroll down and click **Save User**

{: .note }
> Any user who needs to record clinical encounters (visits, observations, orders) must have a provider account.

---

## Step 3: Create User Accounts

Create accounts for clinical and administrative staff based on their roles.

### Creating a Role-Based Account

For example, to create a doctor account:

1. Click **App Menu** → **System Administration**
2. Go to **Manage Users**
3. Click **Add User**
4. Under **Create a new person**, click **Next**
5. Enter required details:
   - **Given Name**: First name
   - **Family Name**: Last name
   - **Gender**: Select appropriate option
   - **Username**: Login name (lowercase, no spaces)
   - **Password**: Initial password (user should change on first login)
6. Check **Create a Provider account for this user** (required for clinical functions)
7. Under **Roles**, select the appropriate organizational role:
   - **Organizational: Doctor** - For physicians
   - **Organizational: Nurse** - For nursing staff
   - **Organizational: Registration Clerk** - For front desk staff
8. Click **Save User**

### Common Roles

| Role | Description | Typical Users |
|------|-------------|---------------|
| Organizational: Doctor | Full clinical privileges for physicians | Doctors, clinical officers |
| Organizational: Nurse | Clinical privileges for nursing care | Nurses, nursing assistants |
| Organizational: Registration Clerk | Patient registration only | Front desk staff |
| System Developer | Full system access | IT administrators only |

{: .warning }
> Assign only the minimum roles needed. Avoid giving **System Developer** to non-technical users as it grants full system access.

---

## Step 4: Customize Role Privileges

If the existing roles don't meet your needs, you can modify them:

1. Click **App Menu** → **System Administration**
2. Click **Manage Roles** under the Users section
3. Click on the role you want to modify (e.g., Organizational: Doctor)
4. Check or uncheck privileges as needed
5. Click **Save Role**

{: .note }
> To persist role changes across all deployments, update the configuration file at [roles_core-demo.csv](https://github.com/path-drc/openmrs-content-path-drc/blob/main/configuration/backend_configuration/roles/roles_core-demo.csv) in the content package repository.

---

## Step 5: Verify Metadata Loading

Confirm that metadata has loaded correctly:

### Check Locations

1. Go to **System Administration** → **Manage Locations**
2. Verify location hierarchy is present

### Check Concepts

1. Go to **System Administration** → **Manage Concept**
2. Search for common concepts (e.g., "weight", "temperature")
3. Verify concepts exist and have appropriate attributes

### Test Patient Registration

1. Navigate to the OpenMRS 3.0 interface: `http://your-server/openmrs/spa`
2. Go to **Register Patient**
3. Fill in test patient details
4. Verify the registration completes successfully

---

## Step 6: Configure Backup

Set up automated backups by configuring the backup service in your `.env` file:

```bash
# Backup repository location
RESTIC_REPOSITORY=/restic_data

# Backup encryption password (use a strong password!)
RESTIC_PASSWORD=your-strong-backup-password

# Backup schedule (cron format) - daily at 2 AM
RESTIC_CRON_SCHEDULE=0 2 * * *

# Retention policy
RESTIC_KEEP_DAILY=7
RESTIC_KEEP_WEEKLY=4
RESTIC_KEEP_MONTHLY=12
RESTIC_KEEP_YEARLY=3
```

After updating `.env`, restart the backup service:

```bash
docker compose restart backup
```

Verify backup is configured:

```bash
docker compose logs backup
```

See [Backup & Restore](../operations/backup-restore) for detailed configuration.

---

## Post-Setup Checklist

- [ ] Default admin password changed
- [ ] Admin user configured as provider
- [ ] Staff user accounts created with appropriate roles
- [ ] Provider accounts created for clinical users
- [ ] Location hierarchy verified
- [ ] Concepts loaded correctly
- [ ] Test patient registration successful
- [ ] Backup configured and tested
- [ ] Instance name set (if applicable)

---

## Verifying the System

### Check System Status

```bash
# All services should show "Up" or "Up (healthy)"
docker compose ps

# Check for errors in logs
docker compose logs --since 1h | grep -i error
```

### Health Check Endpoints

```bash
# Check backend is responding
curl http://localhost/openmrs/ws/rest/v1/session

# Check health endpoint
curl http://localhost/openmrs/health/started
```

### Monitoring Script

You can use this script to wait for the system to be fully ready:

```bash
while [[ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost/openmrs/login.htm)" != "200" ]]; do
    echo "Waiting for OpenMRS to start..."
    sleep 10
done
echo "OpenMRS is ready!"
```

---

## Next Steps

- [Operations Guide](../operations/) - Day-to-day management
- [User Management](../operations/user-management) - Detailed user management
- [Backup & Restore](../operations/backup-restore) - Backup configuration
- [Monitoring](../operations/monitoring) - System monitoring
