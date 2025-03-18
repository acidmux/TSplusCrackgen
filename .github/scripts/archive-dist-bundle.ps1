# Archive the working directory after patching

# Check if TSPLUS_WORKDIR is available from GitHub environment
$workDir = if ($env:TSPLUS_WORKDIR) { $env:TSPLUS_WORKDIR } else { [Environment]::GetEnvironmentVariable("TSPLUS_WORKDIR", "Process") }

if (-not $workDir -or -not (Test-Path $workDir)) {
    Write-Host "Error: Working directory not found. Make sure prepare-work-files.ps1 was run first." -ForegroundColor Red
    Write-Host "Current value: $workDir" -ForegroundColor Red
    exit 1
}

# Get TSplus version from environment variable
$tsplusVersion = $env:TSPLUS_VERSION
if (-not $tsplusVersion) {
    $tsplusVersion = [Environment]::GetEnvironmentVariable("TSPLUS_VERSION", "Process")
}

if (-not $tsplusVersion) {
    # If version not found, use a default naming convention
    $tsplusVersion = "unknown-version"
    Write-Host "Warning: TSplus version not found in environment. Using default naming." -ForegroundColor Yellow
}

# Get the path to the downloaded TSplus setup
$setupFilePath = $env:TSPLUS_SETUP_PATH
if (-not $setupFilePath) {
    $setupFilePath = [Environment]::GetEnvironmentVariable("TSPLUS_SETUP_PATH", "Process")
}

if (-not $setupFilePath -or -not (Test-Path $setupFilePath)) {
    Write-Host "Warning: TSplus setup file not found. Setup file won't be included in release." -ForegroundColor Yellow
    Write-Host "Setup path: $setupFilePath" -ForegroundColor Yellow
} else {
    Write-Host "Found TSplus setup file: $setupFilePath (will be uploaded separately in release)"
}

# Create archive directory
$archiveDir = Join-Path $env:GITHUB_WORKSPACE "archives"
New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

# Create the archive filename using build number instead of timestamp
$archiveFile = Join-Path $archiveDir "TSplus-Crack-v$tsplusVersion.zip"

