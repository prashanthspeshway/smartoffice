# Run Smart Office Management - embedded Tomcat (LanTomcatLauncher binds 0.0.0.0 for LAN)
# Usage:  .\run.ps1
#         .\run.ps1 -Clean     (full clean: deletes target + .cargo-runtime, slower)
# Requires: JDK 17, PowerShell 5.1+

param(
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

# Check for Java
$java = Get-Command java -ErrorAction SilentlyContinue
if (-not $java) {
    Write-Host "Java not found. Please install JDK 17 and add to PATH." -ForegroundColor Red
    exit 1
}

Set-Location $PSScriptRoot

if ($Clean) {
    $cargoDir = Join-Path $PSScriptRoot ".cargo-runtime"
    if (Test-Path $cargoDir) {
        Remove-Item -Recurse -Force $cargoDir -ErrorAction SilentlyContinue
    }
    $targetDir = Join-Path $PSScriptRoot "target"
    if (Test-Path $targetDir) {
        Write-Host "Cleaning previous build (-Clean)..." -ForegroundColor Gray
        Remove-Item -Recurse -Force $targetDir -ErrorAction SilentlyContinue
        if (Test-Path $targetDir) {
            Write-Host "Could not delete target folder. Close any running server (Ctrl+C) and try again." -ForegroundColor Yellow
            Write-Host "Or run: taskkill /F /IM java.exe" -ForegroundColor Yellow
            exit 1
        }
    }
}

Write-Host "Building and starting Smart Office Management..." -ForegroundColor Cyan
Write-Host "This PC:  http://localhost:8080/Smart_Office_Management/" -ForegroundColor Green

# LAN URLs: do not use $ErrorActionPreference=Stop here (can abort script before Maven runs)
$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
try {
    $addrs = @()
    $raw = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue
    if ($raw) {
        $addrs = $raw |
            Where-Object { $null -ne $_.IPAddress -and $_.IPAddress -notmatch '^127\.' } |
            Select-Object -ExpandProperty IPAddress -Unique
    }
    if (-not $addrs -or $addrs.Count -eq 0) {
        $ipconfigOut = ipconfig 2>$null
        if ($ipconfigOut) {
            $addrs = [regex]::Matches(($ipconfigOut -join "`n"), 'IPv4 Address[^:]*:\s*(\d+\.\d+\.\d+\.\d+)') |
                ForEach-Object { $_.Groups[1].Value } |
                Where-Object { $_ -notmatch '^127\.' } |
                Select-Object -Unique
        }
    }
    if ($addrs -and $addrs.Count -gt 0) {
        Write-Host "LAN access (use one of these from phones / other PCs on the same network):" -ForegroundColor Yellow
        foreach ($a in $addrs) {
            Write-Host "         http://${a}:8080/Smart_Office_Management/" -ForegroundColor Yellow
        }
        Write-Host "If connection fails: Windows Firewall may block port 8080." -ForegroundColor DarkGray
        Write-Host "  Run PowerShell as Admin:  .\scripts\Open-Firewall-8080.ps1" -ForegroundColor DarkGray
        Write-Host "After the server starts, you can verify listen with:  .\scripts\Diagnose-Network.ps1" -ForegroundColor DarkGray
    }
    else {
        Write-Host "(No LAN IPv4 found automatically. Run ipconfig and use your Wi-Fi/Ethernet IPv4 address.)" -ForegroundColor DarkGray
    }
}
catch {
    Write-Host "(Could not list LAN IPs - use ipconfig to find your IPv4.)" -ForegroundColor DarkGray
}
finally {
    $ErrorActionPreference = $prevEap
}

Write-Host ""

# LanTomcatLauncher sets connector address=0.0.0.0 (Cargo embedded often ignores cargo.hostname)
& .\mvnw.cmd @("package", "exec:java")
