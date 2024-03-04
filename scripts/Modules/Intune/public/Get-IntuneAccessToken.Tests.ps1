BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "Get-IntuneAccessToken" {
    Context "Given ClientSecret" {
        BeforeAll {
            Mock Get-MsalToken {
                [pscustomobject]@{
                    AccessToken = "token"
                }
            }
        }

        It "It gets an access token" {
            $myTenantId = "0cafa489-6f15-4fad-b5eb-6fad24a2387b"
            $myClientId = "f3eede29-3aa4-41d6-a19d-ff921731bd8d"
            $myClientSecret = New-Guid | ConvertTo-SecureString -AsPlainText -Force

            Get-IntuneAccessToken -TenantId $myTenantId -ClientId $myClientId -ClientSecret $myClientSecret
            Should -Invoke Get-MsalToken -ParameterFilter {
                $TenantId -eq $myTenantId -and
                $ClientId -eq $myClientId -and
                $ClientSecret -eq $myClientSecret
            }
        }

        It "It returns token as secure string" {
            $myTenantId = "0cafa489-6f15-4fad-b5eb-6fad24a2387b"
            $myClientId = "f3eede29-3aa4-41d6-a19d-ff921731bd8d"
            $myClientSecret = New-Guid | ConvertTo-SecureString -AsPlainText -Force

            Get-IntuneAccessToken -TenantId $myTenantId -ClientId $myClientId -ClientSecret $myClientSecret | ConvertFrom-SecureString -AsPlainText | Should -Be "token"
        }
    }

    Context "Given no ClientSecret" {
        BeforeAll {
            Mock Get-MsalToken {
                [pscustomobject]@{
                    AccessToken = "token"
                }
            }
        }

        It "It gets an access token" {
            $myTenantId = "0cafa489-6f15-4fad-b5eb-6fad24a2387b"
            $myClientId = "f3eede29-3aa4-41d6-a19d-ff921731bd8d"

            Get-IntuneAccessToken -TenantId $myTenantId -ClientId $myClientId
            Should -Invoke Get-MsalToken -ParameterFilter {
                $TenantId -eq $myTenantId -and
                $ClientId -eq $myClientId -and
                $Scopes -contains "https://graph.microsoft.com/DeviceManagementConfiguration.ReadWrite.All"
            }
        }

        It "It returns token as secure string" {
            $myTenantId = "0cafa489-6f15-4fad-b5eb-6fad24a2387b"
            $myClientId = "f3eede29-3aa4-41d6-a19d-ff921731bd8d"

            Get-IntuneAccessToken -TenantId $myTenantId -ClientId $myClientId | ConvertFrom-SecureString -AsPlainText | Should -Be "token"
        }
    }
}
