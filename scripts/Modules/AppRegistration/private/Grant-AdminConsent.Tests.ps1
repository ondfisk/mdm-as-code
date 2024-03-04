BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "Grant-AdminConsent" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-Expression { }
        }

        It "It grants permissions" {
            Grant-AdminConsent -AppId "a8b1861e-7ed4-4984-b171-63455ca43ca3"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad app permission admin-consent --id a8b1861e-7ed4-4984-b171-63455ca43ca3"
            }
        }
    }
}
