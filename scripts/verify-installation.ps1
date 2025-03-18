
$requiredFiles = @(
  "C:\Program Files (x86)\TSplus\UserDesktop\files\APSC.exe",
  "C:\Program Files (x86)\TSplus\UserDesktop\files\AdminTool.exe",
  "C:\Program Files (x86)\TSplus\UserDesktop\files\TwoFactor.Admin.exe",
  "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll",
  "C:\Program Files (x86)\TSplus\Clients\www\cgi-bin\OneLicense.dll"
)

$missingFiles = @()

foreach ($file in $requiredFiles) {
  if (Test-Path $file) {
    Write-Host "✅ Verified: $file"
  } else {
    Write-Host "❌ Missing: $file"
    $missingFiles += $file
  }
}

if ($missingFiles.Count -gt 0) {
  Write-Host "Missing $($missingFiles.Count) required files."
  foreach ($file in $missingFiles) {
    Write-Host "  - $file"
  }
  exit 1
}

Write-Host "All required TSplus files verified successfully."