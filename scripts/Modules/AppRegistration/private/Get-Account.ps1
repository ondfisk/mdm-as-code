function Get-Account {
    param()

    $account = Invoke-Expression -Command "az account show" | ConvertFrom-Json

    [pscustomobject]@{
        TenantId         = $account.tenantId
        SubscriptionName = $account.name
        SubscriptionId   = $account.id
    }
}
