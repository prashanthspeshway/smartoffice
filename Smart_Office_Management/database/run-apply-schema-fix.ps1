# Apply schema fix: add firstname/lastname columns to match Add Employee form
# Run: .\database\run-apply-schema-fix.ps1

$scriptPath = Join-Path $PSScriptRoot "apply-schema-fix.sql"
if (-not (Test-Path $scriptPath)) {
    Write-Host "apply-schema-fix.sql not found!" -ForegroundColor Red
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
    Write-Host "  File -> Open SQL Script -> database/apply-schema-fix.sql -> Execute" -ForegroundColor Yellow
    exit 1
}

Write-Host "Running apply-schema-fix.sql..." -ForegroundColor Cyan
Write-Host "  - Adds firstname, lastname if missing" -ForegroundColor Gray
Write-Host "  - Fixes column sizes for form compatibility" -ForegroundColor Gray
Write-Host ""
cmd /c "`"$mysqlExe`" -u root -p < `"$scriptPath`""
if ($LASTEXITCODE -eq 0) { Write-Host "Done! Try adding an employee again." -ForegroundColor Green }
else { Write-Host "Failed. Check MySQL is running and password is correct." -ForegroundColor Red }
