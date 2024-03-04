BeforeAll {
    . $PSScriptRoot\..\private\ConvertFrom-ConfigurationFileName.ps1
    . $PSScriptRoot\..\private\Get-Template.ps1
    . $PSScriptRoot\..\private\Sync-Assignment.ps1
    . $PSScriptRoot\..\private\Sync-GroupPolicyConfigurationDefinitionValue.ps1
    . $PSScriptRoot\..\private\Sync-IntentSetting.ps1
    . $PSScriptRoot\..\private\Update-Configuration.ps1
    . $PSScriptRoot\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Import-IntuneConfiguration" {
    Context "Given new configuration" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "source/configuration/deviceManagement/deviceConfigurations/new"
                        FullName  = "source/configuration/deviceManagement/deviceConfigurations/new/new.json"
                    }
                )
            }

            Mock Get-Content {
                @"
            {
                "id": "634663be-507e-40c3-955f-5a1d54360412",
                "displayName": "new",
                "assignments": [{}]
            }
"@
            } -ParameterFilter {
                $Path -eq "source/configuration/deviceManagement/deviceConfigurations/new/new.json"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "value" = @()
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'new'" -and
                $Method -eq "Get"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    id = "815965a8-ebde-4ade-8bc7-958ecfe89494"
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $Method -eq "Post"
            }

            Mock Sync-Assignment { }
        }

        It "It gets configuration files" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Get-ChildItem -ParameterFilter {
                $Path -eq "myinputfolder" -and
                $Filter -eq "*.json" -and
                $Exclude -eq "transformations.json" -and
                $Recurse -eq $true
            }
        }

        It "It creates new configuration" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Post" -and
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $Body -ne $null
            } -Times 1 -Exactly
        }

        It "It syncs assignments" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Sync-Assignment -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $Id -eq "815965a8-ebde-4ade-8bc7-958ecfe89494" -and
                $Assignment -ne $null
            } -Times 1 -Exactly
        }
    }

    Context "Given existing configuration" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "source\configuration\deviceManagement\deviceConfigurations/android"
                        FullName  = "source\configuration\deviceManagement\deviceConfigurations/android/existing.json"
                    }
                )
            }

            Mock Get-Content {
                @"
            {
                "id": "214c982d-439b-4829-846f-ae0237329746",
                "displayName": "existing",
                "property": false
            }
"@
            } -ParameterFilter {
                $Path -eq "source\configuration\deviceManagement\deviceConfigurations/android/existing.json"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "value" = @(
                        [pscustomobject]@{
                            id          = "bef4c12a-527d-43ff-9f81-715068dcce28"
                            displayName = "existing"
                            property    = $true
                        }
                    )
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'existing'" -and
                $Method -eq "Get"
            }

            Mock Invoke-IntuneGraphApi { }
            Mock Sync-Assignment { }
        }

        It "It updates existing configuration" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Patch" -and
                $Resource -eq "deviceManagement/deviceConfigurations/bef4c12a-527d-43ff-9f81-715068dcce28"
                $Body -ne $null
            }
        }
    }

    Context "Given multiple existing configurations with same display name" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "source\configuration\deviceManagement\deviceConfigurations/android"
                        FullName  = "source\configuration\deviceManagement\deviceConfigurations/android/existing.json"
                    }
                )
            }

            Mock Get-Content {
                @"
                {
                    "id": "214c982d-439b-4829-846f-ae0237329746",
                    "displayName": "existing",
                    "property": false
                }
"@
            } -ParameterFilter {
                $Path -eq "source\configuration\deviceManagement\deviceConfigurations/android/existing.json"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "value" = @(
                        [pscustomobject]@{
                            id          = "bef4c12a-527d-43ff-9f81-715068dcce28"
                            displayName = "existing"
                            property    = $true
                        }
                        [pscustomobject]@{
                            id          = "2656aaa2-26d1-46de-8692-b88fc0d79030"
                            displayName = "existing"
                            property    = $false
                        }
                    )
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'existing'" -and
                $Method -eq "Get"
            }

            Mock Invoke-IntuneGraphApi { }
            Mock Sync-Assignment { }
            Mock Write-Error { }
        }

        It "It does not update existing" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Not -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Patch" -and
                $Resource -match "deviceManagement/deviceConfigurations"
            }
        }

        It "It writes error" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found multiple deviceManagement/deviceConfigurations with the display name 'existing' aborting..."
            }
        }
    }

    Context "Given unchanged configuration" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "source\configuration\deviceManagement\deviceConfigurations/iOS"
                        FullName  = "source\configuration\deviceManagement\deviceConfigurations/iOS/unchanged.json"
                    }
                )
            }

            Mock Get-Content {
                @"
            {
                "id": "d417c1d8-a2d9-4e6e-ae0c-4dcdea381db8",
                "displayName": "unchanged",
                "property": true
            }
"@
            } -ParameterFilter {
                $Path -eq "source\configuration\deviceManagement\deviceConfigurations/iOS/unchanged.json"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "value" = @(
                        [pscustomobject]@{
                            id          = "c99b3b72-4a67-48cb-b001-fefb2c49a286"
                            displayName = "unchanged"
                            property    = $true
                        }
                    )
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'unchanged'" -and
                $Method -eq "Get"
            }

            Mock Invoke-IntuneGraphApi { }
            Mock Sync-Assignment { }
        }

        It "It skips unchanged configuration" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Not -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Patch" -and
                $Resource -eq "deviceManagement/deviceConfigurations/c99b3b72-4a67-48cb-b001-fefb2c49a286"
            }
        }
    }

    Context "Given group policy configuration" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "configuration/deviceManagement/groupPolicyConfigurations/mypolicy"
                        FullName  = "configuration/deviceManagement/groupPolicyConfigurations/mypolicy/mypolicy.json"
                    }
                )
            }

            Mock Get-Content {
                @"
            {
                "id": "143e991e-3ecd-43c6-8991-835a8574a03b",
                "displayName": "mypolicy",
                "prop": "value",
                "definitionValues": [
                    {
                        "id": "41c342ec-791b-4846-bed0-8803e6849d39",
                        "enabled": true
                    }
                ]
            }
"@
            } -ParameterFilter {
                $Path -eq "configuration/deviceManagement/groupPolicyConfigurations/mypolicy/mypolicy.json"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    id          = "a7cb44a1-a68a-44c6-8457-a9804c1c0def"
                    displayName = "mypolicy"
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/groupPolicyConfigurations" -and
                $Method -eq "Post"
            }

            Mock Invoke-IntuneGraphApi { }
            Mock Sync-Assignment { }
            Mock Sync-GroupPolicyConfigurationDefinitionValue { }
        }

        It "It invokes Sync-GroupPolicyConfigurationDefinitionValue with created id" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Sync-GroupPolicyConfigurationDefinitionValue -ParameterFilter {
                $Id -eq "a7cb44a1-a68a-44c6-8457-a9804c1c0def" -and
                $DefinitionValue[0].id -eq "41c342ec-791b-4846-bed0-8803e6849d39"
            }
        }
    }

    Context "Given existing intent" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "configuration/deviceManagement/intents/myintent"
                        FullName  = "configuration/deviceManagement/intents/myintent/myintent.json"
                    }
                )
            }

            Mock Get-Content {
                @"
            {
                "id": "143e991e-3ecd-43c6-8991-835a8574a03b",
                "displayName": "myintent",
                "templateId": "eda16323-584a-4783-a8f7-b9375ca1fa78",
                "templateDisplayName": "mytemplate",
                "isAssigned": true,
                "lastModifiedDateTime": "2020-09-22T09:01:15.4212194Z",
                "settings": [
                    {
                        "@odata.type": "#microsoft.graph.deviceManagementBooleanSettingInstance",
                        "id": "19f93736-96bf-40fd-83f8-fe565eff82ae",
                        "definitionId": "def",
                        "valueJson": "true",
                        "value": true
                    }
                ]
            }
"@
            } -ParameterFilter {
                $Path -eq "configuration/deviceManagement/intents/myintent/myintent.json"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "value" = @(
                        [pscustomobject]@{
                            id          = "bef4c12a-527d-43ff-9f81-715068dcce28"
                            displayName = "myintent"
                            property    = $true
                        }
                    )
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/intents?`$filter=displayName+eq+'myintent'" -and
                $Method -eq "Get"
            }

            Mock Invoke-IntuneGraphApi { }
            Mock Sync-Assignment { }

            Mock Get-Template {
                [pscustomobject]@{
                    id          = "ad463a8a-7302-40d0-bd39-464392cfd974"
                    displayName = "mytemplate"
                }
            }

            Mock Sync-IntentSetting { }
        }

        It "It gets template" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Get-Template -ParameterFilter {
                $DisplayName -eq "mytemplate"
            }
        }

        It "It invokes Sync-IntentSetting with id" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Sync-IntentSetting -ParameterFilter {
                $Id -eq "bef4c12a-527d-43ff-9f81-715068dcce28" -and
                $Setting[0].definitionId -eq "def"
            }
        }

        It "It updates intent without templateid, templateDisplayName, isAssigned, or lastModifiedDateTime" {
            Import-IntuneConfiguration -InputFolder "myinputfolder"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Patch" -and
                $Resource -eq "deviceManagement/intents/bef4c12a-527d-43ff-9f81-715068dcce28" -and
                $Body.templateId -eq $null -and
                $Body.templateDisplayName -eq $null -and
                $Body.isAssigned -eq $null -and
                $Body.lastModifiedDateTime -eq $null
            } -Times 1 -Exactly
        }
    }

    Context "Given configuration with transformations" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "source/configuration/deviceManagement/deviceConfigurations/config"
                        FullName  = "source/configuration/deviceManagement/deviceConfigurations/config/config.json"
                    }
                )
            }

            Mock Get-Content {
                @"
            {
                "id": "634663be-507e-40c3-955f-5a1d54360412",
                "displayName": "config",
                "assignments": []
            }
"@
            } -ParameterFilter {
                $Path -eq "source/configuration/deviceManagement/deviceConfigurations/config/config.json"
            }

            Mock Test-Path { $true }

            Mock Join-Path {
                "source/configuration/deviceManagement/deviceConfigurations/config/transformations.json"
            } -ParameterFilter {
                $Path -eq "source/configuration/deviceManagement/deviceConfigurations/config" -and
                $ChildPath -eq "transformations.json"
            }

            Mock Get-Content {
                @"
                [
                    {
                        "configuration": "config",
                        "transformations": [
                          {
                            "environment": "Production",
                            "key": "my-key",
                            "value": "my-value"
                          },
                          {
                            "environment": "Test",
                            "key": "my-key",
                            "value": "my-value"
                          }
                        ]
                      }
                ]
"@
            } -ParameterFilter {
                $Path -eq "source/configuration/deviceManagement/deviceConfigurations/config/transformations.json"
            }

            Mock Update-Configuration { [pscustomobject]@{ Updated = $true } }

            Mock Invoke-IntuneGraphApi { }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    id = "815965a8-ebde-4ade-8bc7-958ecfe89494"
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $Method -eq "Post"
            }

            Mock Sync-Assignment { }
        }

        It "It checks for existing transformation file" {
            Import-IntuneConfiguration -InputFolder "myinputfolder" -Environment "Test"

            Should -Invoke Test-Path -ParameterFilter {
                $Path -eq "source/configuration/deviceManagement/deviceConfigurations/config/transformations.json"
            }
        }

        It "It gets transformation file" {
            Import-IntuneConfiguration -InputFolder "myinputfolder" -Environment "Test"

            Should -Invoke Get-Content -ParameterFilter {
                $Path -eq "source/configuration/deviceManagement/deviceConfigurations/config/transformations.json"
            }
        }

        It "It updates configuration with transformations" {
            Import-IntuneConfiguration -InputFolder "myinputfolder" -Environment "Test"

            Should -Invoke Update-Configuration -ParameterFilter {
                $Configuration.id -eq "634663be-507e-40c3-955f-5a1d54360412"
                $Transformation.Length -eq 1 -and
                $Transformation[0].environment -eq "Test" -and
                $Transformation[0].key -eq "my-key" -and
                $Transformation[0].value -eq "my-value"
            }
        }

        It "It creates new configuration" {
            Import-IntuneConfiguration -InputFolder "myinputfolder" -Environment "Test"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Post" -and
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $Body.Updated -eq $true
            }
        }
    }
}
