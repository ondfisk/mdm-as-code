function Get-IntuneGroup {
    [CmdletBinding(DefaultParameterSetName = "Id")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Id")]
        [string]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "DisplayName")]
        [string]
        $DisplayName
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Id" {
            Invoke-IntuneGraphApi -Method Get -Resource "groups/$Id"
        }
        "DisplayName" {
            $groups = Invoke-IntuneGraphApi -Method Get -Resource "groups?`$filter=displayName+eq+'$DisplayName'"

            $group = $groups.value

            if ($group.Count -gt 1) {
                Write-Log -Level ERROR -Message "Found multiple groups with the display name '$displayName' aborting..." -Body @{Function = 'Get-IntuneGroup'; ObjectName = $DisplayName; ObjectId = $Id }
                Write-Error -Message "Found multiple groups with the display name '$displayName' aborting..."
            }

            $group
        }
    }
}