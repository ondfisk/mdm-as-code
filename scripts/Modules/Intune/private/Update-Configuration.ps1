function Set-Value {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]
        $Object,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Key,

        [object]
        $Value
    )

    [char[]]$split = "[", "]", "."
    $p1, $p2 = $Key.Split($split, 2, [System.StringSplitOptions]::RemoveEmptyEntries)
    $index = 0

    if ($p2) {
        if ([int]::TryParse($p1, [ref]$index)) {
            Set-Value -Object $Object[$index] -Key $p2 -Value $Value
        }
        else {
            Set-Value -Object $Object.$p1 -Key $p2 -Value $Value
        }
    }
    else {
        if ([int]::TryParse($p1, [ref]$index)) {
            $Object[$index] = $Value
        }
        else {
            $Object.$p1 = $Value
        }
    }
}

function Get-ValueFromKeyVault {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $KeyVaultName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SecretName
    )

    $secret = Invoke-Expression "az keyvault secret show --vault-name $KeyVaultName --name $SecretName" | ConvertFrom-Json
    $secret.value
}

function Update-Configuration {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Configuration,

        [psobject[]]
        $Transformation
    )

    if ($Transformation) {
        $Transformation | ForEach-Object {
            $key = $PSItem.key
            $value = $PSItem.value
            $reference = $PSItem.reference

            if ($reference) {
                $value = Get-ValueFromKeyVault -KeyVaultName $reference.keyVaultName -SecretName $reference.secretName
            }

            Set-Value -Object $Configuration -Key $key -Value $value
        }
    }

    $Configuration
}