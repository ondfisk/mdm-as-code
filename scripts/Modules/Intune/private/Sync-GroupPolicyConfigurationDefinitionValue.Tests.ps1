BeforeAll {
    . $PSScriptRoot\Get-GroupPolicyConfiguration.ps1
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Sync-GroupPolicyConfigurationDefinitionValue" {
    Context "Given no definition values" {
        BeforeAll {
            Mock Get-GroupPolicyConfiguration {
                [pscustomobject]@{
                    definitionValues = @(
                        [pscustomobject]@{
                            id                      = "5c8cf416-ea39-41d2-8d9e-e1d310564049"
                            "definition@odata.bind" = "delete"
                            presentationValues      = @()
                        }
                    )
                }
            }

            Mock Invoke-IntuneGraphApi { }
        }

        It "It gets existing definition" {
            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue @() |
            Should -Invoke Get-GroupPolicyConfiguration -ParameterFilter {
                $Id -eq "eb297d06-3131-4c0c-aa11-29bea42ae11b"
            }
        }

        It "It deletes existing definition values" {
            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue @() |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Delete" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/eb297d06-3131-4c0c-aa11-29bea42ae11b/definitionValues/5c8cf416-ea39-41d2-8d9e-e1d310564049" -and
                $Body -eq $null
            }
        }
    }

    Context "Given new definition values" {
        BeforeAll {
            Mock Get-GroupPolicyConfiguration {
                [pscustomobject]@{
                    definitionValues = @()
                }
            }

            Mock Invoke-IntuneGraphApi { }
        }

        It "It gets existing definition" {
            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue @() |
            Should -Invoke Get-GroupPolicyConfiguration -ParameterFilter {
                $Id -eq "eb297d06-3131-4c0c-aa11-29bea42ae11b"
            }
        }

        It "It adds new definition value" {
            $definitionValue = [pscustomobject]@{
                "definition@odata.bind" = "add"
                enabled                 = $true
            }

            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue $definitionValue |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Post" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/eb297d06-3131-4c0c-aa11-29bea42ae11b/definitionValues" -and
                $Body."definition@odata.bind" -eq "add"
            }
        }
    }

    Context "Given updated definition value" {
        BeforeAll {
            Mock Get-GroupPolicyConfiguration {
                [pscustomobject]@{
                    definitionValues = @(
                        [pscustomobject]@{
                            id                      = "37e17638-ccd1-4a75-839c-55d2b80471b3"
                            "definition@odata.bind" = "update"
                            presentationValues      = @()
                        }
                    )
                }
            }

            Mock Invoke-IntuneGraphApi { }
        }

        It "It gets existing definition" {
            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue @() |
            Should -Invoke Get-GroupPolicyConfiguration -ParameterFilter {
                $Id -eq "eb297d06-3131-4c0c-aa11-29bea42ae11b"
            }
        }

        It "It updates existing definition value" {
            $definitionValue = [pscustomobject]@{
                id                      = "359a5d29-bcfa-487c-b301-7ebe83431ff2"
                "definition@odata.bind" = "update"
                enabled                 = $true
                presentationValues      = @()
            }

            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue $definitionValue |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Patch" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/eb297d06-3131-4c0c-aa11-29bea42ae11b/definitionValues/37e17638-ccd1-4a75-839c-55d2b80471b3" -and
                $Body."definition@odata.bind" -eq "update"
            }
        }
    }

    Context "Given updated definition values with no presentation values" {
        BeforeAll {
            Mock Get-GroupPolicyConfiguration {
                [pscustomobject]@{
                    definitionValues = @(
                        [pscustomobject]@{
                            id                      = "37e17638-ccd1-4a75-839c-55d2b80471b3"
                            "definition@odata.bind" = "update"
                            presentationValues      = @(
                                [pscustomobject]@{
                                    id                        = "e70be0b7-99f0-443b-b322-2f3e0727a7be"
                                    "presentation@odata.bind" = "delete"
                                }
                            )
                        }
                    )
                }
            }

            Mock Invoke-IntuneGraphApi { }
        }

        It "It deletes existing presentation value" {
            $definitionValue = [pscustomobject]@{
                id                      = "359a5d29-bcfa-487c-b301-7ebe83431ff2"
                "definition@odata.bind" = "update"
                enabled                 = $true
                presentationValues      = @()
            }

            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue $definitionValue |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Delete" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/eb297d06-3131-4c0c-aa11-29bea42ae11b/definitionValues/37e17638-ccd1-4a75-839c-55d2b80471b3/presentationValues/e70be0b7-99f0-443b-b322-2f3e0727a7be" -and
                $Body -eq $null
            }
        }
    }

    Context "Given updated definition values with new presentation value" {
        BeforeAll {
            Mock Get-GroupPolicyConfiguration {
                [pscustomobject]@{
                    definitionValues = @(
                        [pscustomobject]@{
                            id                      = "37e17638-ccd1-4a75-839c-55d2b80471b3"
                            "definition@odata.bind" = "update"
                            presentationValues      = @()
                        }
                    )
                }
            }

            Mock Invoke-IntuneGraphApi { }
        }

        It "It adds new presentation value" {
            $definitionValue = [pscustomobject]@{
                id                      = "359a5d29-bcfa-487c-b301-7ebe83431ff2"
                "definition@odata.bind" = "update"
                enabled                 = $true
                presentationValues      = @(
                    [pscustomobject]@{
                        id                        = "ad02f545-44fe-49f7-b1fd-7443d47a7e93"
                        "presentation@odata.bind" = "new"
                    }
                )
            }

            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue $definitionValue |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Post" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/eb297d06-3131-4c0c-aa11-29bea42ae11b/definitionValues/37e17638-ccd1-4a75-839c-55d2b80471b3/presentationValues" -and
                $Body."presentation@odata.bind" -eq "new"
            }
        }
    }

    Context "Given updated definition values with existing presentation value" {
        BeforeAll {
            Mock Get-GroupPolicyConfiguration {
                [pscustomobject]@{
                    definitionValues = @(
                        [pscustomobject]@{
                            id                      = "37e17638-ccd1-4a75-839c-55d2b80471b3"
                            "definition@odata.bind" = "update"
                            presentationValues      = [pscustomobject]@{
                                id                        = "b32b1cd6-ab5e-4db0-8139-afa43c45932f"
                                "presentation@odata.bind" = "update"
                            }
                        }
                    )
                }
            }

            Mock Invoke-IntuneGraphApi { }
        }

        It "It updates presentation value" {
            $definitionValue = [pscustomobject]@{
                id                      = "359a5d29-bcfa-487c-b301-7ebe83431ff2"
                "definition@odata.bind" = "update"
                enabled                 = $true
                presentationValues      = @(
                    [pscustomobject]@{
                        id                        = "ad02f545-44fe-49f7-b1fd-7443d47a7e93"
                        "presentation@odata.bind" = "update"
                    }
                )
            }

            Sync-GroupPolicyConfigurationDefinitionValue -Id "eb297d06-3131-4c0c-aa11-29bea42ae11b" -DefinitionValue $definitionValue |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Patch" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/eb297d06-3131-4c0c-aa11-29bea42ae11b/definitionValues/37e17638-ccd1-4a75-839c-55d2b80471b3/presentationValues/b32b1cd6-ab5e-4db0-8139-afa43c45932f" -and
                $Body."presentation@odata.bind" -eq "update"
            }
        }
    }
}
