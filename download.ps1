param (
    [string]$downloadedFile,
    [string]$containerName,
    [string]$blobName,
    [string]$storageAccountName
    
)

$destinationPath = "$(Build.ArtifactStagingDirectory)\$downloadedFile"
# Construct the SAS URL for the blob
$sasUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/$blobName?$blobSasToken"
# Download the CSV file
Invoke-WebRequest -Uri $sasUrl -OutFile $destinationPath

Write-Host "Downloaded CSV file from '$sasUrl' to '$destinationPath'"