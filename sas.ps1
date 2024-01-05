Connect-AzAccount -ServicePrincipal -Tenant $env:servicePrincipalTenantId -ApplicationId $env:servicePrincipalId -CertificateThumbprint $env:servicePrincipalKey -ServicePrincipal

$sasToken = az storage blob generate-sas --account-name $storageAccountName --container-name $containerName --name $blobName --permissions $sasPermissions --expiry $sasExpiry --output tsv

Write-Host "Generated SAS token: $sasToken"