$requiredFiles = @(
  "C:\Program Files (x86)\TSplus\UserDesktop\files\APSC.exe",
  "C:\Program Files (x86)\TSplus\UserDesktop\files\AdminTool.exe",
  "C:\Program Files (x86)\TSplus\UserDesktop\files\TwoFactor.Admin.exe",
  "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll",
  "C:\Program Files (x86)\TSplus\Clients\www\cgi-bin\OneLicense.dll"
)

# First verify all required files exist
$missingFiles = @()
foreach ($file in $requiredFiles) {
  if (Test-Path $file) {
    Write-Host "✅ Verified file exists: $file"
  } else {
    Write-Host "❌ Missing file: $file"
    $missingFiles += $file
    continue
  }
}

if ($missingFiles.Count -gt 0) {
  Write-Host "Missing $($missingFiles.Count) required files. Patching verification failed."
  exit 1
}

# Check for successful patching by examining processes and services
$tsplusServices = @(
  "APSC",
  "SVCE"
)

$failedServices = @()
foreach ($service in $tsplusServices) {
  $serviceStatus = Get-Service -Name $service -ErrorAction SilentlyContinue
  if ($serviceStatus -and $serviceStatus.Status -eq 'Running') {
    Write-Host "✅ Service $service is running"
  } else {
    Write-Host "❌ Service $service is not running"
    $failedServices += $service
  }
}

if ($failedServices.Count -gt 0) {
  Write-Host "Failed to verify $($failedServices.Count) services. Patching verification failed."
  exit 1
}