BeforeAll {
    . $PSScriptRoot\..\public\Get-IntuneGroup.ps1
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Import-IntuneGroup" {
    Context "Given new group" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "source/configuration/groups"
                        FullName  = "source/configuration/groups/new.json"
                    }
                )
            }

            Mock Get-Content {
                @"
            {
                "id": "3db641c6-deb6-432c-b548-96860e38a9a5",
                "displayName": "new"
            }
"@
            } -ParameterFilter {
                $Path -eq "source/configuration/groups/new.json"
            }

            Mock Get-IntuneGroup { }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    id = "0f24b723-b6a6-4a1b-bcad-644cd0514a7a"
                }
            } -ParameterFilter {
                $Resource -eq "groups" -and
                $Method -eq "Post"
            }
        }

        It "It gets group files" {
            Import-IntuneGroup -InputFolder "myinputfolder/groups"

            Should -Invoke Get-ChildItem -ParameterFilter {
                $Path -eq "myinputfolder/groups" -and
                $Filter -eq "*.json"
            }
        }

        It "It gets group" {
            Import-IntuneGroup -InputFolder "myinputfolder/groups"

            Should -Invoke Get-IntuneGroup -ParameterFilter {
                $DisplayName -eq "new"
            }
        }

        It "It creates new group" {
            Import-IntuneGroup -InputFolder "myinputfolder/groups"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Post" -and
                $Resource -eq "groups" -and
                $Body -ne $null
            } -Times 1 -Exactly
        }
    }

    Context "Given existing group" {
        BeforeAll {
            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{
                        Directory = "source/configuration/groups"
                        FullName  = "source/configuration/groups/existing.json"
                    }
                )
            }

            Mock Get-Content {
                @"
            {
                "id": "3db641c6-deb6-432c-b548-96860e38a9a5",
                "displayName": "existing"
            }
"@
            } -ParameterFilter {
                $Path -eq "source/configuration/groups/existing.json"
            }

            Mock Get-IntuneGroup {
                [pscustomobject]@{
                    id          = "0f24b723-b6a6-4a1b-bcad-644cd0514a7a"
                    displayName = "existing"
                }
            } -ParameterFilter {
                $DisplayName -eq "existing"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    id = "0f24b723-b6a6-4a1b-bcad-644cd0514a7a"
                }
            } -ParameterFilter {
                $Resource -eq "groups/0f24b723-b6a6-4a1b-bcad-644cd0514a7a" -and
                $Method -eq "Patch"
            }
        }

        It "It updates existing group" {
            Import-IntuneGroup -InputFolder "myinputfolder/groups"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Patch" -and
                $Resource -eq "groups/0f24b723-b6a6-4a1b-bcad-644cd0514a7a" -and
                $Body -ne $null
            } -Times 1 -Exactly
        }
    }
}