function Remove-IntuneConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]
        $ConfigurationFileName
    )

    begin { }

    process {
        if ($ConfigurationFileName) {
            $ConfigurationFileName | ForEach-Object {
                $resourceAndDisplayName = $PSItem | ConvertFrom-ConfigurationFileName

                $resource = $resourceAndDisplayName.Resource
                $displayName = $resourceAndDisplayName.DisplayName

                Write-Log -Level INFO -Message "Checking for existing configuration: $PSItem..." -Body @{Function = 'Remove-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }

                $found = Invoke-IntuneGraphApi -Method Get `
                    -Resource "${resource}?`$filter=displayName+eq+'$displayName'"

                $existing = $found.value

                if ($existing.Count -gt 1) {
                    Write-Log -Level ERROR -Message "Found multiple $resource with the display name '$displayName' aborting..." -Body @{Function = 'Remove-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }
                    Write-Error -Message "Found multiple $resource with the display name '$displayName' aborting..."
                }
                else {
                    if ($existing) {
                        $id = $existing.id

                        Write-Log -Level INFO -Message "$PSItem found. Deleting..." -Body @{Function = 'Remove-IntuneConfiguration'; ObjectName = $displayName; ObjectId = $id }

                        Sync-Assignment -Resource $resource -Id $id

                        Invoke-IntuneGraphApi -Method Delete -Resource "$resource/$id" | Out-Null
                    }
                    else {
                        Write-Log -Level INFO -Message "$PSItem not found. Ignoring..." -Body @{Function = 'Remove-IntuneConfiguration'; ObjectName = $displayName; ObjectId = "N/A" }
                    }
                }
            }
        }
    }

    end { }
}
