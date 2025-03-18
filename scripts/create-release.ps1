# Create a GitHub release with patched files and the original installer

# Get required environment variables
$tsplusVersion = $env:TSPLUS_VERSION
$tsplusSetupPath = $env:TSPLUS_SETUP_PATH
$archivePath = $env:TSPLUS_ARCHIVE_PATH

# Validate required variables
if (-not $tsplusVersion) {
    Write-Host "##[error]TSplus version not found in environment."
    exit 1
}

if (-not $tsplusSetupPath -or -not (Test-Path $tsplusSetupPath)) {
    Write-Host "##[error]TSplus setup path not found or invalid: $tsplusSetupPath"
    exit 1
}

if (-not $archivePath -or -not (Test-Path $archivePath)) {
    Write-Host "##[error]Archive path not found or invalid: $archivePath"
    exit 1
}

# Use the version directly as the tag
$releaseTag = "v$tsplusVersion"

# Save the tag to a file so it can be used by subsequent steps
$releaseTag | Out-File -FilePath "$env:RUNNER_TEMP/release_tag.txt"
Write-Host "Saved release tag to $env:RUNNER_TEMP/release_tag.txt: $releaseTag"

# Check if the release already exists
try {
    $releaseExists = $false
    $releaseCheck = gh release view $releaseTag 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "##[error]Release $releaseTag already exists. Exiting."
        exit 1
    }
}
catch {
    Write-Host "##[error]Error checking for existing release: $_"
    exit 1
}

# Create the release
try {
    Write-Host "Creating GitHub release with tag: $releaseTag"
    
    # Explicitly authenticate gh CLI using GITHUB_TOKEN
    Write-Host "Authenticating GitHub CLI"
    $env:GITHUB_TOKEN | gh auth login --with-token
    
    # Get archive filename for the release notes
    $archiveFileName = [System.IO.Path]::GetFileName($archivePath)
    
    # Create release notes
    $releaseNotes = @"
# TSplus (Setup+Crack)

This release provides patched files for TSplus version $tsplusVersion with all licensing restrictions removed.

## Included Assets

- **Setup-TSplus.exe**: Original TSplus setup (unmodified)
- **$archiveFileName**: Contains all patched files required for activation

## Installation Instructions

### New Installation:

1. Download both the installer (`Setup-TSplus.exe`) and the patched files archive
2. Run the installer to complete the base TSplus installation
3. Extract the contents of the patched files archive
4. Copy and replace the extracted files to the following locations:
   - `C:\Program Files (x86)\TSplus\UserDesktop\files\`
   - `C:\Program Files (x86)\TSplus\Clients\www\cgi-bin\`
5. Restart the TSplus services

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

    # Create the release
    $releaseResult = gh release create $releaseTag `
        --title "TSplus v$tsplusVersion" `
        --notes "$releaseNotes" `
        --draft
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create release: $releaseResult"
    }
    
    # Upload the patched files archive
    Write-Host "Uploading patched files archive as $archiveFileName..."
    gh release upload $releaseTag $archivePath --clobber
    
    # NOTE: The installer upload is now handled by a dedicated workflow step
    # that uses the tag saved to the file system
    
    # Publish the release
    gh release edit $releaseTag --draft=false
    
    # Generate the release URL for easy access
    $releaseUrl = "https://github.com/$env:GITHUB_REPOSITORY/releases/tag/$([uri]::EscapeDataString($releaseTag))"
    Write-Host "Release URL: $releaseUrl"
    
    Write-Host "Release created and published successfully: $releaseTag" -ForegroundColor Green
}
catch {
    Write-Host "##[error]Error creating release: $_"
    exit 1
}
