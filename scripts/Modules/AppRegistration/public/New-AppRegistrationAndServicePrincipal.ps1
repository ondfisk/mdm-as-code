$graphApiAppId = "00000003-0000-0000-c000-000000000000"
$requiredPermissionValues = @{
    App  = @(
        "DeviceManagementApps.ReadWrite.All"
        "DeviceManagementConfiguration.ReadWrite.All"
        "DeviceManagementManagedDevices.ReadWrite.All"
        "DeviceManagementRBAC.ReadWrite.All"
        "DeviceManagementServiceConfig.ReadWrite.All"
        "Directory.Read.All"
        "Group.ReadWrite.All"
    )
    User = @(
        "DeviceManagementApps.ReadWrite.All"
        "DeviceManagementConfiguration.ReadWrite.All"
        "DeviceManagementManagedDevices.ReadWrite.All"
        "DeviceManagementRBAC.ReadWrite.All"
        "DeviceManagementServiceConfig.ReadWrite.All"
        "Directory.Read.All"
        "Group.ReadWrite.All"
        "User.Read"
    )
}

function New-AppRegistrationAndServicePrincipal {
    <#
        .SYNOPSIS
        Create or update app registration for Intune

        .DESCRIPTION
        Create or update app registration with service principal and Azure DevOps service connection for Intune.
        If an existing app registration exists a new password will be generated if either:
        - No existing password.
        - Password has expired.
        - Password will expire within 60 days.
        You must be logged in to the Intune Tenant subscription with 'az login --tenant [Tenant]' prior to running the script.

        .PARAMETER DisplayName
        App Registration display name

        .PARAMETER Role
        The role to assign to the current Azure subscription

        .PARAMETER Grant
        If supplied, the app registration API permissions will be granted admin consent.
        Requires 'Global Administrator' privileges.
        If not supplied, a 'Global Administrator' must 'Grant admin consent' for the app registration to work.

        .PARAMETER ResetPassword
        If supplied any existing passwords will be replaced and the new generated password will be returned

        .OUTPUTS
        psobject. New-AppRegistrationAndServicePrincipal returns an object with properties required to manually setup and Azure DevOps service connection.

        .LINK
        AZ CLI: https://aka.ms/azcli
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $DisplayName,

        [ValidateSet("Reader", "Contributor", "Owner", "User Access Administrator")]
        [string]
        $Role = "Reader",

        [switch]
        $Grant,

        [switch]
        $ResetPassword
    )

    begin { }

    process {
        Write-Progress -Activity "Creating App Registration and Service Principal" -Status "Creating app registration..." -PercentComplete 0

        $app = New-AppRegistration -DisplayName $DisplayName

        # Waiting for app registration to be ready
        Start-Sleep -Seconds 5

        Write-Progress -Activity "Creating App Registration and Service Principal" -Status "Creating credential..." -PercentComplete 12

        if ($ResetPassword) {
            $password = New-AppCredential -AppId $app.appId -Force
        }
        else {
            $password = New-AppCredential -AppId $app.appId
        }

        Write-Progress -Activity "Creating App Registration and Service Principal" -Status "Getting required API permissions..." -PercentComplete 24

        $permissions = Get-ApiPermission -Api $graphApiAppId -AppPermission $requiredPermissionValues.App -UserPermission $requiredPermissionValues.User

        Write-Progress -Activity "Creating App Registration and Service Principal" -Status "Setting API permissions and public client..." -PercentComplete 36

        Set-ApiPermissionAndPublicClient -ObjectId $app.objectId -Api $graphApiAppId -Permission $permissions

        Write-Progress -Activity "Creating App Registration and Service Principal" -Status "Creating service principal..." -PercentComplete 48

        $sp = New-ServicePrincipal -AppId $app.appId

        if ($Grant) {
            Write-Progress -Activity "Creating App Registration and Service Principal" -Status "Granting admin consent..." -PercentComplete 60

            # Waiting for permissions to be ready
            Start-Sleep -Seconds 10

            Grant-ApiPermission -ServicePrincipalObjectId $sp.objectId -Api $graphApiAppId -Permission $requiredPermissionValues.User

            Grant-AdminConsent -AppId $app.appId
        }
        else {
            # Waiting for service principal to be ready
            Start-Sleep -Seconds 5
        }

        Write-Progress -Activity "Creating App Registration and Service Principal" -Status "Getting subscription info..." -PercentComplete 72

        $account = Get-Account

        Write-Progress -Activity "Creating App Registration and Service Principal" -Status "Creating subscription role assignment..." -PercentComplete 84

        New-RoleAssignment -ObjectId $sp.objectId -Role $Role

        Write-Progress -Activity "Creating App Registration and Service Principal" -PercentComplete 100 -Completed

        [pscustomobject]@{
            TenantId                 = $account.TenantId
            SubscriptionId           = $account.SubscriptionId
            SubscriptionName         = $account.SubscriptionName
            AppId                    = $app.appId
            ServicePrincipalObjectId = $sp.objectId
            Password                 = $password
        }
    }

    end { }
}
