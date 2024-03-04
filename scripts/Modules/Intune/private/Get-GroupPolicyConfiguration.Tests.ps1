BeforeAll {
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-GroupPolicyConfiguration" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    id = "0a5281d5-6056-4498-aa18-96ee29b48c19"
                }
            } -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/0a5281d5-6056-4498-aa18-96ee29b48c19"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        [pscustomobject]@{
                            id         = "7ab5ed1b-0784-44f4-bc18-ecd47623c654"
                            enabled    = $true
                            definition = [pscustomobject]@{
                                id = "f2994b61-5ee3-41bf-a041-dcc785fcbad6"
                            }
                        }
                    )
                }
            } -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/0a5281d5-6056-4498-aa18-96ee29b48c19/definitionValues?`$expand=definition"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = [pscustomobject]@{
                        id           = "a2d4b69c-4e61-4cb2-9563-90bfb4e489ff"
                        values       = @(
                            [pscustomobject]@{
                                name  = "ee4237a8-1416-4b0f-8acb-f6f7a9f2db4b"
                                value = $null
                            }
                        )
                        presentation = [pscustomobject]@{
                            id = "6f811d26-c62b-4321-b1c9-4e639592267e"
                        }
                    }
                }
            } -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/groupPolicyConfigurations/0a5281d5-6056-4498-aa18-96ee29b48c19/definitionValues/7ab5ed1b-0784-44f4-bc18-ecd47623c654/presentationValues?`$expand=presentation"
            }
        }

        It "It sets group policy configuration id" {
            $configuration = Get-GroupPolicyConfiguration -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.id | Should -Be "0a5281d5-6056-4498-aa18-96ee29b48c19"
        }

        It "It sets group policy configuration definition value id" {
            $configuration = Get-GroupPolicyConfiguration -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.definitionValues[0].id | Should -Be "7ab5ed1b-0784-44f4-bc18-ecd47623c654"
        }

        It "It sets group policy configuration definition value enabled" {
            $configuration = Get-GroupPolicyConfiguration -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.definitionValues[0].enabled | Should -Be $true
        }

        It "It sets group policy configuration definition value definition@odata.bind" {
            $configuration = Get-GroupPolicyConfiguration -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.definitionValues[0]."definition@odata.bind" | Should -Be "$script:graphBaseUri/beta/deviceManagement/groupPolicyDefinitions('f2994b61-5ee3-41bf-a041-dcc785fcbad6')"
        }

        It "It sets group policy configuration definition values presentation value id" {
            $configuration = Get-GroupPolicyConfiguration -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.definitionValues[0].presentationValues[0].id | Should -Be "a2d4b69c-4e61-4cb2-9563-90bfb4e489ff"
        }

        It "It sets group policy configuration definition values presentation value values" {
            $configuration = Get-GroupPolicyConfiguration -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.definitionValues[0].presentationValues[0].values[0].name | Should -Be "ee4237a8-1416-4b0f-8acb-f6f7a9f2db4b"
        }

        It "It sets group policy configuration definition values presentation value presentation@odata.bind" {
            $configuration = Get-GroupPolicyConfiguration -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.definitionValues[0].presentationValues[0]."presentation@odata.bind" | Should -Be "$script:graphBaseUri/beta/deviceManagement/groupPolicyDefinitions('f2994b61-5ee3-41bf-a041-dcc785fcbad6')/presentations('6f811d26-c62b-4321-b1c9-4e639592267e')"
        }
    }
}
