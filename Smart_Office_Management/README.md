# Smart Office Management

Java web application for office management with user roles (Admin, Manager, Employee), attendance, meetings, tasks, leave requests, and more.

**Stack:** JDK 17 | Tomcat 9 (embedded) | MySQL

---

## Prerequisites

- **JDK 17** – [Download](https://adoptium.net/)
- **Maven** – [Download](https://maven.apache.org/download.cgi) or `winget install Apache.Maven`
- **MySQL 5.7+ or 8.0** – [Download](https://dev.mysql.com/downloads/mysql/)

**No Eclipse, Tomcat, or Maven install needed** – Maven Wrapper downloads Maven automatically; **`run.ps1`** starts embedded Tomcat via **`LanTomcatLauncher`** (binds HTTP to **`0.0.0.0`** so LAN access works; Codehaus Cargo often does not apply `cargo.hostname` to the connector).

---

## Quick Start (Run from Cursor / VS Code / Terminal)

### 1. Database

1. Start MySQL.
2. Run the schema **from PowerShell** (not from inside MySQL!):

```powershell
.\database\import-schema.ps1
```

Or in MySQL Workbench: File → Open SQL Script → `database/schema.sql` → Execute.

3. Edit `src/main/resources/db.properties` with your MySQL password.

### 2. Run the app

```powershell
cd Smart_Office_Management
.\run.ps1
```

- **Full clean rebuild** (slower): `.\run.ps1 -Clean`
- **LAN not reachable?** After the server starts, run `.\scripts\Diagnose-Network.ps1` — you should see a listener on `0.0.0.0:8080`. If not, open the firewall (see below).

Or: `.\mvnw.cmd package exec:java` (same as `run.ps1`)

**Alternative:** `.\mvnw.cmd cargo:run` (older embedded Tomcat path; LAN bind may be unreliable)

First run downloads Maven + dependencies + embedded Tomcat (~80MB). Then open:

**http://localhost:8080/Smart_Office_Management/**

After login, the **employee** dashboard opens **Overview** (snapshot of attendance, tasks, leave, meetings, and recent activity). Admins and managers have their own overview pages.

### Access from other devices on your Wi‑Fi / LAN

The dev server listens on **all interfaces** (`LanTomcatLauncher` sets the HTTP connector address to **`0.0.0.0`**). On another phone or PC, use **your computer’s IPv4 address**, not `localhost`:

- Example: `http://192.168.1.50:8080/Smart_Office_Management/`  
  (Find the address with `ipconfig` on Windows, or use the **LAN** lines printed when you run `.\run.ps1`.)

**Windows Firewall** often blocks inbound connections. Either:

1. **Allow the port** (recommended on a trusted home network): open PowerShell **as Administrator** and run:
   ```powershell
   cd Smart_Office_Management\scripts
   .\Open-Firewall-8080.ps1
   ```
2. Or when Windows asks, allow **Java** / **OpenJDK** for **Private** networks.

**Note:** Guest Wi‑Fi or “AP isolation” on routers blocks phone↔PC traffic; use the main LAN or disable isolation.

### 3. Create admin user

Visit: **http://localhost:8080/Smart_Office_Management/initAdmin**

Login: **admin** / **Admin@123** (change after first login)

---

## Alternative: Eclipse

1. Import as Maven project.
2. Run → Run Configurations → Maven → Goals: `cargo:run`.

---

## Project Structure

```
Smart_Office_Management/
├── pom.xml                 # Maven config (deps + embedded Tomcat)
├── run.ps1                 # Run script
├── database/
│   └── schema.sql          # MySQL schema
└── src/main/
    ├── java/               # Java sources
    ├── resources/
    │   └── db.properties   # DB config (edit password here)
    └── webapp/
        ├── WEB-INF/web.xml
        ├── index.html      # Login page
        ├── admin.jsp, manager.jsp, user.jsp
        └── ...
```

---

## Dashboard navigation (refresh keeps your page)

The three shell pages **`admin.jsp`**, **`user.jsp`**, and **`manager.jsp`** sync the browser URL when you change sections so **refresh (F5) stays on the same screen**:

| Dashboard | URL mechanism | Example |
|-----------|---------------|---------|
| **Admin** | `?view=<iframe page>` | `admin.jsp?view=teams` |
| **Employee** | `?view=<page>` | `/user?view=userTasks` (servlet URL; legacy `?tab=` is read once, then normalized to `view`) |
| **Manager** | `?view=<iframe page>` | `managerDashboard.jsp?view=managerTeams` (login redirects here; older **`manager.jsp`** / **`manager?tab=`** is separate) |

- Opening **Notifications** in Admin/Employee loads the iframe but **does not change `view`**, so refresh returns to the last sidebar section.
- Flash query params (`success`, `error`) are stripped after the toast while preserving `view` / `tab`.

### Code quality notes (ongoing)

- Prefer **one canonical id** per DOM node (e.g. `manager.jsp` historically had duplicate `id="settings"` in places—investigate and dedupe when touching that file).
- Shell scripts use **`history.replaceState`** (not `pushState`) so the back button is not flooded with every sidebar click; adjust if you need full history.
- Keep servlet mappings and iframe `src` values in sync when adding new pages.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `mvn not found` | Install Maven and add to PATH. Or: `winget install Apache.Maven` |
| `java not found` | Install JDK 17 and add to PATH. |
| `db.properties not found` | Ensure `db.properties` is in `src/main/resources/`. |
| `No suitable driver` | Check `db.url`, `db.username`, `db.password` in `db.properties`. |
| Port 8080 in use | With **`run.ps1` / `exec:java`:** `.\mvnw.cmd package exec:java "-Dtomcat.port=9090"`. With Cargo: edit `pom.xml` → `cargo.servlet.port`. |
| Other PCs can’t open the site | Use `http://<your-PC-LAN-IP>:8080/...` not `localhost`. Open firewall (see **Access from other devices** above). Same Wi‑Fi segment; disable guest isolation if needed. Run `.\scripts\Diagnose-Network.ps1` — you should see a listener on **`0.0.0.0:8080`**. |
