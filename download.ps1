param (
    [string]$downloadedFile,
    [string]$containerName,
    [string]$blobName,
    [string]$storageAccountName,
    [string]$destinationPath
    
)

Write-Host "storageAccountName: $storageAccountName"
Write-Host "containerName: $containerName"
Write-Host "blobName: $blobName"
Write-Host "blobSasToken: $blobSasToken"

# Construct the SAS URL for the blob
$sasUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/$blobName$($blobSasToken)"
Write-Host "Constructed SAS URL: $sasUrl"

# Download the CSV file
Invoke-WebRequest -Uri $sasUrl -OutFile $destinationPath

Write-Host "Downloaded CSV file from '$sasUrl' to '$destinationPath'"