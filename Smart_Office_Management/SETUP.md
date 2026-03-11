# Setup Guide – Smart Office Management

## 1. MySQL schema import

**Important:** Run the import from **PowerShell** or **Command Prompt**, not from inside the MySQL client.

### Option A: From PowerShell (recommended)

```powershell
cd Smart_Office_Management
.\database\import-schema.ps1
```

Enter your MySQL root password when prompted.

### Option B: From PowerShell (manual)

```powershell
cd Smart_Office_Management
Get-Content database\schema.sql | mysql -u root -p
```

### Option C: Inside MySQL Workbench

1. Open MySQL Workbench and connect to your server.
2. Go to **File → Open SQL Script** and select `database/schema.sql`.
3. Click the **Execute** (lightning bolt) button.

### Option D: Using SOURCE inside MySQL client

If you are already in the MySQL prompt:

```sql
SOURCE C:/Users/Home/Desktop/smartoffice_management/Smart_Office_Management/database/schema.sql;
```

Use forward slashes and the full path.

### If you already have the database (Teams feature)

Run the teams migration to add the Teams tables:

```sql
SOURCE C:/Users/Home/Desktop/smartoffice_management/Smart_Office_Management/database/teams-migration.sql;
```

Or in MySQL Workbench: File → Open SQL Script → `database/teams-migration.sql` → Execute.

---

## 2. Maven – no manual install

The project uses the **Maven Wrapper** (`mvnw.cmd`). Maven is downloaded automatically on first run.

You do **not** need to install Maven manually.

---

## 3. Run the app

1. Edit `src/main/resources/db.properties` with your MySQL password.
2. Run:

```powershell
cd Smart_Office_Management
.\run.ps1
```

Or:

```powershell
.\mvnw.cmd clean package cargo:run
```

3. Open: **http://localhost:8080/Smart_Office_Management/**
4. Create admin: **http://localhost:8080/Smart_Office_Management/initAdmin**
5. Login: **admin** / **Admin@123**

---

## 4. Allow friends to access (same WiFi/network)

To let others on your network open the app using your IP:

**1. Allow port 8080 in Windows Firewall** (run PowerShell as Administrator):

```powershell
cd Smart_Office_Management
.\allow-firewall.ps1
```

**2. Find your IP** (e.g. 192.168.7.4):

```powershell
ipconfig | findstr "IPv4"
```

**3. Share this URL with your friend:**

```
http://YOUR_IP:8080/Smart_Office_Management/
```

Example: `http://192.168.7.4:8080/Smart_Office_Management/`

**Note:** Your friend must be on the **same WiFi or LAN** as you. For internet access, you’d need port forwarding on your router.

---

## If Maven extraction failed before

If you previously tried to install Maven and it failed during extraction:

1. You can ignore that – the project uses the Maven Wrapper.
2. Run `.\mvnw.cmd clean package cargo:run` – it will download Maven into `~/.m2/wrapper/dists/`.
3. No manual Maven installation is required.
