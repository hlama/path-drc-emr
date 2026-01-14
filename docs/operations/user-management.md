---
layout: default
title: User Management
parent: Operations
nav_order: 4
---

# User Management

Guide to creating and managing user accounts, roles, and privileges in PATH DRC EMR.

---

## Overview

User management in PATH DRC EMR is handled through the OpenMRS Legacy Admin UI. This guide covers:

- Creating user accounts
- Assigning roles and privileges
- Managing provider accounts
- Password management
- Deactivating users

---

## Accessing User Management

1. Navigate to the Legacy Admin UI: `http://your-server/openmrs`
2. Log in with an administrator account
3. Click **Administration** in the top menu
4. Select **Manage Users** under the Users section

---

## Creating a New User

### Step 1: Create Person Record

Every user needs a person record first:

1. Go to **Administration** → **Manage Persons**
2. Click **Add Person**
3. Fill in required information:
   - **Given Name**: First name
   - **Family Name**: Last name
   - **Gender**: Select appropriate option
4. Click **Save Person**

### Step 2: Create User Account

1. Go to **Administration** → **Manage Users**
2. Click **Add User**
3. Fill in the form:

**System ID**: Unique identifier (auto-generated or custom)

**Username**: Login name (required)
- Use lowercase letters and numbers
- No spaces or special characters
- Example: `jsmith`, `nurse01`

**Person**: Link to person record
- Search for the person you created
- Or create a new person inline

**Password**: Initial password
- Must meet complexity requirements
- User should change on first login

### Step 3: Assign Roles

Select appropriate roles for the user:

| Role | Description | Typical Users |
|------|-------------|---------------|
| Organizational: Doctor | Clinical privileges for physicians | Doctors |
| Organizational: Nurse | Clinical privileges for nurses | Nurses |
| Organizational: Registration Clerk | Patient registration only | Front desk staff |
| System Developer | Full system access | IT administrators |
| Provider | Basic provider functions | All clinical staff |

{: .warning }
> Assign only the minimum roles needed. Avoid giving System Developer to non-technical users.

### Step 4: Save and Verify

1. Click **Save User**
2. Verify the user appears in the user list
3. Test login with the new account

---

## Setting Up Provider Accounts

Clinical users need provider accounts to perform clinical functions.

### Create Provider

1. Go to **Administration** → **Manage Providers**
2. Click **Add Provider**
3. Fill in:
   - **Identifier**: Provider ID (can be auto-generated)
   - **Person**: Link to the user's person record
   - **Provider Role**: Select appropriate role
4. Click **Save Provider**

### Link User to Provider

This is typically done automatically when creating a provider with a linked person. Verify by:

1. Go to **Manage Providers**
2. Find the provider
3. Confirm the person link is correct

---

## Common Roles

### Organizational: Doctor

**Privileges include:**
- View patients
- Create/edit encounters
- Order medications
- View clinical data
- Access all clinical forms

**Assign to:** Physicians, clinical officers

### Organizational: Nurse

**Privileges include:**
- View patients
- Create/edit nursing encounters
- Record vitals
- Administer medications
- View clinical data

**Assign to:** Nurses, nursing assistants

### Organizational: Registration Clerk

**Privileges include:**
- Register patients
- Edit patient demographics
- Schedule appointments
- View limited patient information

**Assign to:** Front desk staff, registration clerks

### System Developer

**Privileges include:**
- All system access
- Manage users
- Manage modules
- Access administration

{: .warning }
> Use sparingly. This role has full system access.

---

## Password Management

### Password Requirements

Default OpenMRS password requirements:
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number

### Reset User Password

**As administrator:**

1. Go to **Administration** → **Manage Users**
2. Find and click on the user
3. Enter new password in **Password** field
4. Confirm in **Confirm Password** field
5. Click **Save User**

### User Self-Service

Users can change their own password:

1. Log in to OpenMRS
2. Click user name (top right)
3. Select **My Profile** or **Change Password**
4. Enter current password
5. Enter and confirm new password
6. Click **Save**

---

## Deactivating Users

### Retire (Recommended)

Retiring keeps the user record but prevents login:

1. Go to **Administration** → **Manage Users**
2. Find and click on the user
3. Click **Retire User** (or check "Retired" checkbox)
4. Enter reason for retirement
5. Click **Save**

**Benefits:**
- Audit trail preserved
- Can be unretired if needed
- Associated data remains linked

### Delete (Permanent)

{: .warning }
> Only delete if the user was created by mistake and has no associated data.

1. Go to **Administration** → **Manage Users**
2. Find and click on the user
3. Click **Delete User** (if available)
4. Confirm deletion

---

## Bulk User Management

### Export User List

```bash
# Export from database
docker compose exec db mysql -u openmrs -popenmrs openmrs -e \
  "SELECT u.username, p.given_name, p.family_name, u.retired
   FROM users u
   JOIN person_name p ON u.person_id = p.person_id
   WHERE p.preferred = 1;" > users.csv
```

### View Active Users

```bash
docker compose exec db mysql -u openmrs -popenmrs openmrs -e \
  "SELECT username FROM users WHERE retired = 0;"
```

---

## Audit and Security

### View Login History

Check who has logged in:

```bash
# Check backend logs for login events
docker compose logs backend | grep -i "login\|authentication"
```

### View User Changes

```bash
# Recent user modifications
docker compose exec db mysql -u openmrs -popenmrs openmrs -e \
  "SELECT u.username, u.date_changed, u.changed_by
   FROM users u
   ORDER BY u.date_changed DESC
   LIMIT 20;"
```

### Security Best Practices

1. **Regular audits**: Review user list monthly
2. **Prompt deactivation**: Remove access immediately when staff leave
3. **Least privilege**: Assign minimum required roles
4. **Password policy**: Enforce regular password changes
5. **Shared accounts**: Never share login credentials
6. **Session timeouts**: Configure appropriate session timeouts

---

## Troubleshooting

### User Cannot Log In

**Check if account exists:**
1. Go to **Manage Users**
2. Search for username
3. Verify account is not retired

**Check if password is correct:**
1. Reset password as administrator
2. Have user try again with new password

**Check roles:**
1. Verify user has at least one role assigned
2. Ensure roles include necessary privileges

### User Cannot Access Features

**Check role assignments:**
1. Go to user's profile
2. Review assigned roles
3. Add missing roles if needed

**Check provider account:**
Clinical functions require a provider account. Verify:
1. User has linked provider record
2. Provider is not retired

### Cannot Create Users

**Check your permissions:**
- You need System Developer or similar admin role
- Verify your account has "Manage Users" privilege

---

## Quick Reference

### Create User Checklist

- [ ] Create person record (name, gender)
- [ ] Create user account (username, password)
- [ ] Assign appropriate roles
- [ ] Create provider record (if clinical user)
- [ ] Test login
- [ ] Inform user of credentials
- [ ] User changes password on first login

### Common Tasks

```
Create user:        Administration → Manage Users → Add User
Reset password:     Administration → Manage Users → [User] → Change password
Assign roles:       Administration → Manage Users → [User] → Edit roles
Create provider:    Administration → Manage Providers → Add Provider
Retire user:        Administration → Manage Users → [User] → Retire
```

---

## Related

- [Initial Setup](../getting-started/initial-setup) - First-time user setup
- [Troubleshooting](troubleshooting) - Common issues
