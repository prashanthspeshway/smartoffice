# Run remove-username migration (username -> email)
# Usage: .\database\run-remove-username.ps1

$scriptPath = Join-Path $PSScriptRoot "remove-username-migration.sql"
if (-not (Test-Path $scriptPath)) {
    Write-Host "remove-username-migration.sql not found!" -ForegroundColor Red
    exit 1
}

$mysqlExe = $null
$mysql = Get-Command mysql -ErrorAction SilentlyContinue
if ($mysql) { $mysqlExe = $mysql.Source }
else {
    $paths = @(
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
        "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { $mysqlExe = $p; break }
    }
}

if (-not $mysqlExe) {
    Write-Host "MySQL not found. Use MySQL Workbench:" -ForegroundColor Red
    Write-Host "  File -> Open SQL Script -> database/remove-username-migration.sql" -ForegroundColor Yellow
    Write-Host "  Execute (Ctrl+Shift+Enter)" -ForegroundColor Yellow
    exit 1
}

Write-Host "Running remove-username-migration.sql..." -ForegroundColor Cyan
Write-Host "  - Migrates username -> email in all tables" -ForegroundColor Gray
Write-Host "  - Drops username column from users" -ForegroundColor Gray
Write-Host ""
cmd /c "`"$mysqlExe`" -u root -p smartoffice < `"$scriptPath`""
if ($LASTEXITCODE -eq 0) { Write-Host "Done! Restart the app." -ForegroundColor Green }
else { Write-Host "Failed. Run the script in MySQL Workbench and check for errors." -ForegroundColor Red }
