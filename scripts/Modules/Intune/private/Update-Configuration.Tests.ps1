BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-ValueFromKeyVault" {
    Context "Given valid input" {
        BeforeAll {
            Mock Invoke-Expression {
                @"
                    {
                        "value": "the-secret"
                    }
"@
            }
        }

        It "It gets value from key vault" {
            Get-ValueFromKeyVault -KeyVaultName "vault" -SecretName "secret"
            Should -Invoke Invoke-Expression -ParameterFilter {
                $Command -eq "az keyvault secret show --vault-name vault --name secret"
            }
        }

        It "It returns value" {
            Get-ValueFromKeyVault -KeyVaultName "vault" -SecretName "secret" | Should -Be "the-secret"
        }
    }
}

Describe "Set-Value" {
    Context "Given valid input" {
        It "With root property; it transforms object" {
            $object = [pscustomobject]@{
                id     = "f789a6c5-ac3b-4967-a006-18ea530e961f"
                level0 = "foo"
            }

            Set-Value -Object $object -Key "level0" -Value "bar"

            $object.level0 | Should -Be "bar"
        }

        It "With nested property; It transforms object" {
            $object = [pscustomobject]@{
                id     = "f789a6c5-ac3b-4967-a006-18ea530e961f"
                level0 = [pscustomobject]@{
                    level1 = "foo"
                }
            }

            Set-Value -Object $object -Key "level0.level1" -Value "bar"

            $object.level0.level1 | Should -Be "bar"
        }

        It "With array property; It transforms object" {
            $object = [pscustomobject]@{
                id     = "f789a6c5-ac3b-4967-a006-18ea530e961f"
                level0 = @(
                    [pscustomobject]@{
                        level1 = "foo"
                    }
                    [pscustomobject]@{
                        level1 = "foo"
                    }
                    [pscustomobject]@{
                        level1 = "foo"
                    }
                )
            }

            Set-Value -Object $object -Key "level0[1].level1" -Value "bar"

            $object.level0[0].level1 | Should -Be "foo"
            $object.level0[1].level1 | Should -Be "bar"
            $object.level0[2].level1 | Should -Be "foo"
        }

        It "With nested object property; It transforms object" {
            $object = [pscustomobject]@{
                id     = "f789a6c5-ac3b-4967-a006-18ea530e961f"
                level0 = @(
                    [pscustomobject]@{ }
                    [pscustomobject]@{
                        level1 = @(
                            [pscustomobject]@{ }
                            [pscustomobject]@{
                                level2 = $null
                            }
                            [pscustomobject]@{ }
                        )
                    }
                    [pscustomobject]@{ }
                )
            }

            Set-Value -Object $object -Key "level0[1].level1[1].level2" -Value ([pscustomobject]@{ foo = "bar" })

            $object.level0[1].level1[1].level2.foo | Should -Be "bar"
        }

        It "With non-existing property; It throws" {
            $object = [pscustomobject]@{
                id = "f789a6c5-ac3b-4967-a006-18ea530e961f"
            }

            { Set-Value -Object $object -Key "level0" -Value "bar" } | Should -Throw
        }
    }
}

Describe "Update-Configuration" {
    Context "Given no transformation" {
        BeforeAll {
            Mock Set-Value { }
        }

        It "It does not set value (transformation: <Case>)" -TestCases @(
            @{ Case = "null" ; Transformation = $null }
            @{ Case = "empty" ; Transformation = @() }
        ) {
            $configuration = [pscustomobject]@{ displayName = "name" }

            Update-Configuration -Configuration $configuration -Transformation $Transformation

            Should -Not -Invoke Set-Value
        }
    }

    Context "Given transformation contains value" {
        BeforeAll {
            Mock Set-Value { }
            Mock Get-ValueFromKeyVault {
                "the-secret"
            }
        }

        BeforeEach {
            $configuration = [pscustomobject]@{ displayName = "name" }

            $transformation = @(
                [pscustomobject]@{
                    key   = "my-key"
                    value = "my-value"
                }
                [pscustomobject]@{
                    key       = "my-key-2"
                    reference = [pscustomobject]@{
                        keyVaultName = "my-key-vault"
                        secretName   = "my-secret"
                    }
                }
            )
        }

        It "It sets value for value" {
            Update-Configuration -Configuration $configuration -Transformation $transformation

            Should -Invoke Set-Value -ParameterFilter {
                $Object -eq $configuration
                $Key -eq "my-key"
                $Value -eq "my-value"
            }
        }

        It "It gets secret from key vault" {
            Update-Configuration -Configuration $configuration -Transformation $transformation

            Should -Invoke Get-ValueFromKeyVault -ParameterFilter {
                $KeyVaultName -eq "my-key-vault"
                $SecretName -eq "my-secret"
            }
        }

        It "It sets value for reference" {
            Update-Configuration -Configuration $configuration -Transformation $transformation

            Should -Invoke Set-Value -ParameterFilter {
                $Object -eq $configuration
                $Key -eq "my-key-2"
                $Value -eq "the-secret"
            }
        }

        It "It returns configuration" {
            Update-Configuration -Configuration $configuration -Transformation $transformation |
            Should -Be $configuration
        }
    }
}