try {
    # Ensure proper directory structure for the archive
    Write-Host "Preparing archive with required directory structure..."
    
    # Create a temporary directory for organizing files
    $structuredDir = Join-Path $env:TEMP "TSplus-Structured-$(Get-Random)"
    New-Item -ItemType Directory -Path $structuredDir -Force | Out-Null
    
    # Create the expected directory structure
    $paths = @(
        "TSplus\UserDesktop\files",
        "TSplus\Clients\www\cgi-bin",
        "Utilities"  # Add Utilities folder for the scripts
    )
    
    foreach ($path in $paths) {
        $fullPath = Join-Path $structuredDir $path
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created directory: $fullPath"
    }
    
    # Define the files to copy with their source and destination paths
    $filesToCopy = @(
        @{Source="APSC.exe"; Destination=Join-Path $structuredDir "TSplus\UserDesktop\files\APSC.exe"},
        @{Source="AdminTool.exe"; Destination=Join-Path $structuredDir "TSplus\UserDesktop\files\AdminTool.exe"},
        @{Source="TwoFactor.Admin.exe"; Destination=Join-Path $structuredDir "TSplus\UserDesktop\files\TwoFactor.Admin.exe"},
        @{Source="OneLicense.dll"; Destination=Join-Path $structuredDir "TSplus\UserDesktop\files\OneLicense.dll"}
    )
    
    # Also copy OneLicense.dll to the cgi-bin directory
    $filesToCopy += @{Source="OneLicense.dll"; Destination=Join-Path $structuredDir "TSplus\Clients\www\cgi-bin\OneLicense.dll"}
    
    # Add the utility scripts to the copy list
    $scriptFiles = @(
        "start-services.ps1",
        "stop-services.ps1",
        "tsplus-firewall-block.ps1",
        "tsplus-firewall-unblock.ps1"
    )
    
    foreach ($scriptFile in $scriptFiles) {
        $scriptSource = Join-Path $env:GITHUB_WORKSPACE ".github\scripts\$scriptFile"
        if (Test-Path $scriptSource) {
            $filesToCopy += @{Source=$scriptSource; Destination=Join-Path $structuredDir "Utilities\$scriptFile"}
            Write-Host "Added script $scriptFile to archive list"
        } else {
            Write-Host "Warning: Script file $scriptSource not found" -ForegroundColor Yellow
        }
    }
    
    # Copy the files to their destinations
    foreach ($file in $filesToCopy) {
        $sourcePath = if ($file.Source -like "*\*") { $file.Source } else { Join-Path $workDir $file.Source }
        if (Test-Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $file.Destination -Force
            Write-Host "Copied $($sourcePath) to $($file.Destination)"
        } else {
            Write-Host "Warning: Source file $sourcePath not found" -ForegroundColor Yellow
        }
    }
    
    # Create RELEASE_NOTES.md file
    Write-Host "Creating RELEASE_NOTES.md file..."
    $releaseNotes = @"
# TSplus

This release provides patched files for TSplus version $tsplusVersion with all licensing restrictions removed.

## Included Files

The following patched files are included in this archive:
- `TSplus\UserDesktop\files\APSC.exe`
- `TSplus\UserDesktop\files\AdminTool.exe`
- `TSplus\UserDesktop\files\TwoFactor.Admin.exe`
- `TSplus\UserDesktop\files\OneLicense.dll`
- `TSplus\Clients\www\cgi-bin\OneLicense.dll`

## Utility Scripts

The following utility PowerShell scripts are included to help manage TSplus:
- `Utilities\start-services.ps1` - Starts TSplus services
- `Utilities\stop-services.ps1` - Stops TSplus services
- `Utilities\tsplus-firewall-block.ps1` - Blocks TSplus activation servers in Windows Firewall
- `Utilities\tsplus-firewall-unblock.ps1` - Removes the firewall blocks

## Installation Instructions

### New Installation:

1. Download both the installer (`Setup-TSplus.exe`) and the patched files archive
2. Run the installer to complete the base TSplus installation
3. Extract the contents of the patched files archive
4. Copy and replace the extracted files to the following locations:
   - `C:\Program Files (x86)\TSplus\UserDesktop\files\`
   - `C:\Program Files (x86)\TSplus\Clients\www\cgi-bin\`
5. Restart the TSplus services (you can use the included utility scripts)

### Upgrading Existing Installation:

1. Stop all TSplus services
2. Run the setup to update your installation
3. Apply the patched files as described above
4. Restart the TSplus services

## Features Enabled

- Unlimited user connections
- All features unlocked
- No license server validation
- No expiration
"@

    $releaseNotesPath = Join-Path $structuredDir "RELEASE_NOTES.md"
    $releaseNotes | Out-File -FilePath $releaseNotesPath -Encoding utf8
    Write-Host "Release notes saved to $releaseNotesPath"
    
    # Create the archive from the structured directory
    Write-Host "Archiving structured directory to $archiveFile"
    Compress-Archive -Path "$structuredDir\*" -DestinationPath $archiveFile -Force
    
    # Verify archive was created
    if (-not (Test-Path $archiveFile)) {
        throw "Failed to create archive"
    }
    
    # Clean up the temporary structured directory
    Remove-Item -Path $structuredDir -Recurse -Force -ErrorAction SilentlyContinue
    
    # Save archive path to environment variable for release script
    [Environment]::SetEnvironmentVariable("TSPLUS_ARCHIVE_PATH", $archiveFile, "Process")
    
    # Export to GitHub Actions environment file
    if ($env:GITHUB_ENV) {
        Write-Host "::debug::Setting TSPLUS_ARCHIVE_PATH=$archiveFile in GITHUB_ENV"
        "TSPLUS_ARCHIVE_PATH=$archiveFile" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    }
    
    Write-Host "Archive created successfully at: $archiveFile"
}
catch {
    Write-Host "Error archiving working directory: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up the temporary working directory after archiving
    Write-Host "Cleaning up temporary working directory..."
    Remove-Item -Path $workDir -Recurse -Force -ErrorAction SilentlyContinue
    [Environment]::SetEnvironmentVariable("TSPLUS_WORKDIR", $null, "Process")
}
