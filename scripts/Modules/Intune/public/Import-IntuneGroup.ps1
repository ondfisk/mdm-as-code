function Import-IntuneGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $InputFolder
    )

    Get-ChildItem -Path $InputFolder -Filter "*.json" |
    ForEach-Object {
        $group = Get-Content -Path $PSItem.FullName | ConvertFrom-Json
        $displayName = $group.displayName

        Write-Log -Level INFO -Message "Checking for existing group: $displayName..." -Body @{Function = 'Import-IntuneGroup'; ObjectName = $displayName; ObjectId = "N/A" }

        $existing = Get-IntuneGroup -DisplayName $displayName

        if ($existing) {
            if ($PSCmdlet.ShouldProcess("groups/$displayName", "UPDATE")) {
                $id = $existing.id

                Write-Log -Level INFO -Message "$displayName found. Updating..." -Body @{Function = 'Import-IntuneGroup'; ObjectName = $displayName; ObjectId = "groups/$id" }

                Invoke-IntuneGraphApi -Method Patch `
                    -Resource "groups/$id" `
                    -Body $group |
                Out-Null
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess("groups/$displayName", "CREATE")) {
                Write-Log -Level INFO -Message "$displayName not found. Creating..." -Body @{Function = 'Import-IntuneGroup'; ObjectName = $displayName; ObjectId = "N/A" }

                Invoke-IntuneGraphApi -Method Post `
                    -Resource "groups" `
                    -Body $group |
                Out-Null
            }
        }
    }
}
