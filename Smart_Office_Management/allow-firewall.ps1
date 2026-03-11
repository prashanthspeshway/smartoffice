# Allow port 8080 through Windows Firewall - run as Administrator
# Right-click PowerShell -> Run as Administrator, then: .\allow-firewall.ps1

$ruleName = "Smart Office Management - Tomcat 8080"
$port = 8080

# Remove existing rule if present
Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

# Add inbound rule
New-NetFirewallRule -DisplayName $ruleName `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort $port `
    -Action Allow `
    -Profile Any

Write-Host "Firewall rule added. Port $port is now open for incoming connections." -ForegroundColor Green
Write-Host "Your friend can access: http://YOUR_IP:8080/Smart_Office_Management/" -ForegroundColor Cyan
