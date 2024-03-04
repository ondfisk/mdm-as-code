BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "New-ServicePrincipal" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                {
                    "appId": "a8b1861e-7ed4-4984-b171-63455ca43ca3",
                    "objectId": "24d50f90-bb61-4057-a909-5ac4ed971798"
                }
"@
            } -ParameterFilter {
                $Command -match "^az ad sp create"
            }
            Mock Invoke-Expression { }
        }

        It "It queries for existing service principal" {
            New-ServicePrincipal -AppId "a8b1861e-7ed4-4984-b171-63455ca43ca3"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad sp list --filter `"appId eq 'a8b1861e-7ed4-4984-b171-63455ca43ca3'`""
            }
        }

        It "It creates a service principal" {
            New-ServicePrincipal -AppId "a8b1861e-7ed4-4984-b171-63455ca43ca3"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad sp create --id a8b1861e-7ed4-4984-b171-63455ca43ca3"
            }
        }

        It "It returns the service principal appId" {
            $sp = New-ServicePrincipal -AppId "a8b1861e-7ed4-4984-b171-63455ca43ca3"

            $sp.appId | Should -Be "a8b1861e-7ed4-4984-b171-63455ca43ca3"
        }

        It "It returns the service principal objectId" {
            $sp = New-ServicePrincipal -AppId "a8b1861e-7ed4-4984-b171-63455ca43ca3"

            $sp.objectId | Should -Be "24d50f90-bb61-4057-a909-5ac4ed971798"
        }
    }

    Context "Given existing service principal" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                [
                    {
                        "appId": "a8b1861e-7ed4-4984-b171-63455ca43ca3",
                        "objectId": "24d50f90-bb61-4057-a909-5ac4ed971798"
                    }
                ]
"@
            } -ParameterFilter {
                $Command -match "^az ad sp list"
            }
            Mock Invoke-Expression { }
        }

        It "It does not create a service principal" {
            New-ServicePrincipal -AppId "a8b1861e-7ed4-4984-b171-63455ca43ca3"

            Should -Not -Invoke Invoke-Expression -ParameterFilter {
                $Command -match "^az ad sp create"
            }
        }

        It "It returns the service principal app id" {
            $sp = New-ServicePrincipal -AppId "a8b1861e-7ed4-4984-b171-63455ca43ca3"

            $sp.appId | Should -Be "a8b1861e-7ed4-4984-b171-63455ca43ca3"
        }

        It "It returns the service principal object id" {
            $sp = New-ServicePrincipal -AppId "a8b1861e-7ed4-4984-b171-63455ca43ca3"

            $sp.objectId | Should -Be "24d50f90-bb61-4057-a909-5ac4ed971798"
        }
    }
}
