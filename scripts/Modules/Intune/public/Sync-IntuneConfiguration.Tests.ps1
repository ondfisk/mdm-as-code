BeforeAll {
    . $PSScriptRoot\..\private\ConvertFrom-ConfigurationFileName.ps1
    . $PSScriptRoot\Invoke-IntuneGraphApi.ps1
    . $PSScriptRoot\Export-IntuneConfiguration.ps1
    . $PSScriptRoot\Import-IntuneConfiguration.ps1
    . $PSScriptRoot\Remove-IntuneConfiguration.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Sync-IntuneConfiguration" {
    Context "Given valid input" {
        BeforeAll {
            Mock Resolve-Path { "/temp/" } -ParameterFilter {
                $Path -eq "temp"
            }
            Mock Resolve-Path { "/input/" } -ParameterFilter {
                $Path -eq "input"
            }
            Mock Test-Path { $true } -ParameterFilter {
                $Path -eq "/input/deviceManagement/deviceConfigurations/keep/keep.json"
            }
            Mock Test-Path { }

            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{ FullName = "/temp/deviceManagement" }
                )
            } -ParameterFilter {
                $Exclude -eq ".gitignore"
            }

            Mock Get-ChildItem {
                @(
                    [pscustomobject]@{ FullName = "/temp/deviceManagement/deviceConfigurations/delete/delete.json" }
                    [pscustomobject]@{ FullName = "/temp/deviceManagement/deviceConfigurations/keep/keep.json" }
                )
            }

            Mock New-Item { }
            Mock Remove-Item { }
            Mock Export-IntuneConfiguration { }
            Mock Remove-IntuneConfiguration { }
            Mock Import-IntuneConfiguration { }
            Mock Write-Warning { }
        }

        It "It creates temp folder" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke New-Item -ParameterFilter {
                $Path -eq "temp" -and
                $ItemType -eq "Directory"
            }
        }

        It "It gets existing data in temp folder excluding .gitignore" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke Get-ChildItem -ParameterFilter {
                $Path -eq "temp" -and
                $Exclude -eq ".gitignore"
            }
        }

        It "It removes existing data in temp folder" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke Remove-Item -ParameterFilter {
                $Recurse -eq $true -and
                $Force -eq $true
            }
        }

        It "It exports deviceManagement/deviceConfigurations to TempFolder" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke Export-IntuneConfiguration -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $OutputFolder -eq "temp" -and
                $SkipDetails -eq $true
            }
        }

        It "It exports deviceManagement/deviceCompliancePolicies to TempFolder" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke Export-IntuneConfiguration -ParameterFilter {
                $Resource -eq "deviceManagement/deviceCompliancePolicies" -and
                $OutputFolder -eq "temp" -and
                $SkipDetails -eq $true
            }
        }

        It "It exports deviceManagement/groupPolicyConfigurations to TempFolder" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke Export-IntuneConfiguration -ParameterFilter {
                $Resource -eq "deviceManagement/groupPolicyConfigurations" -and
                $OutputFolder -eq "temp" -and
                $SkipDetails -eq $true
            }
        }

        It "It gets existing configurations from TempFolder" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke Get-ChildItem -ParameterFilter {
                $Path -eq "temp" -and
                $File -eq $true -and
                $Filter -eq "*.json" -and
                $Exclude -eq "transformations.json" -and
                $Recurse -eq $true
            }
        }

        It "It removes 'delete' configuration" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke Remove-IntuneConfiguration -ParameterFilter {
                $ConfigurationFileName -eq "/temp/deviceManagement/deviceConfigurations/delete/delete.json"
            }
        }

        It "It does not remove 'keep' configuration" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Not -Invoke Remove-IntuneConfiguration -ParameterFilter {
                $ConfigurationFileName -eq "/temp/deviceManagement/deviceConfigurations/keep/keep.json"
            }
        }

        It "It imports configurations" {
            Sync-IntuneConfiguration -InputFolder "input" -TempFolder "temp" -Environment "env"

            Should -Invoke Import-IntuneConfiguration -ParameterFilter {
                $InputFolder -eq "input" -and
                $Environment -eq "env"
            }
        }
    }
}
