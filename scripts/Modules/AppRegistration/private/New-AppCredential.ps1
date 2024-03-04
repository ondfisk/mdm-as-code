$credentialDescription = "Intune"

function New-AppCredential {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AppId,

        [switch]
        $Force
    )

    if (-not $Force) {
        $existing = Invoke-Expression -Command "az ad app credential list --id $AppId" | ConvertFrom-Json

        $now = Get-Date
        $sixtyDaysFromNow = $now.AddDays(60)

        $latest = $existing | Sort-Object -Property endDate -Descending | Select-Object -First 1
    }

    if ($Force -or $latest.endDate -lt $sixtyDaysFromNow) {
        if ($latest.endDate -gt $now) {
            $append = " --append"
        }

        $credential = Invoke-Expression -Command "az ad app credential reset --id $AppId --credential-description `"$credentialDescription`"$append" | ConvertFrom-Json

        $credential.password | ConvertTo-SecureString -AsPlainText -Force
    }
}
