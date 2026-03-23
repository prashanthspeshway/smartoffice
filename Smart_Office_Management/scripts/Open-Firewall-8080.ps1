# Opens TCP 8080 for inbound traffic on Private networks (so other devices can reach embedded Tomcat).
# Right-click PowerShell -> Run as Administrator, then:
#   cd ...\Smart_Office_Management\scripts
#   .\Open-Firewall-8080.ps1

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

$ruleName = "Smart Office Management - Tomcat 8080"
$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Rule already exists: $ruleName" -ForegroundColor Yellow
    exit 0
}

New-NetFirewallRule -DisplayName $ruleName `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort 8080 `
    -Profile Private `
    -Description "Allow LAN access to Smart Office Management (Cargo embedded Tomcat)"

Write-Host "Firewall rule added: $ruleName (Private profile only)." -ForegroundColor Green
Write-Host "Connect from another device: http://<this-PC-IPv4>:8080/Smart_Office_Management/" -ForegroundColor Cyan
