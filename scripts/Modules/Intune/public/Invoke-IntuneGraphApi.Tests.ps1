BeforeAll {
    . $PSScriptRoot\Get-IntuneAccessToken.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    $script:accessToken = "token" | ConvertTo-SecureString -AsPlainText -Force
}

Describe "Invoke-IntuneGraphApi" {
    Context "Given valid input" {
        BeforeAll {
            Mock Get-IntuneAccessToken { $script:accessToken }
            Mock Invoke-RestMethod { "response" }
            Mock ConvertTo-Json { "{}" }

            $env:IntuneTenantId = "tenantId"
            $env:IntuneClientId = "clientId"
            $env:IntuneClientSecret = "clientSecret"
        }

        It "It gets and access token using environment variables" {
            Invoke-IntuneGraphApi -Method Get -Resource "users"

            Should -Invoke Get-IntuneAccessToken -ParameterFilter {
                $TenantId -eq "tenantId" -and
                $ClientId -eq "clientId" -and
                ($ClientSecret | ConvertFrom-SecureString -AsPlainText) -eq "clientSecret"
            }
        }

        It "It returns result of Invoke-RestMethod" {
            Invoke-IntuneGraphApi -Method Get -Resource "users" | Should -Be "response"
        }

        It "It invokes graph API with given input and JSON body" {
            Invoke-IntuneGraphApi -Method Post -Resource "users" -Body "body"

            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Method -eq "Post" -and
                $Uri -eq "https://graph.microsoft.com/v1.0/users" -and
                $Authentication -eq "Bearer" -and
                $Token -eq $script:accessToken -and
                $ContentType -eq "application/json" -and
                $Headers.Accept -eq "application/json" -and
                $Body -eq "{}" -and
                $RetryIntervalSec -eq 5 -and
                $MaximumRetryCount -eq 3
            }
        }

        It "It converts to JSON with depth" {
            Invoke-IntuneGraphApi -Method Post -Resource "users" -Body "body"

            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq "body" -and
                $Depth -eq 10
            }
        }

        AfterAll {
            $env:IntuneTenantId = $null
            $env:IntuneClientId = $null
            $env:IntuneClientSecret = $null
        }
    }

    Context "Given no client secret" {
        BeforeAll {
            Mock Get-IntuneAccessToken { $script:accessToken }
            Mock Invoke-RestMethod { "response" }
            Mock ConvertTo-Json { "{}" }

            $env:IntuneTenantId = "tenantId"
            $env:IntuneClientId = "clientId"
            $env:IntuneClientSecret = $null
        }

        It "It gets and access token using environment variables" {
            Invoke-IntuneGraphApi -Method Get -Resource "users"

            Should -Invoke Get-IntuneAccessToken -ParameterFilter {
                $TenantId -eq "tenantId" -and
                $ClientId -eq "clientId" -and
                $ClientSecret -eq $null
            }
        }

        It "It returns result of Invoke-RestMethod" {
            Invoke-IntuneGraphApi -Method Get -Resource "users" | Should -Be "response"
        }

        It "It invokes graph API with given input and JSON body" {
            Invoke-IntuneGraphApi -Method Post -Resource "users" -Body "body"

            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Method -eq "Post" -and
                $Uri -eq "https://graph.microsoft.com/v1.0/users" -and
                $Authentication -eq "Bearer" -and
                $Token -eq $script:accessToken -and
                $ContentType -eq "application/json" -and
                $Body -eq "{}" -and
                $RetryIntervalSec -eq 5 -and
                $MaximumRetryCount -eq 3
            }
        }

        It "It converts to JSON with depth" {
            Invoke-IntuneGraphApi -Method Post -Resource "users" -Body "body"

            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq "body" -and
                $Depth -eq 10
            }
        }

        AfterAll {
            $env:IntuneTenantId = $null
            $env:IntuneClientId = $null
            $env:IntuneClientSecret = $null
        }
    }

    Context "Given no tenant id" {
        BeforeAll {
            function Get-IntuneAccessToken($TenantId, $ClientId) {}

            Mock Get-IntuneAccessToken { $script:accessToken }
            Mock Write-Error { }
            Mock Invoke-RestMethod { "response" }
            Mock ConvertTo-Json { "{}" }

            $env:IntuneTenantId = $null
            $env:IntuneClientId = "clientId"
            $env:IntuneClientSecret = $null
        }

        It "It writes error" {
            Invoke-IntuneGraphApi -Method Get -Resource "users"

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "No environment variable set for 'IntuneTenantId'"
            }
        }

        AfterAll {
            $env:IntuneTenantId = $null
            $env:IntuneClientId = $null
            $env:IntuneClientSecret = $null
        }
    }

    Context "Given no client id" {
        BeforeAll {
            function Get-IntuneAccessToken($TenantId, $ClientId) {}

            Mock Get-IntuneAccessToken { $script:accessToken }
            Mock Write-Error { }
            Mock Invoke-RestMethod { "response" }
            Mock ConvertTo-Json { "{}" }

            $env:IntuneTenantId = "tenantId"
            $env:IntuneClientId = $null
            $env:IntuneClientSecret = $null
        }

        It "It writes error" {
            Invoke-IntuneGraphApi -Method Get -Resource "users"

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "No environment variable set for 'IntuneClientId'"
            }
        }

        AfterAll {
            $env:IntuneTenantId = $null
            $env:IntuneClientId = $null
            $env:IntuneClientSecret = $null
        }
    }

    Context "Given URI input" {
        BeforeAll {
            Mock Get-IntuneAccessToken { $script:accessToken }
            Mock Invoke-RestMethod { }

            $env:IntuneTenantId = "tenantId"
            $env:IntuneClientId = "clientId"
        }

        It "It invokes graph API with URI" {
            Invoke-IntuneGraphApi -Method Get -Resource "https://graph.microsoft.com/v1.0/users"

            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Uri -eq "https://graph.microsoft.com/v1.0/users"
            }
        }

        AfterAll {
            $env:IntuneTenantId = $null
            $env:IntuneClientId = $null
            $env:IntuneClientSecret = $null
        }
    }

    Context "Given beta resource input" {
        BeforeAll {
            Mock Get-IntuneAccessToken { $script:accessToken }
            Mock Invoke-RestMethod { }

            $env:IntuneTenantId = "tenantId"
            $env:IntuneClientId = "clientId"
        }

        $testCases = @(
            @{ Resource = "deviceManagement/deviceCompliancePolicies" }
            @{ Resource = "deviceManagement/deviceConfigurations" }
            @{ Resource = "deviceManagement/groupPolicyConfigurations" }
            @{ Resource = "deviceManagement/intents" }
            @{ Resource = "deviceManagement/templates" }
            @{ Resource = "deviceManagement/windowsAutopilotDeploymentProfiles" }
        )

        It "With <Resource>, it invokes graph API with given input and JSON body" -TestCases $testCases {
            Invoke-IntuneGraphApi -Method Get -Resource $Resource

            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Uri -eq "https://graph.microsoft.com/beta/$Resource"
            }
        }

        AfterAll {
            $env:IntuneTenantId = $null
            $env:IntuneClientId = $null
            $env:IntuneClientSecret = $null
        }
    }
}