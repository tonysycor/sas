param (
    [string]$downloadedFile,
    [string]$containerName,
    [string]$blobName,
    [string]$storageAccountName,
    [string]$destinationPath
    
)


# Construct the SAS URL for the blob
$sasUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/$blobName?$blobSasToken"
# Download the CSV file
Invoke-WebRequest -Uri $sasUrl -OutFile $destinationPath

Write-Host "Downloaded CSV file from '$sasUrl' to '$destinationPath'"