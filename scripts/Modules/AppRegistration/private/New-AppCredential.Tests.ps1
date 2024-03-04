BeforeAll {
    . $PSCommandPath.Replace('.Tests', '')
}

Describe "New-AppCredential" {
    Context "Given no existing credentials" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                {
                    "appId": "ea9c3a50-963d-47a6-8649-3bc4272e18e4",
                    "password": "generated-password"
                }
"@
            } -ParameterFilter {
                $Command -match "^az ad app credential reset"
            }
            Mock Invoke-Expression { }
        }

        It "It gets existing credential" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad app credential list --id ea9c3a50-963d-47a6-8649-3bc4272e18e4"
            }
        }

        It "It creates new credential" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad app credential reset --id ea9c3a50-963d-47a6-8649-3bc4272e18e4 --credential-description `"Intune`""
            }
        }

        It "It returns password" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4" |
            ConvertFrom-SecureString -AsPlainText |
            Should -Be "generated-password"
        }
    }

    Context "Given Force" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                {
                    "appId": "ea9c3a50-963d-47a6-8649-3bc4272e18e4",
                    "password": "generated-password"
                }
"@
            } -ParameterFilter {
                $Command -match "^az ad app credential reset"
            }
            Mock Invoke-Expression { }
        }

        It "It does not get existing credential" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4" -Force

            Should -Not -Invoke Invoke-Expression -ParameterFilter {
                $Command -match "^az ad app credential list"
            }
        }

        It "It creates new credential" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4" -Force

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad app credential reset --id ea9c3a50-963d-47a6-8649-3bc4272e18e4 --credential-description `"Intune`""
            }
        }

        It "It returns password" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4" -Force |
            ConvertFrom-SecureString -AsPlainText |
            Should -Be "generated-password"
        }
    }

    Context "Given existing credentials does not expire within 60 days" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                [
                    {
                        "endDate": "$((Get-Date).AddDays(-7).ToString("s"))"
                    },
                    {
                        "endDate": "$((Get-Date).AddDays(61).ToString("s"))"
                    }
                ]
"@
            } -ParameterFilter {
                $Command -match "^az ad app credential list"
            }
            Mock Invoke-Expression { }
        }

        It "It does not create new credential" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4"

            Should -Not -Invoke Invoke-Expression -ParameterFilter {
                $Command -match "^az ad app credential reset"
            }
        }

        It "It does not return password" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4" | Should -Be $null
        }
    }

    Context "Given existing credentials has expired" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                [
                    {
                        "endDate": "$((Get-Date).AddDays(-7).ToString("s"))"
                    },
                    {
                        "endDate": "$((Get-Date).AddDays(-365).ToString("s"))"
                    }
                ]
"@
            } -ParameterFilter {
                $Command -match "^az ad app credential list"
            }
            Mock Invoke-Expression {
                @"
                {
                    "appId": "ea9c3a50-963d-47a6-8649-3bc4272e18e4",
                    "password": "generated-password"
                }
"@
            }
        }

        It "It creates new credential" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad app credential reset --id ea9c3a50-963d-47a6-8649-3bc4272e18e4 --credential-description `"Intune`""
            }
        }
    }

    Context "Given existing credentials will expire within 60 days" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                [
                    {
                        "endDate": "$((Get-Date).AddDays(59).ToString("s"))"
                    },
                    {
                        "endDate": "$((Get-Date).AddDays(-365).ToString("s"))"
                    }
                ]
"@
            } -ParameterFilter {
                $Command -match "^az ad app credential list"
            }
            Mock Invoke-Expression {
                @"
                {
                    "appId": "ea9c3a50-963d-47a6-8649-3bc4272e18e4",
                    "password": "generated-password"
                }
"@
            }
        }

        It "It appends new credential" {
            New-AppCredential -AppId "ea9c3a50-963d-47a6-8649-3bc4272e18e4"

            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az ad app credential reset --id ea9c3a50-963d-47a6-8649-3bc4272e18e4 --credential-description `"Intune`" --append"
            }
        }
    }
}
