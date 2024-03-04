BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "Set-ApiPermissionAndPublicClient" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-Expression {}
        }

        It "It patches the application" {
            Set-ApiPermissionAndPublicClient -ObjectId "bc3cc1c4-72f9-4f53-b22d-0e60cc40b32b" -Api "00000003-0000-0000-c000-000000000000" -Permission @(
                [pscustomobject]@{
                    Value = "Directory.Read.All"
                    Id    = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
                    Type  = "Role"
                }
                [pscustomobject]@{
                    Value = "Group.ReadWrite.All"
                    Id    = "62a82d76-70ea-41e2-9197-370581804d09"
                    Type  = "Role"
                }
            )

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az rest --method PATCH --uri https://graph.microsoft.com/v1.0/applications/bc3cc1c4-72f9-4f53-b22d-0e60cc40b32b --headers 'Content-Type=application/json' --body '{\`"isFallbackPublicClient\`":true,\`"publicClient\`":{\`"redirectUris\`":[\`"http://localhost:61485\`"]},\`"requiredResourceAccess\`":[{\`"resourceAppId\`":\`"00000003-0000-0000-c000-000000000000\`",\`"resourceAccess\`":[{\`"id\`":\`"7ab1d382-f21e-4acd-a863-ba3e13f7da61\`",\`"type\`":\`"Role\`"},{\`"id\`":\`"62a82d76-70ea-41e2-9197-370581804d09\`",\`"type\`":\`"Role\`"}]}],\`"web\`":{\`"implicitGrantSettings\`":{\`"enableAccessTokenIssuance\`":false,\`"enableIdTokenIssuance\`":false},\`"redirectUris\`":[]}}'"
            }
        }
    }
}
