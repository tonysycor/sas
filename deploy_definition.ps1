param (
    
    [string]$servicePrincipalId ,
    [string]$servicePrincipalKey,
    [string]$tenantId,
    [string]$policyfile,
    [string]$companyManagemntScope
    
)





# Convert CSV content to PowerShell objects
$policies = ConvertFrom-Csv $policyfile



Connect-AzAccount -ServicePrincipal -Tenant $tenantId -ApplicationId $servicePrincipalId -CertificateThumbprint $servicePrincipalKey -ServicePrincipal

# Loop through each row in the CSV and create policy definitions with remediation
foreach ($policy in $policies) {
    $policyName = $policy.Name
    $policyRule = ConvertFrom-Json $policy.Parameters
    $managementScope = $policy.Management_Scope

    # Conditionally set $managementGroupId based on $managementScope
    switch ($managementScope) {
        "Company" {
            $managementGroupId = $companyManagemntScope
        }
        default {
            $managementGroupId = $managementScope
        }
    }

    $definition = @{
        DisplayName = $policyName
        PolicyRule  = $policyRule
        Mode        = 'All'
    }

    $policyDefinition = New-AzPolicyDefinition @definition
    $policyAssignment = New-AzPolicyAssignment -Name $policyName -PolicyDefinition $policyDefinition -Scope "/providers/Microsoft.Management/managementGroups/$managementGroupId"

    # Check if remediation is specified in the CSV
    if ($policy.Remediation) {
        $remediationTask = @{
            DisplayName = "RemediationTask-$policyName"
            PolicyAssignmentId = $policyAssignment.ResourceId
            PolicyDefinitionReferenceId = $policyDefinition.PolicyDefinitionId
        }

        $remediationTask = New-AzPolicyRemediationTask @remediationTask
        Write-Host "Created policy definition, assignment, and remediation for '$policyName' in management group '$managementGroupId'"
    }
    else {
        Write-Host "Created policy definition and assignment for '$policyName' in management group '$managementGroupId'"
    }
}