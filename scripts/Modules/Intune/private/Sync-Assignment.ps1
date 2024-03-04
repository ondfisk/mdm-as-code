function Sync-Assignment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Resource,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Id,

        [psobject[]]
        $Assignment
    )

    if ($Assignment) {
        [array]$assignments = $Assignment | ForEach-Object {
            $groupDisplayName = $PSItem.target.groupDisplayName

            if ($groupDisplayName) {
                $group = Get-IntuneGroup -DisplayName $groupDisplayName

                if (-not $group) {
                    Write-Log -Level WARNING -Message "Found no group with display name '$groupDisplayName' skipping..." -Body @{Function = 'Sync-Assignment'; ObjectName = $groupDisplayName; ObjectId = "N/A" }
                    Write-Warning -Message "Found no group with display name '$groupDisplayName' skipping..."
                }
                else {
                    [pscustomobject]@{
                        target = [pscustomobject]@{
                            "@odata.type"                              = $PSItem.target."@odata.type"
                            groupId                                    = $group.id
                            deviceAndAppManagementAssignmentFilterType = $PSItem.target.deviceAndAppManagementAssignmentFilterType
                        }
                    }
                }
            }
            else {
                [pscustomobject]@{
                    target = [pscustomobject]@{
                        "@odata.type"                              = $PSItem.target."@odata.type"
                        deviceAndAppManagementAssignmentFilterType = $PSItem.target.deviceAndAppManagementAssignmentFilterType
                    }
                }
            }
        }
    }

    if (-not $assignments) {
        $assignments = @()
    }

    $body = [pscustomobject]@{ assignments = $assignments }

    Invoke-IntuneGraphApi -Method Post `
        -Resource "$Resource/$Id/assign" `
        -Body $body |
    Out-Null
}
