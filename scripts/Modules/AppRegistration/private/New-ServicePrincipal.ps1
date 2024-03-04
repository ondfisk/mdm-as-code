function New-ServicePrincipal {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AppId
    )

    $sp = Invoke-Expression -Command "az ad sp list --filter `"appId eq '$AppId'`"" | ConvertFrom-Json

    if (-not $sp) {
        $sp = Invoke-Expression -Command "az ad sp create --id $AppId" | ConvertFrom-Json
    }

    $sp
}
