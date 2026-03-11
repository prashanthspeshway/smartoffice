# Database Migration Guide

## Option 0: Keep Username (Recommended if you have existing data)

**If you want to keep the `username` column** and have it auto-filled from firstname + lastname:

1. **No migration needed** – your current schema is fine.
2. **Sync existing users:** Run `sync-username-from-name.sql` to update username from firstname + lastname.
3. **Add Employee** – The app now sets `username = firstname + lastname` automatically.

---

## Current vs Target Structure (for full migration)

**Current (old):** `users` has `username`, `firstname`, `lastname`, `email`  
**Target:** `users` has `firstname`, `lastname`, `email` (no username). All tables use `email` as the user identifier.

---

## Option 1: Fresh Install (no existing data to keep)

1. Open **MySQL Workbench** and connect to your server.
2. Run `schema.sql`:
   - File → Open SQL Script → select `schema.sql`
   - Execute (Ctrl+Shift+Enter)
3. Done. The schema uses `email` and `firstname`/`lastname` only.

---

## Option 2: Migrate Existing Database (keep your data)

1. **Backup first:**
   ```sql
   mysqldump -u root -p smartoffice > smartoffice_backup.sql
   ```
   Or in MySQL Workbench: Server → Data Export → select `smartoffice` → Export.

2. **Run the migration:**
   - Open `remove-username-migration.sql` in MySQL Workbench
   - Execute the **entire script** (Ctrl+Shift+Enter)

3. **If you get "Duplicate entry" on attendance:**
   - Run `fix-attendance-duplicates.sql` first
   - Then run `remove-username-migration.sql` again

4. **Remove username from users:**
   The migration ends with step 11, which drops the `username` column from `users`.

---

## Option 3: Sync username from firstname + lastname (keep username column)

Run `sync-username-from-name.sql` to update all existing users:

```sql
-- Updates username = firstname + " " + lastname for all users
```

---

## Verify After Migration

```sql
USE smartoffice;

-- Check users table structure
DESCRIBE users;

-- Should show: id, password, firstname, lastname, role, status, email, phone, joinedDate, created_at
-- No 'username' column
```
