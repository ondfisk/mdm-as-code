<#
 .Synopsis
  Intune module

 .NOTES
  Module requires the MSAL.PS and Logging module.
#>

. $PSScriptRoot/private/ConvertFrom-ConfigurationFileName.ps1
. $PSScriptRoot/private/Get-Assignment.ps1
. $PSScriptRoot/private/Get-DeviceCompliancePolicy.ps1
. $PSScriptRoot/private/Get-FolderName.ps1
. $PSScriptRoot/private/Get-FolderNameFromODataType.ps1
. $PSScriptRoot/private/Get-GroupPolicyConfiguration.ps1
. $PSScriptRoot/private/Get-Intent.ps1
. $PSScriptRoot/private/Get-Template.ps1
. $PSScriptRoot/private/New-MetaFile.ps1
. $PSScriptRoot/private/Sync-Assignment.ps1
. $PSScriptRoot/private/Sync-GroupPolicyConfigurationDefinitionValue.ps1
. $PSScriptRoot/private/Sync-IntentSetting.ps1
. $PSScriptRoot/private/Update-Configuration.ps1

. $PSScriptRoot/public/Get-IntuneAccessToken.ps1
. $PSScriptRoot/public/Get-IntuneGroup.ps1
. $PSScriptRoot/public/Export-IntuneConfiguration.ps1
. $PSScriptRoot/public/Import-IntuneConfiguration.ps1
. $PSScriptRoot/public/Import-IntuneGroup.ps1
. $PSScriptRoot/public/Invoke-IntuneGraphApi.ps1
. $PSScriptRoot/public/Remove-IntuneConfiguration.ps1
. $PSScriptRoot/public/Sync-IntuneConfiguration.ps1
