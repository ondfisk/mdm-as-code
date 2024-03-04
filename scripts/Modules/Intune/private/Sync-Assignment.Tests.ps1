BeforeAll {
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSScriptRoot\..\public\Get-IntuneGroup.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Sync-Assignment" {
    Context "Given assignments" {
        BeforeAll {
            Mock Get-IntuneGroup {
                [pscustomobject]@{
                    id          = "0b7ef424-b6ba-4227-8eee-3534da6663c5"
                    displayName = "existing group"
                }
            } -ParameterFilter {
                $DisplayName -eq "existing group"
            }

            Mock Write-Warning { }

            Mock Invoke-IntuneGraphApi { }
        }
        BeforeEach {
            $assignments = @(
                [pscustomobject]@{
                    target = [pscustomobject]@{
                        "@odata.type"    = "#microsoft.graph.groupAssignmentTarget"
                        groupId          = "67e9f6f6-9ed2-4276-b39d-4309e24afad6"
                        groupDisplayName = "existing group"
                    }
                }
                [pscustomobject]@{
                    target = [pscustomobject]@{
                        "@odata.type"    = "#microsoft.graph.exclusionGroupAssignmentTarget"
                        groupId          = "e8cd2b2c-a49c-4e77-a4cc-72d41f88f006"
                        groupDisplayName = "unknown group"
                    }
                }
                [pscustomobject]@{
                    target = [pscustomobject]@{
                        "@odata.type" = "#microsoft.graph.allDevicesAssignmentTarget"
                    }
                }
            )
        }

        It "It gets group" {
            Sync-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -Assignment $assignments

            Should -Invoke Get-IntuneGroup -ParameterFilter {
                $DisplayName -eq "existing group"
            }
        }

        It "It writes warning for missing group" {
            Sync-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -Assignment $assignments

            Should -Invoke Write-Warning -ParameterFilter {
                $Message -eq "Found no group with display name 'unknown group' skipping..."
            }
        }

        It "It creates assignments" {
            Sync-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -Assignment $assignments

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Post" -and
                $Resource -eq "deviceManagement/deviceConfigurations/72889532-554f-433c-98f2-881ec0ea5b3a/assign" -and
                $Body.assignments.Count -eq 2
            }
        }
    }
}