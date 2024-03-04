function Sync-IntentSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Id,

        [psobject[]]
        $Setting
    )

    $Setting | ForEach-Object {
        $PSItem.PSObject.Properties.Remove("id")
        $PSItem.PSObject.Properties.Remove("value")
    }

    $settings = [pscustomobject]@{
        settings = $Setting
    }

    # TODO: get object name
    Write-Log -Level INFO -Message "Updating settings..." -Body @{Function = 'Sync-IntentSetting'; 'ObjectName' = "N/A"; ObjectId = $Id }

    Invoke-IntuneGraphApi -Method Post `
        -Resource "deviceManagement/intents/$Id/updateSettings" `
        -Body $settings |
    Out-Null
}
