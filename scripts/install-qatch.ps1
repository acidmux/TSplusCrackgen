$qatchRepo = "acidmux/qatch"
$qatchDir = "$env:TEMP\qatch"
$qatchDll = "$qatchDir\qatch.dll"

# Create temp directory if needed
if (-not (Test-Path $qatchDir)) {
    New-Item -ItemType Directory -Path $qatchDir | Out-Null
}

Write-Host "Downloading Qatch patching tool..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Get latest release info from GitHub API
$apiUrl = "https://api.github.com/repos/$qatchRepo/releases/latest"
$releaseInfo = Invoke-RestMethod -Uri $apiUrl -Headers @{
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# Find the asset URL for the Qatch zip (matching pattern qatch*.zip)
$zipAsset = $releaseInfo.assets | Where-Object { $_.name -like "qatch*.zip" } | Select-Object -First 1
if (-not $zipAsset) {
    throw "Could not find Qatch zip asset in the latest release"
}

Write-Host "Found Qatch asset: $($zipAsset.name)"
$zipUrl = $zipAsset.browser_download_url
$zipPath = "$qatchDir\qatch-release.zip"

# Download the zip file
Write-Host "Downloading from $zipUrl..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# Extract and clean up
Expand-Archive -Path $zipPath -DestinationPath $qatchDir -Force
Remove-Item -Path $zipPath -Force

# Verify Qatch DLL exists
if (-not (Test-Path $qatchDll)) {
    $files = Get-ChildItem -Path $qatchDir -Recurse
    Write-Host "Extracted files: $files"
    throw "Qatch DLL not found at expected path: $qatchDll"
}

Write-Host "Qatch successfully installed to $qatchDir"

# Make the path available to other steps
echo "QATCH_DIR=$qatchDir" | Out-File -FilePath $env:GITHUB_ENV -Append