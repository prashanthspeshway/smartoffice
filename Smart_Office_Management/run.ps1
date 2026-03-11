# Run Smart Office Management - uses embedded Tomcat (no separate install needed)
# Requires: JDK 17 only - Maven is auto-downloaded via wrapper
# Run: .\run.ps1

$ErrorActionPreference = "Stop"

# Check for Java
$java = Get-Command java -ErrorAction SilentlyContinue
if (-not $java) {
    Write-Host "Java not found. Please install JDK 17 and add to PATH." -ForegroundColor Red
    exit 1
}

Set-Location $PSScriptRoot

# Remove stale Cargo config (fixes "Invalid configuration dir" after failed runs)
$cargoDir = Join-Path $PSScriptRoot ".cargo-runtime"
if (Test-Path $cargoDir) {
    Remove-Item -Recurse -Force $cargoDir -ErrorAction SilentlyContinue
}

# Remove target if clean failed before (files locked by previous run)
$targetDir = Join-Path $PSScriptRoot "target"
if (Test-Path $targetDir) {
    Write-Host "Cleaning previous build..." -ForegroundColor Gray
    Remove-Item -Recurse -Force $targetDir -ErrorAction SilentlyContinue
    if (Test-Path $targetDir) {
        Write-Host "Could not delete target folder. Close any running server (Ctrl+C) and try again." -ForegroundColor Yellow
        Write-Host "Or run: taskkill /F /IM java.exe" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "Building and starting Smart Office Management..." -ForegroundColor Cyan
Write-Host "App: http://localhost:8080/Smart_Office_Management/" -ForegroundColor Green
Write-Host ""

& .\mvnw.cmd package cargo:run
