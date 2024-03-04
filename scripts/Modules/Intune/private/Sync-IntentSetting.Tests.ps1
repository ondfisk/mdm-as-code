BeforeAll {
    . $PSScriptRoot\..\public\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Sync-Intent" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-IntuneGraphApi { }
        }

        It "It updates settings without id and value" {
            $settings = @(
                [pscustomobject]@{
                    id           = "abf1d04e-6392-402c-bbaa-3038adde38a1"
                    definitionId = "def1"
                    valueJson    = "true"
                    value        = $true
                }
                [pscustomobject]@{
                    id           = "9bd7fe0c-3374-4aae-8bb7-d414a2200ff2"
                    definitionId = "def2"
                    valueJson    = "`"high`""
                    value        = "high"
                }
            )

            Sync-IntentSetting -Id "72889532-554f-433c-98f2-881ec0ea5b3a" -Setting $settings
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Post" -and
                $Resource -eq "deviceManagement/intents/72889532-554f-433c-98f2-881ec0ea5b3a/updateSettings" -and
                $Body.settings[0].id -eq $null -and
                $Body.settings[0].definitionId -eq "def1" -and
                $Body.settings[0].valueJson -eq "true" -and
                $Body.settings[0].value -eq $null -and
                $Body.settings[1].id -eq $null -and
                $Body.settings[1].definitionId -eq "def2" -and
                $Body.settings[1].valueJson -eq "`"high`"" -and
                $Body.settings[1].value -eq $null
            }
        }
    }
}