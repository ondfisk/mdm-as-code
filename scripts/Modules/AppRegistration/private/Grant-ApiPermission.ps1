function Grant-ApiPermission {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServicePrincipalObjectId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Api,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Permission
    )

    $graph = Invoke-Expression -Command "az ad sp show --id $Api" | ConvertFrom-Json

    $existing = Invoke-Expression "az rest --method GET --uri https://graph.microsoft.com/v1.0/oauth2PermissionGrants" |
    ConvertFrom-Json |
    Select-Object -ExpandProperty value |
    Where-Object resourceId -eq $graph.objectId |
    Where-Object clientId -eq $ServicePrincipalObjectId

    if ($existing) {
        $id = $existing.id

        $body = [pscustomobject]@{
            scope = $Permission -join " "
        } | ConvertTo-Json -Compress

        $body = $body -replace "`"", "\`""

        Invoke-Expression -Command "az rest --method PATCH --uri https://graph.microsoft.com/v1.0/oauth2PermissionGrants/$id --headers 'Content-Type=application/json' --body '$body'" | Out-Null
    }
    else {
        $body = [pscustomobject]@{
            clientId    = $ServicePrincipalObjectId
            consentType = "AllPrincipals"
            principalId = $null
            resourceId  = $graph.objectId
            scope       = $Permission -join " "
        } | ConvertTo-Json -Compress

        $body = $body -replace "`"", "\`""

        Invoke-Expression -Command "az rest --method POST --uri https://graph.microsoft.com/v1.0/oauth2PermissionGrants --headers 'Content-Type=application/json' --body '$body'" | Out-Null
    }
}
