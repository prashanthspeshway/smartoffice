# Smart Office Management

Java web application for office management with user roles (Admin, Manager, Employee), attendance, meetings, tasks, leave requests, and more.

**Stack:** JDK 17 | Tomcat 9 (embedded) | MySQL

---

## Prerequisites

- **JDK 17** – [Download](https://adoptium.net/)
- **Maven** – [Download](https://maven.apache.org/download.cgi) or `winget install Apache.Maven`
- **MySQL 5.7+ or 8.0** – [Download](https://dev.mysql.com/downloads/mysql/)

**No Eclipse, Tomcat, or Maven install needed** – Maven Wrapper downloads Maven automatically; Cargo runs embedded Tomcat.

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

Or: `.\mvnw.cmd clean package cargo:run`

First run downloads Maven + dependencies + embedded Tomcat (~80MB). Then open:

**http://localhost:8080/Smart_Office_Management/**

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

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `mvn not found` | Install Maven and add to PATH. Or: `winget install Apache.Maven` |
| `java not found` | Install JDK 17 and add to PATH. |
| `db.properties not found` | Ensure `db.properties` is in `src/main/resources/`. |
| `No suitable driver` | Check `db.url`, `db.username`, `db.password` in `db.properties`. |
| Port 8080 in use | Edit `pom.xml` → `cargo.servlet.port` (e.g. 9090). |
