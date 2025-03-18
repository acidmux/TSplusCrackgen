# Check for admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script requires Administrator privileges to start services." -ForegroundColor Red
    Write-Host "Please re-run this script as Administrator." -ForegroundColor Yellow
    exit 1
}

Write-Host "Stopping TSplus services..."

$services = @(
    @{Name = "SVCE"; Path = "C:\Program Files (x86)\TSplus\UserDesktop\files\svcenterprise.exe"},
    @{Name = "APSC"; Path = "C:\Program Files (x86)\TSplus\UserDesktop\files\APSC.exe"}
)

foreach ($service in $services) {
    $serviceName = $service.Name
    Write-Host "Checking service: $serviceName"
    
    try {
        $svc = Get-Service -Name $serviceName -ErrorAction Stop
        Write-Host "Found $serviceName service. Stopping..."
        
        try {
            Stop-Service -Name $serviceName -Force -ErrorAction Stop
            Write-Host "Service $serviceName stopped successfully."
        } catch {
            Write-Host "Error stopping service ${serviceName}: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "Service $serviceName not found or cannot be accessed: $($_.Exception.Message)" -ForegroundColor Yellow
        # Continue with other services instead of exiting
    }
}

Write-Host "TSplus services processing completed." -ForegroundColor Green
