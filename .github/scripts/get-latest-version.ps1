# This script gets the latest available TSplus version from the website

# Set TLS to 1.2 to avoid connection issues with some servers
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    # Check if custom version was provided as workflow input
    if ($env:INPUT_CUSTOM_VERSION) {
        Write-Host "Using custom version from workflow input: $env:INPUT_CUSTOM_VERSION"
        $version = $env:INPUT_CUSTOM_VERSION
    } else {
        # Get the latest version from dl-files.com
        Write-Host "Fetching latest version from dl-files.com..."
        $version = Invoke-RestMethod -Uri 'https://dl-files.com/data/latestversion.txt' -TimeoutSec 10
        Write-Host "Latest Version: $version"
    }
    
    # Set output for GitHub Actions - use both variable names for consistency
    echo "LATEST_VERSION=$version" >> $env:GITHUB_ENV
    echo "TSPLUS_VERSION=$version" >> $env:GITHUB_ENV
    
    Write-Host "Version information saved to environment variables"
} catch {
    $errorMessage = "Error retrieving latest version: $($_.Exception.Message)"
    
    # Add diagnostic information
    if ($_.Exception.InnerException) {
        $errorMessage += "`nInner exception: $($_.Exception.InnerException.Message)"
    }
    
    # Try to get more network diagnostics
    try {
        Write-Host "Running diagnostics..."
        $pingResult = Test-NetConnection -ComputerName "dl-files.com" -InformationLevel Quiet
        $errorMessage += "`nCan ping host: $pingResult"
    } catch {
        $errorMessage += "`nCould not run network diagnostics: $($_.Exception.Message)"
    }
    
    Write-Host "##[error]$errorMessage"
    exit 1
}