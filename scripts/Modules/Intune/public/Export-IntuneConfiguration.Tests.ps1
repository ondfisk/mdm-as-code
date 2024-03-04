BeforeAll {
    . $PSScriptRoot\..\private\Get-FolderName.ps1
    . $PSScriptRoot\..\private\Get-FolderNameFromODataType.ps1
    . $PSScriptRoot\..\private\Get-Assignment.ps1
    . $PSScriptRoot\..\private\Get-GroupPolicyConfiguration.ps1
    . $PSScriptRoot\..\private\Get-DeviceCompliancePolicy.ps1
    . $PSScriptRoot\..\private\Get-Intent.ps1
    . $PSScriptRoot\..\private\New-MetaFile.ps1
    . $PSScriptRoot\Invoke-IntuneGraphApi.ps1
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Export-IntuneConfiguration" {
    Context "Given valid input" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                "@odata.type" = "#microsoft.graph.androidWorkProfile"
                id            = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName   = "myconfig"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            $assignments = @(
                [pscustomobject]@{ }
            )

            Mock Get-Assignment { $assignments }
            Mock Add-Member { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock New-MetaFile { }
        }

        It "It gets configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceConfigurations"
            }
        }

        It "It gets assignments" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke Get-Assignment -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $Id -eq "501abe55-f643-4e6c-931e-6f3cc7cec4ef" -and
                $OutputFolder -eq "myoutputfolder"
            }
        }

        It "It sets assignments property on configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke Add-Member -ParameterFilter {
                $InputObject -eq $configuration -and
                $Name -eq "assignments" -and
                $MemberType -eq "NoteProperty" -and
                $Value -eq $assignments[0]
            }
        }

        It "It creates a file name for the configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke Join-Path -ParameterFilter {
                $Path -eq "myoutputfolder" -and
                $ChildPath -eq "deviceManagement/deviceConfigurations/android/myconfig" -and
                $AdditionalChildPath -eq "myconfig.json"
            }
        }

        It "It creates a file for the configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke New-Item -ParameterFilter {
                $Path -eq "joined-path" -and
                $Force -eq $true
            }
        }

        It "It converts configuration to JSON" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $configuration -and
                $Depth -eq 10
            }
        }

        It "It sets content of configuration file" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke Set-Content -ParameterFilter {
                $Value -eq "{}" -and
                $Path -eq "joined-path"
            }
        }

        It "It creates a readme file" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke New-MetaFile -ParameterFilter {
                $Path -eq "joined-path" -and
                $Content -eq "# myconfig"
            }
        }

        It "It creates a transformations file" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke New-MetaFile -ParameterFilter {
                $Path -eq "joined-path" -and
                $Content -eq "[]"
            }
        }
    }

    Context "Given valid input with configurations with trailing whitespace" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                "@odata.type" = "#microsoft.graph.androidWorkProfile"
                id            = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName   = "myconfig "
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            Mock Write-Error { }
        }

        It "It gets configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceConfigurations"
            }
        }

        It "It writes error" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found configuration with leading or trailing whitespace in display name 'myconfig ' aborting..."
            }
        }
    }

    Context "Given valid input with configurations with leading whitespace" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                "@odata.type" = "#microsoft.graph.androidWorkProfile"
                id            = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName   = " myconfig"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            Mock Write-Error { }
        }

        It "It gets configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceConfigurations"
            }
        }

        It "It writes error" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found configuration with leading or trailing whitespace in display name ' myconfig' aborting..."
            }
        }
    }

    Context "Given valid input with groupPolicyConfiguration" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/groupPolicyConfigurations/`$entity"
                id               = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName      = "myconfig"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            $groupPolicyConfiguration = [pscustomobject]@{
                "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/groupPolicyConfigurations/`$entity"
                id               = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName      = "myconfig"
            }

            Mock Get-GroupPolicyConfiguration {
                $groupPolicyConfiguration
            }

            Mock Get-Assignment { @() }
            Mock Add-Member { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock New-MetaFile { }
        }

        It "It gets group policy configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/groupPolicyConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke Get-GroupPolicyConfiguration -ParameterFilter {
                $Id -eq "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
            }
        }

        It "It converts configuration to JSON" {
            Export-IntuneConfiguration -Resource "deviceManagement/groupPolicyConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $groupPolicyConfiguration -and
                $Depth -eq 10
            }
        }
    }

    Context "Given valid input with deviceCompliancePolicy" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceCompliancePolicy/`$entity"
                id               = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName      = "myconfig"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            $deviceCompliancePolicy = [pscustomobject]@{
                "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/deviceCompliancePolicy/`$entity"
                id               = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName      = "myconfig"
            }

            Mock Get-DeviceCompliancePolicy {
                $deviceCompliancePolicy
            }

            Mock Get-Assignment { @() }
            Mock Add-Member { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock New-MetaFile { }
        }

        It "It gets device compliance policy" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceCompliancePolicies" -OutputFolder "myoutputfolder" |
            Should -Invoke Get-DeviceCompliancePolicy -ParameterFilter {
                $Id -eq "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
            }
        }

        It "It converts configuration to JSON" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceCompliancePolicies" -OutputFolder "myoutputfolder" |
            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $deviceCompliancePolicy -and
                $Depth -eq 10
            }
        }
    }

    Context "Given valid input with trustedRootCertificate" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                id                     = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName            = "myconfig"
                trustedRootCertificate = "base64cert"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            Mock Get-Assignment { @() }
            Mock Add-Member { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock New-MetaFile { }
        }

        It "It clears trustedRootCertificate" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            $configuration.trustedRootCertificate | Should -Be $null
        }
    }

    Context "Given valid input with intent" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/intents/`$entity"
                id               = "a5ea271d-f25c-4d98-8e71-6fc8b5d95f9e"
                displayName      = "myintent"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            $intent = [pscustomobject]@{
                "@odata.context" = "https://graph.microsoft.com/beta/`$metadata#deviceManagement/intents/`$entity"
                id               = "a5ea271d-f25c-4d98-8e71-6fc8b5d95f9e"
                displayName      = "myintent"
            }

            Mock Get-Intent {
                $intent
            }

            Mock Get-Assignment { @() }
            Mock Add-Member { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock New-MetaFile { }
        }

        It "It gets intent" {
            Export-IntuneConfiguration -Resource "deviceManagement/intents" -OutputFolder "myoutputfolder" |
            Should -Invoke Get-Intent -ParameterFilter {
                $Id -eq "a5ea271d-f25c-4d98-8e71-6fc8b5d95f9e"
            }
        }

        It "It converts configuration to JSON" {
            Export-IntuneConfiguration -Resource "deviceManagement/intents" -OutputFolder "myoutputfolder" |
            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $intent -and
                $Depth -eq 10
            }
        }
    }

    Context "Given valid input with displayName" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                "@odata.type" = "#microsoft.graph.androidWorkProfile"
                id            = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName   = "myconfig"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            Mock Get-Assignment { @() }
            Mock Add-Member { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock Get-FolderName { "folder" }
            Mock New-MetaFile { }
        }

        It "It gets configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" -DisplayName "myconfiguration" |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceConfigurations?`$filter=displayName+eq+'myconfiguration'"
            }
        }

        It "It gets folder name" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" -DisplayName "myconfiguration" |
            Should -Invoke Get-FolderName -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations" -and
                $DisplayName -eq "myconfig" -and
                $ODataType -eq "#microsoft.graph.androidWorkProfile"
            }
        }

        It "It creates a file name for the configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" -DisplayName "myconfiguration" |
            Should -Invoke Join-Path -ParameterFilter {
                $Path -eq "myoutputfolder" -and
                $ChildPath -eq "folder" -and
                $AdditionalChildPath -eq "myconfig.json"
            }
        }

        It "It creates a file for the configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" -DisplayName "myconfiguration" |
            Should -Invoke New-Item -ParameterFilter {
                $Path -eq "joined-path" -and
                $Force -eq $true
            }
        }

        It "It converts configuration to JSON" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" -DisplayName "myconfiguration" |
            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $configuration -and
                $Depth -eq 10
            }
        }

        It "It sets content of configuration file" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" -DisplayName "myconfiguration" |
            Should -Invoke Set-Content -ParameterFilter {
                $Value -eq "{}" -and
                $Path -eq "joined-path"
            }
        }
    }

    Context "Given valid input with next link" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $android = [pscustomobject]@{
                "@odata.type" = "#microsoft.graph.androidWorkProfile"
                id            = "4af007e8-5370-45e8-9b5a-9b39a7ab506f"
                displayName   = "android-config"
            }
            $windows = [pscustomobject]@{
                "@odata.type" = "#microsoft.graph.windows10GeneralConfiguration"
                id            = "6c3d4688-65f5-467e-a75a-5552beb2f608"
                displayName   = "windows-config.beta"
            }
            $iOS = [pscustomobject]@{
                "@odata.type" = "#microsoft.graph.iosGeneralDeviceConfiguration"
                id            = "71449c34-0016-4572-a634-f9678cc6562c"
                displayName   = "ios-config"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.nextLink" = "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=a"
                    value             = @(
                        $android
                    )
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.nextLink" = "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=b"
                    value             = @(
                        $windows
                    )
                }
            } -ParameterFilter {
                $Resource -eq "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=a"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $iOS
                    )
                }
            } -ParameterFilter {
                $Resource -eq "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=b"
            }

            Mock Get-Assignment { @() }
            Mock Add-Member { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock New-MetaFile { }
        }

        It "It gets configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceConfigurations"
            }
        }

        It "It gets configuration page 2" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=a"
            }
        }

        It "It gets configuration page 3" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=b"
            }
        }

        It "It creates a file name for the Android configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke Join-Path -ParameterFilter {
                $Path -eq "myoutputfolder" -and
                $ChildPath -eq "deviceManagement/deviceConfigurations/android/android-config" -and
                $AdditionalChildPath -eq "android-config.json"
            }
        }

        It "It creates a file name for the Windows configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke Join-Path -ParameterFilter {
                $Path -eq "myoutputfolder" -and
                $ChildPath -eq "deviceManagement/deviceConfigurations/windows/windows-config" -and
                $AdditionalChildPath -eq "windows-config.beta.json"
            }
        }

        It "It creates a file name for the iOS configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke Join-Path -ParameterFilter {
                $Path -eq "myoutputfolder" -and
                $ChildPath -eq "deviceManagement/deviceConfigurations/iOS/iOS-config" -and
                $AdditionalChildPath -eq "iOS-config.json"
            }
        }

        It "It creates a file for the configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke New-Item -ParameterFilter {
                $Path -eq "joined-path" -and
                $Force -eq $true
            } -Times 3
        }

        It "It converts Android configuration to JSON" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $android -and
                $Depth -eq 10
            }
        }

        It "It converts Windows configuration to JSON" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $windows -and
                $Depth -eq 10
            }
        }

        It "It converts iOS configuration to JSON" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke ConvertTo-Json -ParameterFilter {
                $InputObject -eq $iOS -and
                $Depth -eq 10
            }
        }

        It "It sets content of configuration file" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |
            Should -Invoke Set-Content -ParameterFilter {
                $Value -eq "{}" -and
                $Path -eq "joined-path"
            } -Times 3
        }
    }

    Context "Given valid input with next link and multiple configurations with same display name" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $same1 = [pscustomobject]@{
                id          = "4af007e8-5370-45e8-9b5a-9b39a7ab506f"
                displayName = "Same"
            }
            $same2 = [pscustomobject]@{
                id          = "6c3d4688-65f5-467e-a75a-5552beb2f608"
                displayName = "SAME"
            }
            $other = [pscustomobject]@{
                id          = "71449c34-0016-4572-a634-f9678cc6562c"
                displayName = "ios-config"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.nextLink" = "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=a"
                    value             = @(
                        $same1
                    )
                }
            } -ParameterFilter {
                $Resource -eq "deviceManagement/deviceConfigurations"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    "@odata.nextLink" = "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=b"
                    value             = @(
                        $other
                    )
                }
            } -ParameterFilter {
                $Resource -eq "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=a"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $same2
                    )
                }
            } -ParameterFilter {
                $Resource -eq "$script:graphBaseUri/v1.0/deviceManagement/deviceConfigurations?`$skiptoken=b"
            }

            Mock Get-Assignment { @() }
            Mock Add-Member { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock New-MetaFile { }
            Mock Write-Error { }
        }

        It "It writes error" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" |

            Should -Invoke Write-Error -ParameterFilter {
                $Message -eq "Found multiple deviceManagement/deviceConfigurations with the display name 'same' (case insensitive) aborting..."
            }
        }
    }

    Context "Given valid input with -SkipDetails" {
        BeforeAll {
            Mock Join-Path { "joined-path" }

            $configuration = [pscustomobject]@{
                "@odata.type" = "#microsoft.graph.androidWorkProfile"
                id            = "501abe55-f643-4e6c-931e-6f3cc7cec4ef"
                displayName   = "myconfig"
            }

            Mock Invoke-IntuneGraphApi {
                [pscustomobject]@{
                    value = @(
                        $configuration
                    )
                }
            }

            Mock Get-Assignment { }
            Mock New-Item { }
            Mock ConvertTo-Json { "{}" }
            Mock Set-Content { }
            Mock New-MetaFile { }
        }

        It "It gets configuration" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder"

            Should -Invoke Invoke-IntuneGraphApi -ParameterFilter {
                $Method -eq "Get" -and
                $Resource -eq "deviceManagement/deviceConfigurations"
            }
        }

        It "It does not get assignments" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" -SkipDetails

            Should -Not -Invoke Get-Assignment
        }

        It "It does not create meta files" {
            Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder "myoutputfolder" -SkipDetails

            Should -Not -Invoke New-MetaFile
        }
    }
}
