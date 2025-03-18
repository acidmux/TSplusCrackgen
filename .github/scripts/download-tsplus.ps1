# This script downloads the TSplus setup file

# Get version from environment variables
$version = $env:TSPLUS_VERSION
if (-not $version) {
    $version = $env:LATEST_VERSION
}

if (-not $version) {
    Write-Host "##[error]No TSplus version found in environment variables"
    exit 1
}

Write-Host "Version from environment: $version"

try {
    # Create download directory
    $downloadDir = Join-Path $env:TEMP "TSplus_Download"
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
    
    # Define output path
    $outputPath = Join-Path $downloadDir "Setup-TSplus.exe"
    
    # Download using established approach
    $headers = @{
        'User-Agent' = 'InnoDownloadPlugin/1.6'
    }
    
    Write-Host "Downloading TSplus setup..."
    Write-Host "URL: https://dl-files.com/dl/Setup-Master-signed-tsplus.exe"
    Write-Host "Destination: $outputPath"
    
    $progressPreference = 'SilentlyContinue'  # Speeds up download significantly
    Invoke-WebRequest -Uri 'https://dl-files.com/dl/Setup-Master-signed-tsplus.exe' `
        -Headers $headers `
        -OutFile $outputPath
    $progressPreference = 'Continue'
    
    # Verify file was downloaded
    if (Test-Path $outputPath) {
        Write-Host "Download completed successfully."
        $fileInfo = Get-Item $outputPath
        Write-Host "File size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB"
        
        # Store the path in environment variable for other scripts
        echo "TSPLUS_SETUP_PATH=$outputPath" >> $env:GITHUB_ENV
        Write-Host "::debug::Setting TSPLUS_SETUP_PATH=$outputPath in GITHUB_ENV"
    } else {
        throw "Failed to download file."
    }
}
catch {
    Write-Host "##[error]Error downloading TSplus setup: $_"
    exit 1
}