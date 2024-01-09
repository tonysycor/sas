
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
    [string]$destinationUrl
)

# Install and import the Az module
Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
Import-Module Az -Force 

# Connect to Azure using the service principal
$servicePrincipalSecureString = ConvertTo-SecureString $servicePrincipalKey -AsPlainText -Force
$servicePrincipalCredential = New-Object PSCredential -ArgumentList ($servicePrincipalId, $servicePrincipalSecureString)
Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Credential $servicePrincipalCredential

# Generate SAS token for the blob
$blobSasToken = New-AzStorageBlobSASToken -Container $containerName -Blob $blobName -Permission $sasPermissions -ExpiryTime (Get-Date $sasExpiry) -Context (New-AzStorageContext -StorageAccountName $storageAccountName)

Write-Host "Generated SAS token for blob '$blobName': $blobSasToken"
Write-Host "##vso[task.setvariable variable=blobSasToken]$blobSasToken"

