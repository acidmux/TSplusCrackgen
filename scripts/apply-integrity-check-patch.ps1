# Check for admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script requires Administrator privileges to apply integrity patches." -ForegroundColor Red
    Write-Host "Please re-run this script as Administrator." -ForegroundColor Yellow
    exit 1
}

# Check if TSPLUS_WORKDIR is available from GitHub environment
$workDir = if ($env:TSPLUS_WORKDIR) { $env:TSPLUS_WORKDIR } else { [Environment]::GetEnvironmentVariable("TSPLUS_WORKDIR", "Process") }

if (-not $workDir -or -not (Test-Path $workDir)) {
    Write-Host "Error: Working directory not found. Make sure prepare-work-files.ps1 was run first." -ForegroundColor Red
    Write-Host "Current value: $workDir" -ForegroundColor Red
    exit 1
}

Write-Host "Using working directory: $workDir"

# IntegrityCheckPatch script
$targetFile1 = Join-Path $workDir "TwoFactor.Admin.exe"
$targetFile2 = Join-Path $workDir "APSC.exe"
$binDir = "$env:GITHUB_WORKSPACE\bin"

try {
    # Verify files exist
    if (-not (Test-Path $targetFile1) -or -not (Test-Path $targetFile2)) {
        throw "One or more target files not found in working directory"
    }

    # Verify and get file info
    $versionInfo1 = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($targetFile1)
    $versionInfo2 = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($targetFile2)
    Write-Host "[Target] TwoFactor.Admin.exe (Version: $($versionInfo1.FileVersion)) in working directory"
    Write-Host "[Target] APSC.exe (Version: $($versionInfo2.FileVersion)) in working directory"
    
    # Define the location of IntegrityCheckPatch tool
    $integrityCheckPatchTool = "$binDir\IntegrityCheckPatch\IntegrityCheckPatch.exe"
    
    # Execute IntegrityCheckPatch on target files
    Write-Host "Executing IntegrityCheckPatch tool..."
    & $integrityCheckPatchTool $targetFile1 $targetFile2
    
    if ($LASTEXITCODE -ne 0) {
        throw "IntegrityCheckPatch failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "Integrity check patches applied successfully"
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

