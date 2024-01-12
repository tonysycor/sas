
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
#Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
#Import-Module Az -Force 

# Connect to Azure using the service principal
$servicePrincipalSecureString = ConvertTo-SecureString $servicePrincipalKey -AsPlainText -Force
$servicePrincipalCredential = New-Object PSCredential -ArgumentList ($servicePrincipalId, $servicePrincipalSecureString)
Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Credential $servicePrincipalCredential
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName

# Get Storage Container
$storageContainer = Get-AzStorageContainer -Context $storageAccount.Context -Name $containerName

# Get Storage Blob
$storageBlob = Get-AzStorageBlob -Container $storageContainer.Name -Blob $blobName -Context $storageAccount.Context
# Generate SAS token
$sasToken = New-AzStorageBlobSASToken -Container $storageContainer.Name -Blob $storageBlob.Name -Permission rwdl -Context $storageAccount.Context
Write-Output "SAS Token: $sasToken"
$outputFilePath = "$destinationPath\sas.txt"
# Download Blob content using SAS token
$blobUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/$blobName"
$blobUrlWithSas = $blobUrl  + "?" + $sasToken
Write-Output "Full url with Sas: $blobUrlWithSas"
Invoke-WebRequest -Uri $blobUrlWithSas  -OutFile $destinationPath\$blobName 

$sasToken | Set-Content -Path $outputFilePath
# Output SAS token
Write-Host "SAS token saved to: $outputFilePath"

