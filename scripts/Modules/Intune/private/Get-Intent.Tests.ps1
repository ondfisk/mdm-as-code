BeforeAll {
    . $PSScriptRoot\Get-Template.ps1
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-Intent" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    id         = "0a5281d5-6056-4498-aa18-96ee29b48c19"
                    templateId = "02736e20-806a-4049-8242-dbba68a844b9"
                }
            } -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/intents/0a5281d5-6056-4498-aa18-96ee29b48c19"
            }

            Mock Get-Template {
                [pscustomobject]@{
                    id          = "02736e20-806a-4049-8242-dbba68a844b9"
                    displayName = "template-display-name"
                }
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        [pscustomobject]@{
                            id           = "abf1d04e-6392-402c-bbaa-3038adde38a1"
                            definitionId = "def1"
                            valueJson    = "true"
                            value        = $true
                        }
                        [pscustomobject]@{
                            id           = "9bd7fe0c-3374-4aae-8bb7-d414a2200ff2"
                            definitionId = "def2"
                            valueJson    = "`"high`""
                            value        = "high"
                        }
                    )
                }
            } -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/intents/0a5281d5-6056-4498-aa18-96ee29b48c19/settings"
            }
        }

        It "It gets intent" {
            Get-Intent -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/intents/0a5281d5-6056-4498-aa18-96ee29b48c19"
            }
        }

        It "It sets intent id" {
            $configuration = Get-Intent -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.id | Should -Be "0a5281d5-6056-4498-aa18-96ee29b48c19"
        }

        It "It gets template" {
            Get-Intent -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            Should -Invoke Get-Template -ParameterFilter {
                $Id -eq "02736e20-806a-4049-8242-dbba68a844b9"
            }
        }

        It "It sets template display name" {
            $configuration = Get-Intent -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.templateDisplayName | Should -Be "template-display-name"
        }

        It "It gets intent settings" {
            Get-Intent -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/intents/0a5281d5-6056-4498-aa18-96ee29b48c19/settings"
            }
        }

        It "It sets intent settings (1)" {
            $configuration = Get-Intent -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.settings[0].id | Should -Be "abf1d04e-6392-402c-bbaa-3038adde38a1"
            $configuration.settings[0].definitionId | Should -Be "def1"
            $configuration.settings[0].valueJson | Should -Be "true"
            $configuration.settings[0].value | Should -Be $true
        }

        It "It sets intent settings (2)" {
            $configuration = Get-Intent -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.settings[1].id | Should -Be "9bd7fe0c-3374-4aae-8bb7-d414a2200ff2"
            $configuration.settings[1].definitionId | Should -Be "def2"
            $configuration.settings[1].valueJson | Should -Be "`"high`""
            $configuration.settings[1].value | Should -Be "high"
        }
    }
}
