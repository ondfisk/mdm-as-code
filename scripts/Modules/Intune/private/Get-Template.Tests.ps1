BeforeAll {
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-Template" {
    Context "Given Id" {
        BeforeAll {
            $template = [pscustomobject]@{}
            Mock Invoke-IntuneGraphApi { $template }
        }

        It "It gets template" {
            Get-Template -Id "800c721f-fc42-4739-ae9a-a534cbdb7dd8"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/templates/800c721f-fc42-4739-ae9a-a534cbdb7dd8"
            }
        }

        It "It returns template" {
            Get-Template -Id "800c721f-fc42-4739-ae9a-a534cbdb7dd8" | Should -Be $template
        }
    }

    Context "Given DisplayName" {
        BeforeAll {
            $template = [pscustomobject]@{}
            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = , $template
                }
            }
        }

        It "It gets template" {
            Get-Template -DisplayName "template"
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/templates?`$filter=displayName+eq+'template'"
            }
        }

        It "It returns template" {
            Get-Template -DisplayName "template" | Should -Be $template
        }
    }
}