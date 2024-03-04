BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "Get-Account" {
    Context "Given no input" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                {
                    "environmentName": "AzureCloud",
                    "id": "7512cf52-57c0-400f-9aa1-d4d41d389956",
                    "name": "My Subscription",
                    "state": "Enabled",
                    "tenantId": "45f6b7ec-c94a-40ca-bd4b-e9de5441efc7"
                }
"@
            }
        }

        It "It gets current account" {
            Get-Account

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az account show"
            }
        }

        It "It returns tenant id" {
            $account = Get-Account

            $account.TenantId | Should -Be "45f6b7ec-c94a-40ca-bd4b-e9de5441efc7"
        }

        It "It returns subscription name" {
            $account = Get-Account

            $account.SubscriptionName | Should -Be "My Subscription"
        }

        It "It returns subscription id" {
            $account = Get-Account

            $account.SubscriptionId | Should -Be "7512cf52-57c0-400f-9aa1-d4d41d389956"
        }
    }
}
