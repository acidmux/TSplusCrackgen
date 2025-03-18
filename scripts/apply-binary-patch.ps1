# Qatch-based patching script

# Check if TSPLUS_WORKDIR is available from GitHub environment
# (GitHub Actions environment variables take precedence)
$workDir = if ($env:TSPLUS_WORKDIR) { $env:TSPLUS_WORKDIR } else { [Environment]::GetEnvironmentVariable("TSPLUS_WORKDIR", "Process") }

if (-not $workDir -or -not (Test-Path $workDir)) {
    Write-Host "Error: Working directory not found. Make sure prepare-work-files.ps1 was run first." -ForegroundColor Red
    Write-Host "Current value: $workDir" -ForegroundColor Red
    exit 1
}

Write-Host "Using working directory: $workDir"
$targetFile = Join-Path $workDir "AdminTool.exe"
$qatchDir = $env:QATCH_DIR

if (-not $qatchDir) {
    Write-Host "Warning: QATCH_DIR environment variable not set, trying default location" -ForegroundColor Yellow
    $qatchDir = "C:\Users\RUNNER~1\AppData\Local\Temp\qatch"
}

$qatchDll = "$qatchDir\qatch.dll"

try {
    # Verify file exists
    if (-not (Test-Path $targetFile)) {
        throw "Target file not found at $targetFile"
    }

    # Verify and get file info
    $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($targetFile)
    Write-Host "Patching AdminTool.exe (Version: $($versionInfo.FileVersion)) in working directory"

    # Define the find/replace pattern for Qatch
    $findPattern = "0228????????2D02162A000228????????2D23"
    $replacePattern = "172A????????2D02162A000228????????2D23"

    # Execute Qatch with proper patterns
    Write-Host "Executing Qatch patching tool..."
    & dotnet "$qatchDll" --target "$targetFile" --backup --find-replace "${findPattern}:${replacePattern}"

    if ($LASTEXITCODE -ne 0) {
        throw "Qatch failed with exit code $LASTEXITCODE"
    }

    Write-Host "Patch applied successfully using Qatch"
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}