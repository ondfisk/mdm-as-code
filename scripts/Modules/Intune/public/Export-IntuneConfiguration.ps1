using namespace System.Management.Automation

$script:resources = @(
    "deviceManagement/deviceConfigurations"
    "deviceManagement/deviceCompliancePolicies"
    "deviceManagement/groupPolicyConfigurations"
    "deviceManagement/intents"
    "deviceManagement/windowsAutopilotDeploymentProfiles"
)

class ValidResources : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $script:resources
    }
}

function Export-IntuneConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet([ValidResources], IgnoreCase = $true)]
        [string]
        $Resource,

        [Parameter(Mandatory = $false)]
        [string]
        $DisplayName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputFolder,

        [Parameter(Mandatory = $false)]
        [switch]
        $SkipDetails
    )

    begin { }

    process {
        if ($DisplayName) {
            $filter = "?`$filter=displayName+eq+'$DisplayName'"
        }
        $uri = "$Resource$filter"

        $exportedDisplayNames = New-Object -TypeName "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)

        do {
            $configurations = Invoke-IntuneGraphApi -Method Get -Resource $uri

            $count = $configurations.value.Count

            Write-Log -Level INFO -Message "Exporting $count configurations..." -Body @{Function = 'Export-IntuneConfiguration'; ObjectName = $configuration.displayName; ObjectId = "N/A" }

            $configurations.value | ForEach-Object {
                $configuration = $PSItem
                $displayName = $configuration.displayName

                if (-not $exportedDisplayNames.Add($displayName)) {
                    $message = "Found multiple $Resource with the display name '$displayName' (case insensitive) aborting..."
                    Write-Log -Level ERROR -Message $message -Body @{Function = 'Export-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }
                    Write-Error -Message $message
                }
                else {
                    if ($displayName -match "^\s" -or $displayName -match "\s$") {
                        $message = "Found configuration with leading or trailing whitespace in display name '$displayName' aborting..."
                        Write-Log -Level ERROR -Message $message -Body @{Function = 'Export-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }
                        Write-Error -Message $message
                    }
                    else {
                        $folder = Get-FolderName -Resource $Resource -DisplayName $displayName -ODataType $configuration."@odata.type"
                        $outputFile = Join-Path -Path $OutputFolder -ChildPath $folder -AdditionalChildPath "$displayName.json"
                        Write-Log -Level INFO -Message "Exporting $outputFile..." -Body @{Function = 'Export-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }
                        New-Item -Path $outputFile -Force | Out-Null

                        # Clear certificate if any
                        if ($configuration.trustedRootCertificate) {
                            $configuration.trustedRootCertificate = $null
                        }

                        if (-not $SkipDetails) {
                            if ($Resource -eq "deviceManagement/groupPolicyConfigurations") {
                                Write-Log -Level INFO -Message "Getting definition and presentation values for group policy configuration..." -Body @{Function = 'Export-IntuneConfiguration'; ObjectName = "N/A"; ObjectId = $configuration.id }
                                $configuration = Get-GroupPolicyConfiguration -Id $configuration.id
                            }
                            if ($Resource -eq "deviceManagement/deviceCompliancePolicies") {
                                Write-Log -Level INFO -Message "Getting scheduled actions for rule device compliance policy..." -Body @{Function = 'Export-IntuneConfiguration'; ObjectName = "N/A"; ObjectId = $configuration.id }
                                $configuration = Get-DeviceCompliancePolicy -Id $configuration.id
                            }
                            if ($Resource -eq "deviceManagement/intents") {
                                Write-Log -Level INFO -Message "Getting settings for intent..." -Body @{Function = 'Export-IntuneConfiguration'; ObjectName = "N/A"; ObjectId = $configuration.id }
                                $configuration = Get-Intent -Id $configuration.id
                            }

                            [array]$assignments = Get-Assignment -Resource $Resource -Id $configuration.id -OutputFolder $OutputFolder
                            $configuration | Add-Member -Name "assignments" -MemberType NoteProperty -Value $assignments

                            $readme = Join-Path -Path $OutputFolder -ChildPath $folder -AdditionalChildPath "README.md"
                            New-MetaFile -Path $readme -Content "# $displayName"

                            $transformations = Join-Path -Path $OutputFolder -ChildPath $folder -AdditionalChildPath "transformations.json"
                            New-MetaFile -Path $transformations -Content "[]"
                        }

                        ConvertTo-Json -InputObject $configuration -Depth 10 | Set-Content -Path $outputFile
                    }
                }
            }

            $uri = $configurations."@odata.nextLink"
        }
        while ($uri)
    }

    end { }
}
