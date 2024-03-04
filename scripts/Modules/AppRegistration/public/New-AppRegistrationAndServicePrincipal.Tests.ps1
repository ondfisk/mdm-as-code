BeforeAll {
    . $PSScriptRoot\..\private\New-AppRegistration.ps1
    . $PSScriptRoot\..\private\New-AppCredential.ps1
    . $PSScriptRoot\..\private\Get-ApiPermission.ps1
    . $PSScriptRoot\..\private\Set-ApiPermissionAndPublicClient.ps1
    . $PSScriptRoot\..\private\Grant-AdminConsent.ps1
    . $PSScriptRoot\..\private\Grant-ApiPermission.ps1
    . $PSScriptRoot\..\private\New-ServicePrincipal.ps1
    . $PSScriptRoot\..\private\Get-Account.ps1
    . $PSScriptRoot\..\private\New-RoleAssignment.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "New-AppRegistrationAndServicePrincipal" {
    Context "Given valid input" {
        BeforeAll {
            Mock Write-Progress { }
            Mock Start-Sleep { }
            Mock New-AppRegistration {
                [pscustomobject]@{
                    appId    = "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
                    objectId = "10522b33-42c5-49ba-adba-805a69b03ad7"
                }
            }
            Mock New-AppCredential { "35d32bc5-505c-45dc-ad14-f31ea540aa32" | ConvertTo-SecureString -AsPlainText -Force }
            $permissions = @([pscustomobject]@{ })
            Mock Get-ApiPermission { $permissions }
            Mock Set-ApiPermissionAndPublicClient { }
            Mock Grant-ApiPermission { }
            Mock Grant-AdminConsent { }
            Mock New-ServicePrincipal {
                [pscustomobject]@{
                    appId    = "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
                    objectId = "8dc5b0e1-0e06-4f64-a04b-0403dd8238ed"
                }
            }
            Mock Get-Account {
                [pscustomobject]@{
                    TenantId         = "45f6b7ec-c94a-40ca-bd4b-e9de5441efc7"
                    SubscriptionName = "My Subscription"
                    SubscriptionId   = "7512cf52-57c0-400f-9aa1-d4d41d389956"
                }
            }
            Mock New-RoleAssignment { }
        }

        It "It creates app registration" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            Should -Invoke New-AppRegistration -ParameterFilter {
                $DisplayName -eq "IntuneApp"
            }
        }

        It "It creates app credential" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            Should -Invoke New-AppCredential -ParameterFilter {
                $AppId -eq "f1af2fc6-5650-471b-acbb-3d1e5ae00900" -and
                $Existing -eq $null
            }
        }

        It "It gets API permissions" {
            New-AppRegistrationAndServicePrincipal -DisplayName "Intune"

            Should -Invoke Get-ApiPermission -ParameterFilter {
                $Api -eq "00000003-0000-0000-c000-000000000000"
                $AppPermission[0] -eq "DeviceManagementApps.ReadWrite.All" -and
                $AppPermission[1] -eq "DeviceManagementConfiguration.ReadWrite.All" -and
                $AppPermission[2] -eq "DeviceManagementManagedDevices.ReadWrite.All" -and
                $AppPermission[3] -eq "DeviceManagementRBAC.ReadWrite.All" -and
                $AppPermission[4] -eq "DeviceManagementServiceConfig.ReadWrite.All" -and
                $AppPermission[5] -eq "Directory.Read.All" -and
                $AppPermission[6] -eq "Group.Read.All" -and
                $UserPermission[0] -eq "DeviceManagementApps.ReadWrite.All" -and
                $UserPermission[1] -eq "DeviceManagementConfiguration.ReadWrite.All" -and
                $UserPermission[2] -eq "DeviceManagementManagedDevices.ReadWrite.All" -and
                $UserPermission[3] -eq "DeviceManagementRBAC.ReadWrite.All" -and
                $UserPermission[4] -eq "DeviceManagementServiceConfig.ReadWrite.All" -and
                $UserPermission[5] -eq "Directory.Read.All" -and
                $UserPermission[6] -eq "Group.Read.All" -and
                $UserPermission[7] -eq "User.Read"
            }
        }

        It "It sets API permissions and public client" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            Should -Invoke Set-ApiPermissionAndPublicClient -ParameterFilter {
                $ObjectId -eq "10522b33-42c5-49ba-adba-805a69b03ad7" -and
                $Api -eq "00000003-0000-0000-c000-000000000000" -and
                $Permission[0] -ne $null
            }
        }

        It "It creates service principal" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            Should -Invoke New-ServicePrincipal -ParameterFilter {
                $AppId -eq "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
            }
        }

        It "It does not grant API permissions" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            Should -Not -Invoke Grant-ApiPermission
        }

        It "It does not grant admin consent" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            Should -Not -Invoke Grant-AdminConsent
        }

        It "It gets account" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            Should -Invoke Get-Account
        }

        It "It creates role assignment" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            Should -Invoke New-RoleAssignment -ParameterFilter {
                $ObjectId -eq "8dc5b0e1-0e06-4f64-a04b-0403dd8238ed" -and
                $Role -eq "Reader"
            }
        }

        It "It returns appId" {
            $app = New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            $app.AppId | Should -Be "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
        }

        It "It returns password" {
            $app = New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            $app.Password | ConvertFrom-SecureString -AsPlainText | Should -Be "35d32bc5-505c-45dc-ad14-f31ea540aa32"
        }

        It "It returns service principal object id" {
            $app = New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            $app.ServicePrincipalObjectId | Should -Be "8dc5b0e1-0e06-4f64-a04b-0403dd8238ed"
        }

        It "It returns tenant id" {
            $app = New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            $app.TenantId | Should -Be "45f6b7ec-c94a-40ca-bd4b-e9de5441efc7"
        }

        It "It returns subscription name" {
            $app = New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            $app.SubscriptionName | Should -Be "My Subscription"
        }

        It "It returns subscription id" {
            $app = New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp"

            $app.SubscriptionId | Should -Be "7512cf52-57c0-400f-9aa1-d4d41d389956"
        }
    }

    Context "Given Grant" {
        BeforeAll {
            Mock Write-Progress { }
            Mock Start-Sleep { }
            Mock New-AppRegistration {
                [pscustomobject]@{
                    appId    = "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
                    objectId = "10522b33-42c5-49ba-adba-805a69b03ad7"
                }
            }
            Mock New-AppCredential { }
            Mock Get-ApiPermission { }
            Mock Set-ApiPermissionAndPublicClient { }
            Mock Grant-ApiPermission { }
            Mock Grant-AdminConsent { }
            Mock New-ServicePrincipal {
                [pscustomobject]@{
                    appId    = "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
                    objectId = "8dc5b0e1-0e06-4f64-a04b-0403dd8238ed"
                }
            }
            Mock Get-Account { }
            Mock New-RoleAssignment { }
        }

        It "It grants api permissions" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp" -Grant

            Should -Invoke Grant-ApiPermission -ParameterFilter {
                $ServicePrincipalObjectId -eq "8dc5b0e1-0e06-4f64-a04b-0403dd8238ed" -and
                $Api -eq "00000003-0000-0000-c000-000000000000" -and
                $Permission[0] -eq "DeviceManagementApps.ReadWrite.All" -and
                $Permission[1] -eq "DeviceManagementConfiguration.ReadWrite.All" -and
                $Permission[2] -eq "DeviceManagementManagedDevices.ReadWrite.All" -and
                $Permission[3] -eq "DeviceManagementRBAC.ReadWrite.All" -and
                $Permission[4] -eq "DeviceManagementServiceConfig.ReadWrite.All" -and
                $Permission[5] -eq "Directory.Read.All" -and
                $Permission[6] -eq "Group.ReadWrite.All" -and
                $Permission[7] -eq "User.Read"
            }
        }

        It "It grants admin consent" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp" -Grant

            Should -Invoke Grant-AdminConsent -ParameterFilter {
                $AppId -eq "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
            }
        }
    }

    Context "Given ResetPassword" {
        BeforeAll {
            Mock Write-Progress { }
            Mock Start-Sleep { }
            Mock New-AppRegistration {
                [pscustomobject]@{
                    appId    = "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
                    objectId = "10522b33-42c5-49ba-adba-805a69b03ad7"
                }
            }
            $newPassword = "3888edac-16fc-4af2-9375-a46f9e968348" | ConvertTo-SecureString -AsPlainText -Force
            Mock New-AppCredential { $newPassword }
            Mock Get-ApiPermission { }
            Mock Set-ApiPermissionAndPublicClient { }
            Mock Grant-AdminConsent { }
            Mock New-ServicePrincipal {
                [pscustomobject]@{
                    appId    = "f1af2fc6-5650-471b-acbb-3d1e5ae00900"
                    objectId = "8dc5b0e1-0e06-4f64-a04b-0403dd8238ed"
                }
            }
            Mock Get-Account {
                [pscustomobject]@{
                    TenantId         = "45f6b7ec-c94a-40ca-bd4b-e9de5441efc7"
                    SubscriptionName = "My Subscription"
                    SubscriptionId   = "7512cf52-57c0-400f-9aa1-d4d41d389956"
                }
            }
            Mock New-RoleAssignment { }
        }

        It "It resets credential" {
            New-AppRegistrationAndServicePrincipal -DisplayName "IntuneApp" -ResetPassword

            Should -Invoke New-AppCredential -ParameterFilter {
                $AppId -eq "f1af2fc6-5650-471b-acbb-3d1e5ae00900" -and
                $Force -eq $true
            }
        }
    }
}
