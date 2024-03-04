BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "Grant-ApiPermission" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                {
                    "objectId": "ec873540-7b10-4fa7-b64f-3e31dee32a62"
                }
"@
            } -ParameterFilter {
                $Command -match "^az ad sp show --id"
            }
            Mock Invoke-Expression { }
        }

        It "It gets the resourceId" {
            Grant-ApiPermission -ServicePrincipalObjectId "a8b1861e-7ed4-4984-b171-63455ca43ca3" -Api "00000003-0000-0000-c000-000000000000" -Permission "Directory.Read.All", "User.Read"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad sp show --id 00000003-0000-0000-c000-000000000000"
            }
        }

        It "It creates grant" {
            Grant-ApiPermission -ServicePrincipalObjectId "a8b1861e-7ed4-4984-b171-63455ca43ca3" -Api "00000003-0000-0000-c000-000000000000" -Permission "Directory.Read.All", "User.Read"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az rest --method POST --uri https://graph.microsoft.com/v1.0/oauth2PermissionGrants --headers 'Content-Type=application/json' --body '{\`"clientId\`":\`"a8b1861e-7ed4-4984-b171-63455ca43ca3\`",\`"consentType\`":\`"AllPrincipals\`",\`"principalId\`":null,\`"resourceId\`":\`"ec873540-7b10-4fa7-b64f-3e31dee32a62\`",\`"scope\`":\`"Directory.Read.All User.Read\`"}'"
            }
        }
    }

    Context "Given existing grant" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                {
                    "objectId": "ec873540-7b10-4fa7-b64f-3e31dee32a62"
                }
"@
            } -ParameterFilter {
                $Command -match "^az ad sp show --id"
            }
            Mock Invoke-Expression {
                @"
                {
                    "value": [
                        {
                            "clientId": "16694626-401f-4b29-be9b-d9b687cd4ea3",
                            "consentType": "AllPrincipals",
                            "id": "...",
                            "principalId": null,
                            "resourceId": "ec873540-7b10-4fa7-b64f-3e31dee32a62",
                            "scope": "..."
                        },
                        {
                            "clientId": "a8b1861e-7ed4-4984-b171-63455ca43ca3",
                            "consentType": "AllPrincipals",
                            "id": "id-to-update",
                            "principalId": null,
                            "resourceId": "ec873540-7b10-4fa7-b64f-3e31dee32a62",
                            "scope": "..."
                        },
                        {
                            "clientId": "a8b1861e-7ed4-4984-b171-63455ca43ca3",
                            "consentType": "AllPrincipals",
                            "id": "...",
                            "principalId": null,
                            "resourceId": "de3584cc-c2cb-4270-ba67-b370a1b91baa",
                            "scope": "..."
                        }
                    ]
                }
"@
            } -ParameterFilter {
                $Command -eq "az rest --method GET --uri https://graph.microsoft.com/v1.0/oauth2PermissionGrants"
            }
            Mock Invoke-Expression { }
        }

        It "It updates existing grant" {
            Grant-ApiPermission -ServicePrincipalObjectId "a8b1861e-7ed4-4984-b171-63455ca43ca3" -Api "00000003-0000-0000-c000-000000000000" -Permission "Directory.Read.All", "User.Read"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az rest --method PATCH --uri https://graph.microsoft.com/v1.0/oauth2PermissionGrants/id-to-update --headers 'Content-Type=application/json' --body '{\`"scope\`":\`"Directory.Read.All User.Read\`"}'"
            }
        }
    }
}
