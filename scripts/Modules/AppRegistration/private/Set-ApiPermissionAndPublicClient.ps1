function Set-ApiPermissionAndPublicClient {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Api,

        [psobject[]]
        $Permission
    )

    $body = [pscustomobject]@{
        isFallbackPublicClient = $true
        publicClient           = [pscustomobject]@{
            redirectUris = , "http://localhost:61485"
        }
        requiredResourceAccess = @(
            [pscustomobject]@{
                resourceAppId  = $Api
                resourceAccess = $Permission | ForEach-Object {
                    [pscustomobject]@{
                        id   = $PSItem.Id
                        type = $PSItem.Type
                    }
                }
            }
        )
        web                    = [pscustomobject]@{
            implicitGrantSettings = [pscustomobject]@{
                enableAccessTokenIssuance = $false
                enableIdTokenIssuance     = $false
            }
            redirectUris          = @()
        }
    } | ConvertTo-Json -Compress -Depth 10

    $body = $body -replace "`"", "\`""

    Invoke-Expression -Command "az rest --method PATCH --uri https://graph.microsoft.com/v1.0/applications/$ObjectId --headers 'Content-Type=application/json' --body '$body'" | Out-Null
}
