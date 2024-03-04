function Get-Assignment {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Resource,

        [ValidateNotNullOrEmpty()]
        [string]
        $Id,

        [string]
        $OutputFolder
    )

    # TODO: get object name
    Write-Log -Level INFO  "Getting existing assignments for $Resource/$Id..." -Body @{Function = "Get-Assignment"; ObjectName = "N/A"; ObjectId = "$Resource/$Id" }

    $assignments = Invoke-IntuneGraphApi -Method Get -Resource "$Resource/$Id/assignments"

    $assignments.value | ForEach-Object {
        $groupId = $PSItem.target.groupId
        if ($groupId) {
            Write-Log -Level INFO  "Getting display name for group $groupId..." -Body @{Function = "Get-IntuneGroup"; ObjectName = "N/A"; ObjectId = $groupId }
            $group = Get-IntuneGroup -Id $groupId

            if (-not $group) {
                Write-Log -Level ERROR -Message "Found no group with id '$groupId' aborting..." -Body @{Function = "Get-Assignment"; ObjectName = "N/A"; ObjectId = $groupId }
                Write-Error -Message "Found no group with id '$groupId' aborting..."
            }

            $displayName = $group.displayName

            if ($displayName -match "^\s" -or $displayName -match "\s$") {
                $message = "Found group with leading or trailing whitespace in display name '$displayName' aborting..."
                Write-Log -Level ERROR -Message $message -Body @{Function = "Get-Assignment"; ObjectName = $displayName; ObjectId = $groupId }
                Write-Error -Message $message
            }
            elseif ($OutputFolder) {
                # Setting renewedDateTime is not supported
                $group.PSObject.Properties.Remove("renewedDateTime")

                $outputFile = Join-Path -Path $OutputFolder -ChildPath "groups" -AdditionalChildPath "$displayName.json"
                Write-Log -Level INFO -Message "Exporting $outputFile..."
                New-Item -Path $outputFile -Force | Out-Null
                ConvertTo-Json -InputObject $group -Depth 10 | Set-Content -Path $outputFile
            }

            $PSItem.target | Add-Member -Name "groupDisplayName" -MemberType NoteProperty -Value $displayName
        }
        $PSItem
    }
}