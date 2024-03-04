function Sync-GroupPolicyConfigurationDefinitionValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Id,

        [psobject[]]
        $DefinitionValue
    )

    begin { }

    process {
        $existing = Get-GroupPolicyConfiguration -Id $Id

        $existing.definitionValues | ForEach-Object {
            if (-not ($DefinitionValue."definition@odata.bind" -contains $PSItem."definition@odata.bind")) {
                $definitionValueId = $PSItem.id
                # TODO: get object name
                Write-Log -Level INFO  "Deleting definition value: $definitionValueId..." -Body @{Function = 'Sync-GroupPolicyConfigurationDefinitionValue'; ObjectName = "N/A"; ObjectId = $definitionValueId }

                Invoke-IntuneGraphApi -Method Delete `
                    -Resource "deviceManagement/groupPolicyConfigurations/$Id/definitionValues/$definitionValueId" `
                | Out-Null
            }
        }

        $DefinitionValue | ForEach-Object {
            $definitionId = $PSItem."definition@odata.bind"
            $existingDefinitionValue = $existing.definitionValues | Where-Object { $PSItem."definition@odata.bind" -eq $definitionId }

            if ($existingDefinitionValue) {
                $definitionValueId = $existingDefinitionValue.id
                $PSItem.id = $definitionValueId

                # TODO: get object name
                Write-Log -Level INFO  "Updating definition value: $definitionValueId..." -Body @{Function = 'Sync-GroupPolicyConfigurationDefinitionValue'; ObjectName = "N/A"; ObjectId = $definitionValueId }

                $presentationValues = $PSItem.presentationValues

                $PSItem.PSObject.Properties.Remove("presentationValues")

                Invoke-IntuneGraphApi -Method Patch `
                    -Resource "deviceManagement/groupPolicyConfigurations/$Id/definitionValues/$definitionValueId" `
                    -Body $PSItem `
                | Out-Null

                # TODO: get object name
                Write-Log -Level INFO  "Updating presentation values for definition value: $definitionValueId..." -Body @{Function = 'Sync-GroupPolicyConfigurationDefinitionValue'; ObjectName = "N/A"; ObjectId = $definitionValueId }

                $existingDefinitionValue.presentationValues | ForEach-Object {
                    if (-not ($presentationValues."presentation@odata.bind" -contains $PSItem."presentation@odata.bind")) {
                        $presentationValueId = $PSItem.id

                        # TODO: get object name
                        Write-Log -Level INFO  "Deleting presentation value: $presentationValueId..." -Body @{Function = 'Sync-GroupPolicyConfigurationDefinitionValue'; ObjectName = "N/A"; ObjectId = $presentationValueId }

                        Invoke-IntuneGraphApi -Method Delete `
                            -Resource "deviceManagement/groupPolicyConfigurations/$Id/definitionValues/$definitionValueId/presentationValues/$presentationValueId" `
                        | Out-Null
                    }
                }

                if ($presentationValues) {
                    $presentationValues | ForEach-Object {
                        $presentationId = $PSItem."presentation@odata.bind"
                        $existingPresentationValue = $existingDefinitionValue.presentationValues | Where-Object { $PSItem."presentation@odata.bind" -eq $presentationId }

                        if ($existingPresentationValue) {
                            $presentationValueId = $existingPresentationValue.id
                            $PSItem.id = $presentationValueId
                            # TODO: get object name
                            Write-Log -Level INFO  "Updating presentation value: $presentationValueId..." -Body @{Function = 'Sync-GroupPolicyConfigurationDefinitionValue'; ObjectName = "N/A"; ObjectId = $presentationValueId }

                            Invoke-IntuneGraphApi -Method Patch `
                                -Resource "deviceManagement/groupPolicyConfigurations/$Id/definitionValues/$definitionValueId/presentationValues/$presentationValueId" `
                                -Body $PSItem `
                            | Out-Null
                        }
                        else {
                            $PSItem.PSObject.Properties.Remove("id")

                            # TODO: get object name
                            Write-Log -Level INFO  "Creating presentation value..." -Body @{Function = 'Sync-GroupPolicyConfigurationDefinitionValue'; ObjectName = "N/A"; ObjectId = $definitionValueId }

                            Invoke-IntuneGraphApi -Method Post `
                                -Resource "deviceManagement/groupPolicyConfigurations/$Id/definitionValues/$definitionValueId/presentationValues" `
                                -Body $PSItem `
                            | Out-Null
                        }
                    }
                }
            }
            else {
                $PSItem.PSObject.Properties.Remove("id")

                # TODO: get object name
                Write-Log -Level INFO  "Creating definition value..." -Body @{Function = 'Sync-GroupPolicyConfigurationDefinitionValue'; ObjectName = "N/A"; ObjectId = $Id }

                Invoke-IntuneGraphApi -Method Post `
                    -Resource "deviceManagement/groupPolicyConfigurations/$Id/definitionValues" `
                    -Body $PSItem `
                | Out-Null
            }
        }
    }

    end { }
}
