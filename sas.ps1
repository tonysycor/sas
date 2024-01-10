
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

# Install and import the Az module
Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
Import-Module Az -Force 

# Connect to Azure using the service principal
$servicePrincipalSecureString = ConvertTo-SecureString $servicePrincipalKey -AsPlainText -Force
$servicePrincipalCredential = New-Object PSCredential -ArgumentList ($servicePrincipalId, $servicePrincipalSecureString)
Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Credential $servicePrincipalCredential

# Generate SAS token for the blob
#$blobSasToken = New-AzStorageBlobSASToken -Container $containerName -Blob $blobName -Permission $sasPermissions -ExpiryTime (Get-Date $sasExpiry)  -Context (New-AzStorageContext -StorageAccountName $storageAccountName)
#$blobSasToken = New-AzStorageAccountSASToken -Context $context -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission racwdlup
#$blobSasToken = New-AzStorageAccountSASToken  -Service Blob -ResourceType Service,Container,Object -Permission $sasPermissions -ExpiryTime $sasExpiry  -Context (New-AzStorageContext -StorageAccountName $storageAccountName)
$blobSasToken = New-AzStorageBlobSASToken -Container $containerName -Blob $blobName -Permission $sasPermissions -ExpiryTime $sasExpiry -Context (New-AzStorageContext -StorageAccountName $storageAccountName)
Write-Host "Generated SAS token for storage account '$storageAccountName':"
Write-Host "Generated SAS token for blob '$blobName': $blobSasToken"



# Download the CSV file
Invoke-WebRequest -Uri $blobSasToken  -OutFile $destinationPath

Write-Host "Downloaded CSV file from '$sasUrl' to '$destinationPath'"


