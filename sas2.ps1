
# Authenticate with Azure using service principal credentials
param (
    [string]$servicePrincipalId,
    [string]$servicePrincipalKey,
    [string]$tenantId,
    [string]$storageAccountName,
    [string]$containerName,
    [string]$blobName,
    [string]$sasPermissions,
    [string]$sasExpiry,
    [string]$destinationPath,
    [string]$resourceGroupName
    


)
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName

# Get Storage Container
$storageContainer = Get-AzStorageContainer -Context $storageAccount.Context -Name $containerName

# Get Storage Blob
$storageBlob = Get-AzStorageBlob -Container $storageContainer.Name -Blob $blobName -Context $storageAccount.Context
# Generate SAS token
$sasToken = New-AzStorageBlobSASToken -Container $storageContainer.Name -Blob $storageBlob.Name -Permission rwdl -Context $storageAccount.Context

# Download Blob content using SAS token
$blobUrlWithSas = $storageBlob.ICloudBlob.Uri + $sasToken
$blobContent = Invoke-RestMethod -Uri $blobUrlWithSas -Method Get



# Output SAS token
Write-Output "SAS Token: $sasToken"
# Save content to a local file
Set-Content -Path $destinationPath\$blobName -Value $blobContent
# Save content to a local file
