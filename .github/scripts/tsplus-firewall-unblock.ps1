# TSplus Activation Server Unblock Script
# This script removes firewall rules blocking TSplus activation servers

# Requires elevation to modify Windows Firewall
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires administrator privileges. Please run as administrator."
    exit 1
}

$ruleNamePrefix = "Block-TSplus-Activation-"

Write-Host "Removing firewall rules blocking TSplus activation servers..." -ForegroundColor Cyan

# Find all rules with our prefix
$rules = Get-NetFirewallRule -DisplayName "$ruleNamePrefix*" -ErrorAction SilentlyContinue

if (-not $rules) {
    Write-Host "No TSplus blocking firewall rules found." -ForegroundColor Yellow
    exit 0
}

# Count rules for reporting
$foundRules = @($rules).Count
$removedRules = 0

# Remove each rule
foreach ($rule in $rules) {
    try {
        $ruleName = $rule.DisplayName
        Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction Stop
        Write-Host "Removed rule: $ruleName" -ForegroundColor Green
        $removedRules++
    } catch {
        Write-Host "Error removing rule $($rule.DisplayName): $_" -ForegroundColor Red
    }
}

Write-Host "Finished removing TSplus blocking firewall rules." -ForegroundColor Cyan
Write-Host "Removed $removedRules of $foundRules rules." -ForegroundColor Cyan
