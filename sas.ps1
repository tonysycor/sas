
# Authenticate with Azure using service principal credentials

az login --service-principal -t=$servicePrincipalTenantId  -u=$servicePrincipalId -p=$servicePrincipalKey 
$storage_account_key = az storage account keys list --resource-group $resourcegroup --account-name $storageAccountName --query '[0].value' --output tsv

# Create a SAS token for the blob container
$sas_token = az storage container generate-sas `
  --name $containerName `
  --expiry (Get-Date).AddHours(1).ToString("yyyy-MM-ddTHH:mm:ssZ") `
  --permissions "racwdl" `
  --account-key $storage_account_key `
  --account-name $storageAccountName `
  --output tsv
# Print the generated SAS token
Write-Output "Generated SAS Token:"
Write-Host "Generated SAS token: $sas_Token"