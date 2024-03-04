function New-AppRegistration {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName
    )

    Invoke-Expression -Command "az ad app create --display-name `"$DisplayName`"" | ConvertFrom-Json
}