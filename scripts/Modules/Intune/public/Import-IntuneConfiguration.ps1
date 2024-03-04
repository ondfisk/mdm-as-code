function Import-IntuneConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $InputFolder,

        [string]
        $Environment
    )

    begin { }

    process {
        Get-ChildItem -Path $InputFolder -Filter "*.json" -Exclude "transformations.json" -Recurse |
        Where-Object FullName -NotMatch "[/\\]groups[/\\]" |
        ForEach-Object {
            $configuration = Get-Content -Path $PSItem.FullName | ConvertFrom-Json
            $displayName = $configuration.displayName

            $info = $PSItem.FullName | ConvertFrom-ConfigurationFileName
            $resource = $info.Resource
            $fullName = $info.FullName

            $transformationsFile = Join-Path -Path $PSItem.Directory -ChildPath "transformations.json"
            if (Test-Path -Path $transformationsFile) {
                $transformations = Get-Content -Path $transformationsFile |
                ConvertFrom-Json |
                Where-Object configuration -EQ $displayName |
                Select-Object -ExpandProperty transformations |
                Where-Object environment -EQ $Environment
            }
            if ($transformations) {
                $configuration = Update-Configuration -Configuration $configuration -Transformation $transformations
            }

            $assignments = $configuration.assignments
            $configuration.PSObject.Properties.Remove("assignments")

            $definitionValues = $configuration.definitionValues
            $configuration.PSObject.Properties.Remove("definitionValues")

            $templateDisplayName = $configuration.templateDisplayName
            $configuration.PSObject.Properties.Remove("templateDisplayName")

            if ($resource -eq "deviceManagement/intents" -and $templateDisplayName) {
                Write-Log -Level INFO -Message "Getting template..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $templateDisplayName; ObjectId = "N/A" }

                $template = Get-Template -DisplayName $templateDisplayName
                $configuration.templateId = $template.id
            }

            Write-Log -Level INFO -Message "Checking for existing configuration: $displayName..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }

            $found = Invoke-IntuneGraphApi -Method Get `
                -Resource "${resource}?`$filter=displayName+eq+'$displayName'"

            $existing = $found.value

            if ($existing.Count -gt 1) {
                Write-Log -Level ERROR -Message "Found multiple $resource with the display name '$displayName' aborting..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }
                Write-Error -Message "Found multiple $resource with the display name '$displayName' aborting..."
            }
            else {
                if ($existing) {
                    if ($PSCmdlet.ShouldProcess($fullName, "UPDATE")) {
                        $id = $existing.id
                        $configuration.id = $id

                        # Patching scheduledActionsForRule is not supported currently
                        # https://docs.microsoft.com/en-us/graph/api/intune-deviceconfig-devicecompliancescheduledactionforrule-update?view=graph-rest-beta
                        $configuration.PSObject.Properties.Remove("scheduledActionsForRule")

                        # Patching settings is not supported
                        $settings = $configuration.settings
                        $configuration.PSObject.Properties.Remove("settings")

                        # Patching isAssigned and lastModifiedDateTime is not supported
                        $configuration.PSObject.Properties.Remove("isAssigned")
                        $configuration.PSObject.Properties.Remove("lastModifiedDateTime")
                        $configuration.PSObject.Properties.Remove("templateId")

                        $reference = $existing | Select-Object -ExcludeProperty id, lastModifiedDateTime, createdDateTime, version, isAssigned, templateId | ConvertTo-Json -Depth 10
                        $difference = $configuration | Select-Object -ExcludeProperty id, lastModifiedDateTime, createdDateTime, version, isAssigned, templateId | ConvertTo-Json -Depth 10

                        $compare = Compare-Object -ReferenceObject $reference -DifferenceObject $difference

                        if ($compare) {
                            Write-Log -Level INFO -Message "$displayName found. Updating..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = $resource + '/' + $id }

                            Invoke-IntuneGraphApi -Method Patch `
                                -Resource "$resource/$id" `
                                -Body $configuration `
                            | Out-Null
                        }
                        else {
                            Write-Log -Level INFO -Message "$displayName found unchanged. Skipping..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = $resource + '/' + $id }
                        }

                        if ($resource -eq "deviceManagement/intents") {
                            Write-Log -Level INFO -Message "Importing intent settings values for $displayName..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = $id }

                            Sync-IntentSetting -Id $id -Setting $settings
                        }

                        Write-Log -Level INFO -Message "Updating assignments for $displayName..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = $id }

                        Sync-Assignment -Resource $resource -Id $id -Assignment $assignments

                        if ($resource -eq "deviceManagement/groupPolicyConfigurations") {
                            Write-Log -Level INFO -Message "Importing definition values..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = $id }

                            Sync-GroupPolicyConfigurationDefinitionValue -Id $id -DefinitionValue $definitionValues
                        }
                    }
                }
                else {
                    if ($PSCmdlet.ShouldProcess($fullName, "CREATE")) {
                        Write-Log -Level INFO -Message "$displayName not found. Creating..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }
                        $configuration = Invoke-IntuneGraphApi -Method Post `
                            -Resource $resource `
                            -Body $configuration `

                        $id = $configuration.id

                        Write-Log -Level INFO -Message "Updating assignments..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = $id }

                        Sync-Assignment -Resource $resource -Id $id -Assignment $assignments

                        if ($resource -eq "deviceManagement/groupPolicyConfigurations") {
                            Write-Log -Level INFO -Message "Importing definition values..." -Body @{Function = 'Import-IntuneConfiguration'; ObjectName = $displayName; ObjectId = $id }

                            Sync-GroupPolicyConfigurationDefinitionValue -Id $id -DefinitionValue $definitionValues
                        }
                    }
                }
            }
        }
    }

    end { }
}
