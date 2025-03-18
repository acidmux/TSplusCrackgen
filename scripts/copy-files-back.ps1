# Check for admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please re-run this script as Administrator." -ForegroundColor Yellow
    exit 1
}

# Check if TSPLUS_WORKDIR is available from GitHub environment
$workDir = if ($env:TSPLUS_WORKDIR) { $env:TSPLUS_WORKDIR } else { [Environment]::GetEnvironmentVariable("TSPLUS_WORKDIR", "Process") }

Write-Host "Looking for working directory: $workDir"

# Resolve potential short path name issue (~1)
function Resolve-ShortPath {
    param (
        [string]$Path
    )
    
    if ($Path -match "~") {
        try {
            $resolvedPath = $Path -replace "RUNNER~1", "runneradmin"
            Write-Host "Attempting to resolve short path: $Path to $resolvedPath"
            return $resolvedPath
        }
        catch {
            Write-Host "Failed to resolve short path. Using original: $Path" -ForegroundColor Yellow
            return $Path
        }
    }
    return $Path
}

# Try to resolve short path if necessary
if ($workDir -match "~") {
    $resolvedWorkDir = Resolve-ShortPath -Path $workDir
    Write-Host "Resolved path: $resolvedWorkDir"
    if (Test-Path $resolvedWorkDir) {
        $workDir = $resolvedWorkDir
    }
}

# Try to find the working directory with fallback options
if (-not $workDir -or -not (Test-Path $workDir)) {
    Write-Host "Working directory not found at specified path. Attempting to locate it..." -ForegroundColor Yellow
    
    # Try to find TSplus directories in multiple locations
    $searchLocations = @(
        [System.IO.Path]::GetTempPath(),
        "C:\Users\runneradmin\AppData\Local\Temp\",
        "C:\Users\RUNNER~1\AppData\Local\Temp\",
        "D:\a\tsplus-crackgen\tsplus-crackgen\work\"
    )
    
    $foundDir = $null
    
    foreach ($location in $searchLocations) {
        Write-Host "Checking directory: $location"
        
        if (Test-Path $location) {
            # Look for TSplus_Work directories
            $potentialDirs = Get-ChildItem -Path $location -Directory -Filter "TSplus_Work*" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
            
            if ($potentialDirs -and $potentialDirs.Count -gt 0) {
                $foundDir = $potentialDirs[0].FullName
                Write-Host "Found working directory: $foundDir" -ForegroundColor Green
                break
            }
            
            # Also check for TSplus_Download as fallback
            $potentialDirs = Get-ChildItem -Path $location -Directory -Filter "TSplus_Download*" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
            
            if ($potentialDirs -and $potentialDirs.Count -gt 0) {
                $foundDir = $potentialDirs[0].FullName
                Write-Host "Found TSplus download directory: $foundDir" -ForegroundColor Yellow
                break
            }
        }
    }
    
    if ($foundDir) {
        $workDir = $foundDir
        
        # Update the environment variable for future steps
        $env:TSPLUS_WORKDIR = $workDir
        [Environment]::SetEnvironmentVariable("TSPLUS_WORKDIR", $workDir, "Process")
    } else {
        # If we still can't find it, create a new working directory
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $workDir = Join-Path ([System.IO.Path]::GetTempPath()) "TSplus_Work_$timestamp"
        
        Write-Host "Creating new working directory: $workDir" -ForegroundColor Yellow
        New-Item -Path $workDir -ItemType Directory -Force | Out-Null
        
        # Create subdirectories
        New-Item -Path (Join-Path $workDir "www\cgi-bin") -ItemType Directory -Force | Out-Null
        
        # Update the environment variable
        $env:TSPLUS_WORKDIR = $workDir
        [Environment]::SetEnvironmentVariable("TSPLUS_WORKDIR", $workDir, "Process")
    }
}

Write-Host "Using working directory: $workDir" -ForegroundColor Green

# Create path objects for source and target files
$wwwCgiBin = Join-Path $workDir "www\cgi-bin"
$workFile1 = Join-Path $workDir "TwoFactor.Admin.exe"
$workFile2 = Join-Path $workDir "APSC.exe"
$workFile3 = Join-Path $workDir "AdminTool.exe"
$workFile4 = Join-Path $workDir "OneLicense.dll"
$workFile5 = Join-Path $wwwCgiBin "OneLicense.dll"

# Verify that source files exist before copying
$missingFiles = @()
if (-not (Test-Path $workFile1)) { $missingFiles += "TwoFactor.Admin.exe" }
if (-not (Test-Path $workFile2)) { $missingFiles += "APSC.exe" }
if (-not (Test-Path $workFile3)) { $missingFiles += "AdminTool.exe" }
if (-not (Test-Path $workFile4)) { $missingFiles += "OneLicense.dll" }
if (-not (Test-Path $workFile5)) { $missingFiles += "www\cgi-bin\OneLicense.dll" }

