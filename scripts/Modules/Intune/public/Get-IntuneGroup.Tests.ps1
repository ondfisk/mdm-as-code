BeforeAll {
    . $PSScriptRoot\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-IntuneGroup" {
    Context "Given Id" {
        BeforeAll {
            $group = [pscustomobject]@{}
            Mock Invoke-IntuneGraphApi { $group }
        }

        It "It gets group" {
            Get-IntuneGroup -Id "800c721f-fc42-4739-ae9a-a534cbdb7dd8"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "groups/800c721f-fc42-4739-ae9a-a534cbdb7dd8"
            }
        }

        It "It returns group" {
            Get-IntuneGroup -Id "800c721f-fc42-4739-ae9a-a534cbdb7dd8" | Should -Be $group
        }
    }

    Context "Given DisplayName" {
        BeforeAll {
            $group = [pscustomobject]@{}
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = , $group
                }
            }
        }

        It "It gets group" {
            Get-IntuneGroup -DisplayName "Group"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "groups?`$filter=displayName+eq+'Group'"
            }
        }

        It "It returns group" {
            Get-IntuneGroup -DisplayName "Group" | Should -Be $group
        }
    }

    Context "Given multiple existing groups with same display name" {
        BeforeAll {
            $groups = [pscustomobject]@{}, [pscustomobject]@{}
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = $groups
                }
            }
            Mock Write-Error { }
        }

        It "It gets group" {
            Get-IntuneGroup -DisplayName "Group"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "groups?`$filter=displayName+eq+'group'"
            }
        }

        It "It writes error" {
            Get-IntuneGroup -DisplayName "Group"

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found multiple groups with the display name 'Group' aborting..."
            }
        }
    }
}