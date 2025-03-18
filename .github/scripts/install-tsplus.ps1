Write-Host "Installing TSplus..."
try {
  # Get the setup file path from the environment variable
  $setupPath = $env:TSPLUS_SETUP_PATH
  
  if (-not $setupPath -or -not (Test-Path $setupPath)) {
    Write-Error "Setup file not found. Please make sure the download script ran successfully."
    Write-Host "Expected path: $setupPath"
    Write-Host "Current directory: $(Get-Location)"
    exit 1
  }
  
  Write-Host "Using setup file: $setupPath"
  
  # Set a timeout for installation (30 minutes)
  $process = Start-Process -FilePath $setupPath -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/Addons=yes' -PassThru
  $timeoutSeconds = 1800
  
  # Wait with timeout
  if (-not $process.WaitForExit($timeoutSeconds * 1000)) {
    Write-Warning "Installation timed out after $timeoutSeconds seconds"
    $process.Kill()
    throw "Installation timed out"
  }
  
  if ($process.ExitCode -ne 0) {
    throw "Installation failed with exit code: $($process.ExitCode)"
  }
  
  Write-Host "TSplus installation completed successfully with exit code: $($process.ExitCode)"
}
catch {
  Write-Error "Error during installation: $_"
  exit 1
}