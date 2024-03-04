BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "New-AzureDevOpsServiceConnection" {
    Context "Given valid input" {
        BeforeAll {
            Mock Write-Progress { }
            Mock Invoke-Expression {
                @"
                {
                    "id": "c3298af2-39f3-44b0-ae8d-5c121d80f1b7",
                    "name": "My Service Connection"
                }
"@
            } -ParameterFilter {
                $Command -match "^az devops service-endpoint azurerm create"
            }
            Mock Invoke-Expression { }
        }

        It "It gets existing service connections" {
            $password = "c3165fb5-2e92-46a1-acb7-7b791406cccc" | ConvertTo-SecureString -AsPlainText -Force
            New-AzureDevOpsServiceConnection -Organization "MyOrg" `
                -Project "My Project" `
                -TenantId "bcc7620f-290c-419a-9c1a-09bb5f9aee81" `
                -SubscriptionName "My Subscription" `
                -SubscriptionId "a1377463-b45b-4df9-b2f9-120cd9e006af" `
                -Name "My Service Connection" `
                -AppId "6d92459c-36fc-4dcc-82a8-1812c86732c3" `
                -Password $password

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az devops service-endpoint list --org https://dev.azure.com/MyOrg --project 'My Project'"
            }
        }

        It "It stores password as environment variable" {
            $password = "c3165fb5-2e92-46a1-acb7-7b791406cccc" | ConvertTo-SecureString -AsPlainText -Force
            New-AzureDevOpsServiceConnection -Organization "MyOrg" `
                -Project "My Project" `
                -TenantId "bcc7620f-290c-419a-9c1a-09bb5f9aee81" `
                -SubscriptionName "My Subscription" `
                -SubscriptionId "a1377463-b45b-4df9-b2f9-120cd9e006af" `
                -Name "My Service Connection" `
                -AppId "6d92459c-36fc-4dcc-82a8-1812c86732c3" `
                -Password $password

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "`$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY = `"c3165fb5-2e92-46a1-acb7-7b791406cccc`""
            }
        }

        It "It creates service connection" {
            $password = "c3165fb5-2e92-46a1-acb7-7b791406cccc" | ConvertTo-SecureString -AsPlainText -Force
            New-AzureDevOpsServiceConnection -Organization "MyOrg" `
                -Project "My Project" `
                -TenantId "bcc7620f-290c-419a-9c1a-09bb5f9aee81" `
                -SubscriptionName "My Subscription" `
                -SubscriptionId "a1377463-b45b-4df9-b2f9-120cd9e006af" `
                -Name "My Service Connection" `
                -AppId "6d92459c-36fc-4dcc-82a8-1812c86732c3" `
                -Password $password

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az devops service-endpoint azurerm create --org https://dev.azure.com/MyOrg --project 'My Project' --azure-rm-service-principal-id 6d92459c-36fc-4dcc-82a8-1812c86732c3 --azure-rm-tenant-id bcc7620f-290c-419a-9c1a-09bb5f9aee81 --azure-rm-subscription-name 'My Subscription' --azure-rm-subscription-id a1377463-b45b-4df9-b2f9-120cd9e006af --name 'My Service Connection'"
            }
        }

        It "It enables service connection for all pipelines" {
            $password = "c3165fb5-2e92-46a1-acb7-7b791406cccc" | ConvertTo-SecureString -AsPlainText -Force
            New-AzureDevOpsServiceConnection -Organization "MyOrg" `
                -Project "My Project" `
                -TenantId "bcc7620f-290c-419a-9c1a-09bb5f9aee81" `
                -SubscriptionName "My Subscription" `
                -SubscriptionId "a1377463-b45b-4df9-b2f9-120cd9e006af" `
                -Name "My Service Connection" `
                -AppId "6d92459c-36fc-4dcc-82a8-1812c86732c3" `
                -Password $password

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az devops service-endpoint update --org https://dev.azure.com/MyOrg --project 'My Project' --id c3298af2-39f3-44b0-ae8d-5c121d80f1b7 --enable-for-all true"
            }
        }
    }

    Context "Given existing service connection" {
        BeforeAll {
            Mock Write-Progress { }
            Mock Invoke-Expression {
                @"
                [
                    {
                        "id": "934dbdf0-6014-4a87-9236-36cf09f1e1a4",
                        "name": "My Service Connection"
                    }
                ]
"@
            } -ParameterFilter {
                $Command -match "^az devops service-endpoint list"
            }
            Mock Invoke-Expression { }
        }

        It "It deletes existing service connection" {
            $password = "c3165fb5-2e92-46a1-acb7-7b791406cccc" | ConvertTo-SecureString -AsPlainText -Force
            New-AzureDevOpsServiceConnection -Organization "MyOrg" `
                -Project "My Project" `
                -TenantId "bcc7620f-290c-419a-9c1a-09bb5f9aee81" `
                -SubscriptionName "My Subscription" `
                -SubscriptionId "a1377463-b45b-4df9-b2f9-120cd9e006af" `
                -Name "My Service Connection" `
                -AppId "6d92459c-36fc-4dcc-82a8-1812c86732c3" `
                -Password $password

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az devops service-endpoint delete --org https://dev.azure.com/MyOrg --project 'My Project' --id 934dbdf0-6014-4a87-9236-36cf09f1e1a4 --yes"
            }
        }
    }
}
