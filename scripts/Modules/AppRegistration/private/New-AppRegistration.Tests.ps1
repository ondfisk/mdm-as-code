BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "New-AppRegistration" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                {
                    "appId": "4310891a-7def-495e-8719-ede4eecf2197",
                    "displayName": "IntuneApp",
                    "objectId": "10522b33-42c5-49ba-adba-805a69b03ad7"
                }
"@
            } -ParameterFilter {
                $Command -match "^az ad app create"
            }
            Mock Invoke-Expression { }
        }

        It "It creates app registration" {
            New-AppRegistration -DisplayName "IntuneApp"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad app create --display-name `"IntuneApp`""
            }
        }

        It "It returns appId" {
            $app = New-AppRegistration -DisplayName "IntuneApp"

            $app.appId | Should -Be "4310891a-7def-495e-8719-ede4eecf2197"
        }

        It "It returns objectId" {
            $app = New-AppRegistration -DisplayName "IntuneApp"

            $app.objectId | Should -Be "10522b33-42c5-49ba-adba-805a69b03ad7"
        }
    }
}
