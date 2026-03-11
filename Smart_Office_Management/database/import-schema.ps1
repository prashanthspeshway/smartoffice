# Import database schema - run from PowerShell (NOT from inside MySQL!)
# Usage: .\database\import-schema.ps1  (from project root)
# Or: .\import-schema.ps1  (when already in database folder)

$schemaPath = Join-Path $PSScriptRoot "schema.sql"
if (-not (Test-Path $schemaPath)) {
    Write-Host "schema.sql not found!" -ForegroundColor Red
    exit 1
}

# Find mysql.exe - check PATH first, then common install locations
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
    Write-Host "MySQL not found. Options:" -ForegroundColor Red
    Write-Host "  1. Use MySQL Workbench: File -> Open SQL Script -> database/schema.sql -> Execute (lightning icon)" -ForegroundColor Yellow
    Write-Host "  2. Add MySQL to PATH: Add 'C:\Program Files\MySQL\MySQL Server 8.0\bin' to your system PATH" -ForegroundColor Yellow
    exit 1
}

Write-Host "Importing schema from $schemaPath" -ForegroundColor Cyan
Write-Host "Enter your MySQL root password when prompted." -ForegroundColor Yellow
Write-Host ""

cmd /c "`"$mysqlExe`" -u root -p < `"$schemaPath`""

if ($LASTEXITCODE -eq 0) {
    Write-Host "Schema imported successfully!" -ForegroundColor Green
} else {
    Write-Host "Import failed. Make sure MySQL is running and password is correct." -ForegroundColor Red
}
