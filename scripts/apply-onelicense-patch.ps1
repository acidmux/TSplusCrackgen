Write-Host "Applying OneLicense patch..."

# Source file location
$sourceFile = Join-Path $PSScriptRoot "..\assets\OneLicense.dll"

# Target location in work directory
$targetFile = Join-Path $env:TSPLUS_WORKDIR "OneLicense.dll"

# Ensure source file exists
if (-not (Test-Path $sourceFile)) {
    Write-Error "Source file not found: $sourceFile"
    exit 1
}

# Create target directory if it doesn't exist
$targetDir = Split-Path -Parent $targetFile
if (-not (Test-Path $targetDir)) {
    New-Item -Path $targetDir -ItemType Directory -Force
}

# Copy the file
Copy-Item -Path $sourceFile -Destination $targetFile -Force
Write-Host "OneLicense.dll copied successfully to $targetFile"
