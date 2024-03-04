function Get-IntuneAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TenantId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ClientId,

        [Parameter(Mandatory = $false)]
        [securestring]
        $ClientSecret
    )

    begin { }

    process {
        if (-Not $ClientSecret) {
            $scopes = @(
                "https://graph.microsoft.com/DeviceManagementApps.ReadWrite.All"
                "https://graph.microsoft.com/DeviceManagementConfiguration.ReadWrite.All"
                "https://graph.microsoft.com/DeviceManagementManagedDevices.ReadWrite.All"
                "https://graph.microsoft.com/DeviceManagementRBAC.ReadWrite.All"
                "https://graph.microsoft.com/DeviceManagementServiceConfig.ReadWrite.All"
                "https://graph.microsoft.com/Directory.Read.All"
                "https://graph.microsoft.com/Group.ReadWrite.All"
            )
            $token = Get-MsalToken -TenantId $tenantId -ClientId $clientId -Scopes $scopes
        }
        else {
            $token = Get-MsalToken -TenantId $tenantId -ClientId $clientId -ClientSecret $ClientSecret
        }

        $token.AccessToken | ConvertTo-SecureString -AsPlainText -Force
    }

    end { }
}
