function Get-ApiPermission {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Api,

        [Parameter(Mandatory = $true)]
        [string[]]
        $AppPermission,

        [Parameter(Mandatory = $true)]
        [string[]]
        $UserPermission
    )

    $graph = Invoke-Expression -Command "az ad sp show --id $Api" | ConvertFrom-Json

    $app = $graph.appRoles | Where-Object value -in $AppPermission | ForEach-Object {
        [pscustomobject]@{
            Value = $PSItem.value
            Id    = $PSItem.id
            Type  = "Role"
        }
    }

    $user = $graph.oauth2Permissions | Where-Object value -in $UserPermission | ForEach-Object {
        [pscustomobject]@{
            Value = $PSItem.value
            Id    = $PSItem.id
            Type  = "Scope"
        }
    }

    $app + $user
}
