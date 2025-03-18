# Calculate expiration date (1 year from now)
$expirationDate = (Get-Date).AddYears(1).ToString("yyyy/MM/dd HH:mm:ss")
Write-Host "Setting license expiration date to: $expirationDate"

# Create the license file content
$licenseContent = @"
; Warning: any change in this file will invalidate this license
[Main]
ComputerID=<REPLACE_WITH_PLACEHOLDER>
HardwareID=<REPLACE_WITH_PLACEHOLDER>

[Product.Remote]
Edition=Enterprise
Users=50
Type=permanent
Expires=$expirationDate

[Support.Remote]
Expires=$expirationDate

[Product.Security]
Edition=Ultimate
Type=permanent
Expires=$expirationDate

[Product.TwoFA]
Edition=
Type=permanent
Expires=$expirationDate

[Product.SMonitoring]
Users=50
Type=permanent
Expires=$expirationDate

[Signature]
Signature=PLACEHOLDER_SIGNATURE
"@

# Save the license file
$licenseFilePath = Join-Path $env:RUNNER_TEMP "license.lic"
$licenseContent | Out-File -FilePath $licenseFilePath -Encoding ASCII

Write-Host "License template created at: $licenseFilePath"
