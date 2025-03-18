# TSplus Activation Server Block Script
# This script blocks outbound connections to TSplus activation servers

# Requires elevation to modify Windows Firewall
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires administrator privileges. Please run as administrator."
    exit 1
}

# List of TSplus activation domains to block
$domains = @(
    "dl-files.com",
    "licenseapi.dl-files.com"
)

Write-Host "Resolving TSplus activation server IP addresses..." -ForegroundColor Cyan

$ipAddresses = @()
foreach ($domain in $domains) {
    Write-Host "Looking up $domain..." -ForegroundColor Yellow
    try {
        # Use nslookup to get IP addresses
        $nslookupResult = nslookup $domain 2>$null
        
        # Parse nslookup output to extract IP addresses
        $allIps = $nslookupResult | Select-String -Pattern "\d+\.\d+\.\d+\.\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -Unique

        # If we have multiple IPs, assume the first one is the DNS server IP
        if ($allIps.Count -gt 1) {
            # Skip the first IP (DNS server)
            $serverIps = $allIps | Select-Object -Skip 1
            $ipAddresses += $serverIps
            Write-Host "Found IPs for $domain`: $($serverIps -join ', ')" -ForegroundColor Green
        } elseif ($allIps.Count -eq 1) {
            # If only one IP found, add it with a warning
            $ipAddresses += $allIps
            Write-Host "Found single IP for $domain`: $($allIps[0])" -ForegroundColor Green
            Write-Host "Warning: This might be a DNS server IP" -ForegroundColor Yellow
        } else {
            Write-Host "No IP addresses found for $domain" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error resolving $domain`: $_" -ForegroundColor Red
    }
}

# Remove duplicates
$uniqueIPs = $ipAddresses | Sort-Object -Unique

if ($uniqueIPs.Count -eq 0) {
    Write-Host "No IP addresses were found. Cannot create firewall rules." -ForegroundColor Red
    exit 1
}

Write-Host "Creating firewall rules to block connections to TSplus activation servers..." -ForegroundColor Cyan

# Create a firewall rule for each IP
$ruleNamePrefix = "Block-TSplus-Activation-"
$ruleDescription = "Blocks outbound connections to TSplus activation servers"

foreach ($ip in $uniqueIPs) {
    $ruleName = "$ruleNamePrefix$ip"
    
    # Check if rule already exists
    if (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue) {
        Write-Host "Rule '$ruleName' already exists. Skipping." -ForegroundColor Yellow
        continue
    }

    try {
        New-NetFirewallRule -DisplayName $ruleName -Direction Outbound -Action Block -RemoteAddress $ip -Protocol TCP -LocalPort Any -RemotePort Any -Description $ruleDescription
        Write-Host "Created outbound blocking rule for $ip" -ForegroundColor Green
    } catch {
        Write-Host "Error creating firewall rule for $ip`: $_" -ForegroundColor Red
    }
}

Write-Host "Finished blocking TSplus activation servers." -ForegroundColor Cyan
