# Check for admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please re-run this script as Administrator." -ForegroundColor Yellow
    exit 1
}

# Create a working directory in TEMP
$workDir = Join-Path $env:TEMP "TSplus_Work_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $workDir -Force | Out-Null
Write-Host "Created working directory: $workDir"

# Create nested directory structure for web files
$wwwCgiBin = Join-Path $workDir "www\cgi-bin"
New-Item -ItemType Directory -Path $wwwCgiBin -Force | Out-Null
Write-Host "Created www\cgi-bin directory: $wwwCgiBin"

try {
    # Define source and target file paths
    $sourceFile1 = "C:\Program Files (x86)\TSplus\UserDesktop\files\TwoFactor.Admin.exe"
    $sourceFile2 = "C:\Program Files (x86)\TSplus\UserDesktop\files\APSC.exe"
    $sourceFile3 = "C:\Program Files (x86)\TSplus\UserDesktop\files\AdminTool.exe"
    $sourceFile4 = "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll"
    $sourceFile5 = "C:\Program Files (x86)\TSplus\Clients\www\cgi-bin\OneLicense.dll"
    
    $targetFile1 = Join-Path $workDir "TwoFactor.Admin.exe"
    $targetFile2 = Join-Path $workDir "APSC.exe"
    $targetFile3 = Join-Path $workDir "AdminTool.exe"
    $targetFile4 = Join-Path $workDir "OneLicense.dll"
    $targetFile5 = Join-Path $wwwCgiBin "OneLicense.dll"
    
    # Copy files to working directory
    Write-Host "Copying TSplus files to working directory..."
    Copy-Item -Path $sourceFile1 -Destination $targetFile1
    Copy-Item -Path $sourceFile2 -Destination $targetFile2
    Copy-Item -Path $sourceFile3 -Destination $targetFile3
    Copy-Item -Path $sourceFile4 -Destination $targetFile4
    Copy-Item -Path $sourceFile5 -Destination $targetFile5
    
    # Verify files were copied
    $files = Get-ChildItem -Path $workDir -File -Recurse
    foreach ($file in $files) {
        $fileSize = [math]::Round($file.Length / 1KB, 2)
        Write-Host "Copied $($file.Name) ($fileSize KB) to $($file.Directory)"
    }
    
    # Store working directory path in environment variable for other scripts
    [Environment]::SetEnvironmentVariable("TSPLUS_WORKDIR", $workDir, "Process")
    
    # Export to GitHub Actions environment file
    if ($env:GITHUB_ENV) {
        Write-Host "::debug::Setting TSPLUS_WORKDIR=$workDir in GITHUB_ENV"
        "TSPLUS_WORKDIR=$workDir" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    }
    
    # Save the path to a file that can be accessed across jobs
    if ($env:RUNNER_TEMP) {
        $workDirFile = Join-Path $env:RUNNER_TEMP "tsplus_workdir.txt"
        Write-Host "Saving working directory path to file: $workDirFile"
        $workDir | Out-File -FilePath $workDirFile -Encoding utf8 -Force
    }
    
    Write-Host "Files prepared successfully in working directory: $workDir"
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
