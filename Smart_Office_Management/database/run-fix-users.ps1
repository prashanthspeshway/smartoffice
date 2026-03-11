# Fix users table: firstname, lastname, manager (email->username)
# Run: .\database\run-fix-users.ps1

$scriptPath = Join-Path $PSScriptRoot "fix-users-complete.sql"
if (-not (Test-Path $scriptPath)) {
    Write-Host "fix-users-complete.sql not found!" -ForegroundColor Red
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
    Write-Host "  File -> Open SQL Script -> database/fix-users-complete.sql -> Execute" -ForegroundColor Yellow
    exit 1
}

Write-Host "Running fix-users-complete.sql..." -ForegroundColor Cyan
Write-Host "  - Adds firstname, lastname columns" -ForegroundColor Gray
Write-Host "  - Migrates fullname to first/last" -ForegroundColor Gray
Write-Host "  - Converts manager emails to usernames" -ForegroundColor Gray
Write-Host ""
cmd /c "`"$mysqlExe`" -u root -p < `"$scriptPath`""
if ($LASTEXITCODE -eq 0) { Write-Host "Done! Restart the app." -ForegroundColor Green }
else { Write-Host "Failed. Check MySQL is running and password is correct." -ForegroundColor Red }
