# Shows whether something is listening on TCP 8080 and on which addresses.
# Run while the app is up (after .\run.ps1).

Write-Host "TCP listeners on port 8080 (LISTEN state):" -ForegroundColor Cyan
$listeners = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
if ($listeners) {
    $listeners | Select-Object LocalAddress, LocalPort, State | Format-Table -AutoSize
    $hasAll = $listeners | Where-Object { $_.LocalAddress -eq '0.0.0.0' -or $_.LocalAddress -eq '::' }
    if ($hasAll) {
        Write-Host "OK: Server is listening on all interfaces (0.0.0.0 or ::). Other devices can use http://<this-PC-IP>:8080/..." -ForegroundColor Green
    }
    else {
        $onlyLoopback = ($listeners | Where-Object { $_.LocalAddress -ne '127.0.0.1' }).Count -eq 0
        if ($onlyLoopback) {
            Write-Host "WARNING: Only 127.0.0.1 - other PCs on the LAN cannot connect." -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "Nothing listening on 8080. Start the app with .\run.ps1 first." -ForegroundColor Yellow
}

Write-Host "`nIPv4 addresses (for URLs on other devices):" -ForegroundColor Cyan
Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notmatch '^127\.' } |
    Select-Object IPAddress, InterfaceAlias |
    Format-Table -AutoSize
