# Import teams tables only - run if you already have the database but no teams/team_members
# Usage: .\database\import-teams-migration.ps1  (from project root)
# Or: .\import-teams-migration.ps1  (when already in database folder)

$scriptPath = Join-Path $PSScriptRoot "teams-migration.sql"
if (-not (Test-Path $scriptPath)) {
    Write-Host "teams-migration.sql not found!" -ForegroundColor Red
    exit 1
}

$mysqlExe = $null
$mysql = Get-Command mysql -ErrorAction SilentlyContinue
if ($mysql) {
    $mysqlExe = $mysql.Source
} else {
    $paths = @(
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
        "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe",
        "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { $mysqlExe = $p; break }
    }
}

if (-not $mysqlExe) {
    Write-Host "MySQL not found. Use MySQL Workbench instead:" -ForegroundColor Red
    Write-Host "  File -> Open SQL Script -> database/teams-migration.sql -> Execute" -ForegroundColor Yellow
    exit 1
}

Write-Host "Importing teams tables from $scriptPath" -ForegroundColor Cyan
Write-Host "Enter your MySQL root password when prompted." -ForegroundColor Yellow
Write-Host ""

cmd /c "`"$mysqlExe`" -u root -p < `"$scriptPath`""

if ($LASTEXITCODE -eq 0) {
    Write-Host "Teams migration completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Import failed. Make sure MySQL is running and password is correct." -ForegroundColor Red
}
