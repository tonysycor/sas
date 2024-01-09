param (
    [string]$downloadedFile,
    [string]$containerName,
    [string]$blobName,
    [string]$storageAccountName,
    [string]$destinationPath,
    [string]$destinationUrl
    
)

Write-Host "storageAccountName: $storageAccountName"
Write-Host "containerName: $containerName"
Write-Host "blobName: $blobName"
$blobSasToken1 = "$($blobSasToken)"

Write-Host "blobSasToken in download.ps1: $blobSasToken1"
Write-Host "blobSasToken: $blobSasToken"

# Construct the SAS URL for the blob
$sasUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/$blobName$($blobSasToken1)"

Write-Host "Constructed SAS URL: $sasUrl"

# Download the CSV file
Invoke-WebRequest -Uri $sasUrl -OutFile $destinationPath

Write-Host "Downloaded CSV file from '$sasUrl' to '$destinationPath'"
