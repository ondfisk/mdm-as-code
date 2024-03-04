BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "Get-ApiPermission" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-Expression {
                Get-Content -Path "$PSScriptRoot/../testdata/MicrosoftGraph.json"
            }
        }

        It "It gets Microsoft Graph service principal" {
            Get-ApiPermission -Api "00000003-0000-0000-c000-000000000000" -AppPermission "Directory.Read.All", "Group.ReadWrite.All" -UserPermission "Directory.Read.All", "User.Read"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad sp show --id 00000003-0000-0000-c000-000000000000"
            }
        }

        It "It returns permissions" {
            $permissions = Get-ApiPermission -Api "00000003-0000-0000-c000-000000000000" -AppPermission "Directory.Read.All", "Group.ReadWrite.All" -UserPermission "Directory.Read.All", "User.Read"

            $permissions[0].Value | Should -Be "Directory.Read.All"
            $permissions[0].Id | Should -Be "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
            $permissions[0].Type | Should -Be "Role"
            $permissions[1].Value | Should -Be "Group.ReadWrite.All"
            $permissions[1].Id | Should -Be "62a82d76-70ea-41e2-9197-370581804d09"
            $permissions[1].Type | Should -Be "Role"
            $permissions[2].Value | Should -Be "Directory.Read.All"
            $permissions[2].Id | Should -Be "06da0dbc-49e2-44d2-8312-53f166ab848a"
            $permissions[2].Type | Should -Be "Scope"
            $permissions[3].Value | Should -Be "User.Read"
            $permissions[3].Id | Should -Be "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
            $permissions[3].Type | Should -Be "Scope"
        }
    }
}
