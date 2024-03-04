BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "New-RoleAssignment" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-Expression
        }

        It "It creates role assignment" {
            New-RoleAssignment -Role "Contributor" -ObjectId "acb27f78-9d6f-4694-88dc-563095f52f3e"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az role assignment create --assignee acb27f78-9d6f-4694-88dc-563095f52f3e --role 'Contributor'"
            }
        }
    }
}
