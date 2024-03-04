<#
 .Synopsis
  App Registration module

 .NOTES
  Module required AZ CLI.
#>

. $PSScriptRoot/private/Get-Account.ps1
. $PSScriptRoot/private/Get-ApiPermission.ps1
. $PSScriptRoot/private/Grant-AdminConsent.ps1
. $PSScriptRoot/private/Grant-ApiPermission.ps1
. $PSScriptRoot/private/New-AppCredential.ps1
. $PSScriptRoot/private/New-AppRegistration.ps1
. $PSScriptRoot/private/New-RoleAssignment.ps1
. $PSScriptRoot/private/New-ServicePrincipal.ps1
. $PSScriptRoot/private/Set-ApiPermissionAndPublicClient.ps1

. $PSScriptRoot/public/New-AppRegistrationAndServicePrincipal.ps1
. $PSScriptRoot/public/New-AzureDevOpsServiceConnection.ps1