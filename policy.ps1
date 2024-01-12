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
    [string]$destinationUrl,
    [string]$resourceGroupName,
    [string]$myHelp
    
    


)



# Read the CSV file
$policyCsv = Import-Csv -Path $myHelp


# Initialize an array to store management scopes
$managementScopes = @()

# Iterate over each row in the CSV and extract the management scope
foreach ($row in $policyCsv) {
    $managementScopes += $row.management_scope
}


# Connect to Azure using the service principal
$servicePrincipalSecureString = ConvertTo-SecureString $servicePrincipalKey -AsPlainText -Force
$servicePrincipalCredential = New-Object PSCredential -ArgumentList ($servicePrincipalId, $servicePrincipalSecureString)
Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Credential $servicePrincipalCredential
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName


# Generate SAS token
#$sasToken = New-AzStorageBlobSASToken -Container $storageContainer.Name -Blob $storageBlob.Name -Permission rwdlacuptf  -Context $storageAccount.Context
$sasToken = New-AzStorageAccountSASToken -Service Blob -ResourceType Service,Container,Object -Permission "rl" -ExpiryTime (Get-Date).AddDays(1) -Context $storageAccount.Context
# Define the URL and SAS token parameters
$url = ""  # Replace with your actual URL
Write-host  "Sas: $sasToken"

# Initialize an array to store the results
$results = @()

# Iterate over each row in the CSV to make HTTP requests
foreach ($row in $policyCsv) {
    
    $url = $row.url
  
    $urlWithSas = $url + "?" + $sasToken
    Write-host  "Full Url: $urlWithSas"
    
    # Make HTTP request
   try {

       
        $response = Invoke-RestMethod -Uri $urlWithSas -Method Get -Headers @{ Accept = "application/json" }
       
        Write-host  "Policies: $response"
         $mergedData = [PSCustomObject]@{
            Name = $row.Name
            Type = $row.Type
            parameters_value =$row.parameters
            possible_scopes=$row.posssible_scopes
            management_scope = $row.management_scope
            displayName = $response.displayName
            customType = $response.customType
            description = $response.description
            metadata = $response.metadata
            parameters =$response.parameters
            policyRule =$response.policyRule
            # Add other properties from $row
            # Add properties from $response
           ResponseData = $response
        }

        # Merge data from CSV and HTTP response
        #$mergedData = $row | Select-Object *, @{Name="management_group"; Expression={$managementScopes[-1]}}, * -ExcludeProperty name, management_scope
        #$row.parameters = ConvertFrom-Json $row.parameters  # Convert JSON string to PowerShell object
        $results += $mergedData
    }
    catch {
       Write-Host "Error making HTTP request for $($row.name): $_"
   }
}
$jsonData = $results | ConvertTo-Json
$outputFilePath = "$destinationUrl\Policies.json"
# Output SAS token

$jsonData | Set-Content -Path $outputFilePath
Write-Host "SAS token saved to: $outputFilePath"


