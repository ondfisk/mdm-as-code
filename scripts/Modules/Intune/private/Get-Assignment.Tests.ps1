BeforeAll {
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSScriptRoot\..\public\Get-IntuneGroup.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-Assignment" {
    Context "Given assignment with no group id" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceConfigurations('72889532-554f-433c-98f2-881ec0ea5b3a')/assignments"
                    value            = @(
                        [pscustomobject]@{
                            id     = "72889532-554f-433c-98f2-881ec0ea5b3a_adadadad-808e-44e2-905a-0b7873a8a531"
                            target = [pscustomobject]@{
                                "@odata.type" = "#microsoft.graph.allDevicesAssignmentTarget"
                            }
                        }
                    )
                }
            }
        }

        It "It gets assignments" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations/72889532-554f-433c-98f2-881ec0ea5b3a/assignments" -and
                $Method -eq "Get"
            }
        }

        It "It returns assignment" {
            $assignments = Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a"

            $assignments[0].target."@odata.type" | Should -Be "#microsoft.graph.allDevicesAssignmentTarget"
        }
    }

    Context "Given assignment with group id" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceConfigurations('72889532-554f-433c-98f2-881ec0ea5b3a')/assignments"
                    value            = @(
                        [pscustomobject]@{
                            id     = "72889532-554f-433c-98f2-881ec0ea5b3a_4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            target = [pscustomobject]@{
                                "@odata.type" = "#microsoft.graph.exclusionGroupAssignmentTarget"
                                groupId       = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            }
                        }
                    )
                }
            }

            Mock Get-IntuneGroup {
                [pscustomobject]@{
                    id          = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                    displayName = "my-group"
                }
            }
        }

        It "It gets assignments" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations/72889532-554f-433c-98f2-881ec0ea5b3a/assignments" -and
                $Method -eq "Get"
            }
        }

        It "It gets group" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a"
            Should -Invoke Get-IntuneGroup -ParameterFilter {
                $Id -eq "4846eb81-657f-4c3e-95ac-85cd19721e4a"
            }
        }

        It "It returns assignment" {
            $assignments = Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a"

            $assignments[0].target."@odata.type" | Should -Be "#microsoft.graph.exclusionGroupAssignmentTarget"
            $assignments[0].target.groupDisplayName | Should -Be "my-group"
        }
    }

    Context "Given assignment with group id and OutputFolder" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceConfigurations('72889532-554f-433c-98f2-881ec0ea5b3a')/assignments"
                    value            = @(
                        [pscustomobject]@{
                            id     = "72889532-554f-433c-98f2-881ec0ea5b3a_4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            target = [pscustomobject]@{
                                "@odata.type" = "#microsoft.graph.exclusionGroupAssignmentTarget"
                                groupId       = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            }
                        }
                    )
                }
            }

            $group = [pscustomobject]@{
                id              = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                displayName     = "my-group"
                renewedDateTime = Get-Date
            }

            Mock Get-IntuneGroup { $group }
            Mock ConvertTo-Json { "{}" }
            Mock Join-Path { "joined-path" }
            Mock New-Item { }
            Mock Set-Content { }
        }

        It "It clears renewedDateTime and converts group to json" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $group -and
                $InputObject.renewedDateTime -eq $null -and
                $Depth -eq 10
            }
        }

        It "It creates group path" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Invoke Join-Path -ParameterFilter {
                $Path -eq "configuration" -and
                $ChildPath -eq "groups" -and
                $AdditionalChildPath -eq "my-group.json"
            }
        }

        It "It creates group file" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Invoke New-Item -ParameterFilter {
                $Path -eq "joined-path" -and
                $Force -eq $true
            }
        }

        It "It saves group to file" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Invoke Set-Content -ParameterFilter {
                $Path -eq "joined-path" -and
                $Value -eq "{}"
            }
        }
    }

    Context "Given assignment with non-existing group id" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceConfigurations('72889532-554f-433c-98f2-881ec0ea5b3a')/assignments"
                    value            = @(
                        [pscustomobject]@{
                            id     = "72889532-554f-433c-98f2-881ec0ea5b3a_4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            target = [pscustomobject]@{
                                "@odata.type" = "#microsoft.graph.exclusionGroupAssignmentTarget"
                                groupId       = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            }
                        }
                    )
                }
            }

            Mock Get-IntuneGroup { }
            Mock Write-Error { }
        }

        It "It gets assignments" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations/72889532-554f-433c-98f2-881ec0ea5b3a/assignments" -and
                $Method -eq "Get"
            }
        }

        It "It writes error" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a"

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found no group with id '4846eb81-657f-4c3e-95ac-85cd19721e4a' aborting..."
            }
        }
    }

    Context "Given no assignments" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceConfigurations('72889532-554f-433c-98f2-881ec0ea5b3a')/assignments"
                    value            = @()
                }
            }
        }

        It "It gets assignments" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations/72889532-554f-433c-98f2-881ec0ea5b3a/assignments" -and
                $Method -eq "Get"
            }
        }

        It "It returns null" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" | Should -Be $null
        }
    }

    Context "Given assignment with group id and group displayName has leading whitespace" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceConfigurations('72889532-554f-433c-98f2-881ec0ea5b3a')/assignments"
                    value            = @(
                        [pscustomobject]@{
                            id     = "72889532-554f-433c-98f2-881ec0ea5b3a_4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            target = [pscustomobject]@{
                                "@odata.type" = "#microsoft.graph.exclusionGroupAssignmentTarget"
                                groupId       = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            }
                        }
                    )
                }
            }

            $group = [pscustomobject]@{
                id              = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                displayName     = " my-group"
            }

            Mock Get-IntuneGroup { $group }
            Mock ConvertTo-Json { "{}" }
            Mock Join-Path { "joined-path" }
            Mock New-Item { }
            Mock Set-Content { }
            Mock Write-Error { }
        }

        It "It writes error" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found group with leading or trailing whitespace in display name ' my-group' aborting..."
            }
        }

        It "It does not create group file" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Not -Invoke New-Item
        }

        It "It does not save group to file" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Not -Invoke Set-Content
        }
    }

    Context "Given assignment with group id and group displayName has trailing whitespace" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceConfigurations('72889532-554f-433c-98f2-881ec0ea5b3a')/assignments"
                    value            = @(
                        [pscustomobject]@{
                            id     = "72889532-554f-433c-98f2-881ec0ea5b3a_4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            target = [pscustomobject]@{
                                "@odata.type" = "#microsoft.graph.exclusionGroupAssignmentTarget"
                                groupId       = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                            }
                        }
                    )
                }
            }

            $group = [pscustomobject]@{
                id              = "4846eb81-657f-4c3e-95ac-85cd19721e4a"
                displayName     = "my-group "
            }

            Mock Get-IntuneGroup { $group }
            Mock ConvertTo-Json { "{}" }
            Mock Join-Path { "joined-path" }
            Mock New-Item { }
            Mock Set-Content { }
            Mock Write-Error { }
        }

        It "It writes error" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found group with leading or trailing whitespace in display name 'my-group ' aborting..."
            }
        }

        It "It does not create group file" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Not -Invoke New-Item
        }

        It "It does not save group to file" {
            Get-Assignment -Resource "deviceManagement/deviceConfigurations" -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -OutputFolder "configuration"

            Should -Not -Invoke Set-Content
        }
    }
}
