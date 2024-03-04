BeforeAll {
    . $PSScriptRoot\..\private\ConvertFrom-ConfigurationFileName.ps1
    . $PSScriptRoot\..\private\Sync-Assignment.ps1
    . $PSScriptRoot\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "Remove-IntuneConfiguration" {
    Context "Given valid input with ConfigurationFileName" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "value" = @(
                        [pscustomobject]@{
                            id          = "bef4c12a-527d-43ff-9f81-715068dcce28"
                            displayName = "existing"
                        }
                    )
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'existing'" -and
                $Method -eq "Get"
            }

            Mock Invoke-IntuneGraphApi { }
            Mock Write-Warning { }
            Mock Sync-Assignment { }
        }

        It "It gets notfound configuration" {
            Remove-IntuneConfiguration -ConfigurationFileName "configuration/deviceManagement/deviceConfigurations/android/existing/existing.json", "configuration/deviceManagement/deviceConfigurations/notfound/notfound.json"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'notfound'" -and
                $Body -eq $null
            }
        }

        It "It gets existing configuration" {
            Remove-IntuneConfiguration -ConfigurationFileName "configuration/deviceManagement/deviceConfigurations/android/existing/existing.json", "configuration/deviceManagement/deviceConfigurations/notfound/notfound.json"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'existing'" -and
                $Body -eq $null
            }
        }

        It "It removes existing assignments" {
            Remove-IntuneConfiguration -ConfigurationFileName "configuration/deviceManagement/deviceConfigurations/android/existing/existing.json"

            Should -Invoke Sync-Assignment -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $Id -eq "bef4c12a-527d-43ff-9f81-715068dcce28"
            }
        }

        It "It removes existing configuration" {
            Remove-IntuneConfiguration -ConfigurationFileName "configuration/deviceManagement/deviceConfigurations/android/existing/existing.json", "configuration/deviceManagement/deviceConfigurations/notfound/notfound.json"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Delete" -and
                $Resource -eq "deviceManagement/deviceConfigurations/bef4c12a-527d-43ff-9f81-715068dcce28" -and
                $Body -eq $null
            }
        }
    }

    Context "Given valid input with multiple existing configurations with same display name" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "value" = @(
                        [pscustomobject]@{
                            id          = "bef4c12a-527d-43ff-9f81-715068dcce28"
                            displayName = "existing"
                        },
                        [pscustomobject]@{
                            id          = "f2782b64-ba1d-47d7-8385-acc6f4cb978e"
                            displayName = "existing"
                        }
                    )
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'existing'" -and
                $Method -eq "Get"
            }

            Mock Invoke-IntuneGraphApi { }
            Mock Write-Error { }
            Mock Write-Warning { }
        }

        It "It does not remove existing configuration" {
            Remove-IntuneConfiguration -ConfigurationFileName "configuration/deviceManagement/deviceConfigurations/android/existing/existing.json"

            Should -Not -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Delete" -and
                $Resource -match "deviceManagement/deviceConfigurations"
            }
        }

        It "It writes error" {
            Remove-IntuneConfiguration -ConfigurationFileName "configuration/deviceManagement/deviceConfigurations/android/existing/existing.json"

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found multiple deviceManagement/deviceConfigurations with the display name 'existing' aborting..."
            }
        }
    }

    Context "Given valid input with no ConfigurationFileName" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi { }
        }

        It "Given null it does not call the Graph API" {
            Remove-IntuneConfiguration -ConfigurationFileName $null

            Should -Not -Invoke Invoke-IntuneGraphApi
        }

        It "Given empty it does not call the Graph API" {
            Remove-IntuneConfiguration -ConfigurationFileName $()

            Should -Not -Invoke Invoke-IntuneGraphApi
        }
    }
}
