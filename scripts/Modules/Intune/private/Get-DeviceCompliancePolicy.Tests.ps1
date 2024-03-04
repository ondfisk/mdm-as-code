BeforeAll {
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-DeviceCompliancePolicy" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    id                                      = "0a5281d5-6056-4498-aa18-96ee29b48c19"
                    "scheduledActionsForRule@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceCompliancePolicies('0a5281d5-6056-4498-aa18-96ee29b48c19')/microsoft.graph.iosCompliancePolicy/scheduledActionsForRule(scheduledActionConfigurations())"
                    scheduledActionsForRule                 = @(
                        [pscustomobject]@{
                            id                                            = "6a8e3768-e31a-4516-89d4-034d4565ba6e"
                            ruleName                                      = $null
                            "scheduledActionConfigurations@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceCompliancePolicies('0a5281d5-6056-4498-aa18-96ee29b48c19')/microsoft.graph.iosCompliancePolicy/scheduledActionsForRule('6a8e3768-e31a-4516-89d4-034d4565ba6e')/scheduledActionConfigurations"
                            scheduledActionConfigurations                 = @(
                                [pscustomobject]@{
                                    id                        = "051b466b-d9a0-47f1-bb40-35df1d2d6964"
                                    gracePeriodHours          = 0
                                    actionType                = "block"
                                    notificationTemplateId    = "00000000-0000-0000-0000-000000000000"
                                    notificationMessageCCList = @()
                                }
                            )
                        }
                    )
                }
            }
        }

        It "It gets device compliance policy" {
            Get-DeviceCompliancePolicy -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceCompliancePolicies/0a5281d5-6056-4498-aa18-96ee29b48c19?`$expand=scheduledActionsForRule(`$expand%3DscheduledActionConfigurations)"
            }
        }

        It "It removes scheduledActionsForRule@odata.context from configuration" {
            $configuration = Get-DeviceCompliancePolicy -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration."scheduledActionsForRule@odata.context" | Should -Be $null
        }

        It "It removes scheduledActionConfigurations@odata.context from scheduledActionsForRule" {
            $configuration = Get-DeviceCompliancePolicy -Id "0a5281d5-6056-4498-aa18-96ee29b48c19"

            $configuration.scheduledActionsForRule."scheduledActionConfigurations@odata.context" | Should -Be $null
        }
    }
}
