function Grant-AdminConsent {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AppId
    )

    Invoke-Expression -Command "az ad app permission admin-consent --id $AppId" | Out-Null
}
