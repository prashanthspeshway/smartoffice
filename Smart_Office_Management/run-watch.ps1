# Run with auto-restart on file changes (like nodemon)
# Watches src/ - when you save a file, the app restarts automatically
# Usage: .\run-watch.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$watchedDirs = @("src\main\java", "src\main\webapp")
$checkIntervalSeconds = 2

function Get-LatestFileTime {
    $latest = [DateTime]::MinValue
    foreach ($rel in $watchedDirs) {
        $full = Join-Path $PSScriptRoot $rel
        if (Test-Path $full) {
            Get-ChildItem -Path $full -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.LastWriteTime -gt $latest) { $latest = $_.LastWriteTime }
            }
        }
    }
    return $latest
}

Write-Host "Smart Office - Watch Mode (auto-restart on save)" -ForegroundColor Cyan
Write-Host "Watching: src/main/java, src/main/webapp" -ForegroundColor Gray
Write-Host "Server runs in a separate window. Press Ctrl+C here to stop." -ForegroundColor Gray
Write-Host ""

$lastWrite = Get-LatestFileTime
$serverProc = $null

while ($true) {
    # Start server if not running
    if ($null -eq $serverProc -or $serverProc.HasExited) {
        Write-Host "Starting server..." -ForegroundColor Green
        $serverProc = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\run.ps1`"" -WorkingDirectory $PSScriptRoot -PassThru
        $lastWrite = Get-LatestFileTime
    }

    Start-Sleep -Seconds $checkIntervalSeconds

    $current = Get-LatestFileTime
    if ($current -gt $lastWrite) {
        Write-Host ""
        Write-Host "Change detected. Restarting..." -ForegroundColor Yellow
        if ($null -ne $serverProc -and -not $serverProc.HasExited) {
            Stop-Process -Id $serverProc.Id -Force -ErrorAction SilentlyContinue
            $serverProc = $null
        }
        taskkill /F /IM java.exe 2>$null | Out-Null
        Start-Sleep -Seconds 3
    }
}