if ($missingFiles.Count -gt 0) {
    Write-Host "Warning: Some required files are missing in the working directory:" -ForegroundColor Yellow
    $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    
    # Check if we can find the original files in TSplus installation
    Write-Host "Checking if we need to locate original files from TSplus installation..." -ForegroundColor Yellow
    
    # Define TSplus installation paths
    $tsplus1 = "C:\Program Files (x86)\TSplus\UserDesktop\files\TwoFactor.Admin.exe"
    $tsplus2 = "C:\Program Files (x86)\TSplus\UserDesktop\files\APSC.exe"
    $tsplus3 = "C:\Program Files (x86)\TSplus\UserDesktop\files\AdminTool.exe"
    $tsplus4 = "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll"
    $tsplus5 = "C:\Program Files (x86)\TSplus\Clients\www\cgi-bin\OneLicense.dll"
    
    # Copy original files to work directory if they exist
    if ((Test-Path $tsplus1) -and (-not (Test-Path $workFile1))) {
        Copy-Item -Path $tsplus1 -Destination $workFile1 -Force
        Write-Host "  Copied original TwoFactor.Admin.exe to work directory" -ForegroundColor Green
    }
    if ((Test-Path $tsplus2) -and (-not (Test-Path $workFile2))) {
        Copy-Item -Path $tsplus2 -Destination $workFile2 -Force
        Write-Host "  Copied original APSC.exe to work directory" -ForegroundColor Green
    }
    if ((Test-Path $tsplus3) -and (-not (Test-Path $workFile3))) {
        Copy-Item -Path $tsplus3 -Destination $workFile3 -Force
        Write-Host "  Copied original AdminTool.exe to work directory" -ForegroundColor Green
    }
    if ((Test-Path $tsplus4) -and (-not (Test-Path $workFile4))) {
        Copy-Item -Path $tsplus4 -Destination $workFile4 -Force
        Write-Host "  Copied original OneLicense.dll to work directory" -ForegroundColor Green
    }
    if ((Test-Path $tsplus5) -and (-not (Test-Path $workFile5))) {
        New-Item -Path $wwwCgiBin -ItemType Directory -Force | Out-Null
        Copy-Item -Path $tsplus5 -Destination $workFile5 -Force
        Write-Host "  Copied original OneLicense.dll (www) to work directory" -ForegroundColor Green
    }
    
    # Check again for missing files
    $missingFiles = @()
    if (-not (Test-Path $workFile1)) { $missingFiles += "TwoFactor.Admin.exe" }
    if (-not (Test-Path $workFile2)) { $missingFiles += "APSC.exe" }
    if (-not (Test-Path $workFile3)) { $missingFiles += "AdminTool.exe" }
    if (-not (Test-Path $workFile4)) { $missingFiles += "OneLicense.dll" }
    if (-not (Test-Path $workFile5)) { $missingFiles += "www\cgi-bin\OneLicense.dll" }
    
    if ($missingFiles.Count -gt 0) {
        Write-Host "Error: Still missing files after attempted recovery:" -ForegroundColor Red
        $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        Write-Host "Working directory contents:" -ForegroundColor Yellow
        Get-ChildItem -Path $workDir -Recurse | ForEach-Object { Write-Host "  - $($_.FullName.Replace($workDir, ''))" }
        
        # Continue execution - we'll create needed directories but might not have all files
        Write-Host "Will continue execution, but may not be able to copy all files." -ForegroundColor Yellow
    }
}

$targetFile1 = "C:\Program Files (x86)\TSplus\UserDesktop\files\TwoFactor.Admin.exe"
$targetFile2 = "C:\Program Files (x86)\TSplus\UserDesktop\files\APSC.exe"
$targetFile3 = "C:\Program Files (x86)\TSplus\UserDesktop\files\AdminTool.exe"
$targetFile4 = "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll"
$targetFile5 = "C:\Program Files (x86)\TSplus\Clients\www\cgi-bin\OneLicense.dll"

# Check if target directories exist
$targetDir1 = Split-Path -Parent $targetFile1
$targetDir5 = Split-Path -Parent $targetFile5
if (-not (Test-Path $targetDir1)) {
    Write-Host "Creating target directory: $targetDir1"
    New-Item -Path $targetDir1 -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $targetDir5)) {
    Write-Host "Creating target directory: $targetDir5"
    New-Item -Path $targetDir5 -ItemType Directory -Force | Out-Null
}

try {
    # Copy files if they exist
    Write-Host "Copying patched files back to original locations..."
    $copyResults = @()
    
    if (Test-Path $workFile1) {
        Copy-Item -Path $workFile1 -Destination $targetFile1 -Force
        $copyResults += "  → TwoFactor.Admin.exe → $targetFile1"
    }
    if (Test-Path $workFile2) {
        Copy-Item -Path $workFile2 -Destination $targetFile2 -Force
        $copyResults += "  → APSC.exe → $targetFile2"
    }
    if (Test-Path $workFile3) {
        Copy-Item -Path $workFile3 -Destination $targetFile3 -Force
        $copyResults += "  → AdminTool.exe → $targetFile3"
    }
    if (Test-Path $workFile4) {
        Copy-Item -Path $workFile4 -Destination $targetFile4 -Force
        $copyResults += "  → OneLicense.dll → $targetFile4"
    }
    if (Test-Path $workFile5) {
        Copy-Item -Path $workFile5 -Destination $targetFile5 -Force
        $copyResults += "  → OneLicense.dll (www) → $targetFile5"
    }
    
    if ($copyResults.Count -gt 0) {
        Write-Host "Files copied successfully:" -ForegroundColor Green
        $copyResults | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "Warning: No files were copied." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error during file copy: $_" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    
    # Continue execution even if there's an error
    Write-Host "Continuing execution despite error..." -ForegroundColor Yellow
}
# Note: We're not removing the working directory anymore as we'll archive it
