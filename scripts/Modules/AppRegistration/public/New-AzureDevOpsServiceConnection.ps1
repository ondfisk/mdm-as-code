function New-AzureDevOpsServiceConnection {
    <#
        .SYNOPSIS
        Create or replace Azure DevOps service connection

        .DESCRIPTION
        Create or replace Azure DevOps service connection
        If an existing service connection exists, it will be deleted and replaced.
        You must enable the devops extension on AZ CLI (az extension add --name azure-devops) prior to using this function.

        .PARAMETER Organization
        The Azure DevOps organization name as in https://dev.azure.com/[AzureDevOpsOrganization]
        Using this option will reset the app registration password.

        .PARAMETER Project
        The Azure DevOps project name

        .PARAMETER Name
        The name of the Azure DevOPS service connection.

        .PARAMETER TenantId
        Azure AD tenant

        .PARAMETER SubscriptionName
        Azure subscription name

        .PARAMETER SubscriptionId
        Azure subscription id

        .PARAMETER AppId
        App registration application (client id)

        .PARAMETER Password
        App registration password (client secret)

        .LINK
        AZ CLI: https://aka.ms/azcli
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Organization,

        [Parameter(Mandatory = $true)]
        [string]
        $Project,

        [Parameter(Mandatory = $true)]
        [string]
        $TenantId,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [string]
        $SubscriptionName,

        [Parameter(Mandatory = $true)]
        [string]
        $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]
        $AppId,

        [Parameter(Mandatory = $true)]
        [securestring]
        $Password
    )

    Write-Progress -Activity "Creating Azure DevOps Service Connection" -Status "Getting existing connections..." -PercentComplete 0

    $existing = Invoke-Expression -Command "az devops service-endpoint list --org https://dev.azure.com/$Organization --project '$Project'" | ConvertFrom-Json |
    Where-Object name -eq $Name

    if ($existing) {
        Write-Progress -Activity "Creating Azure DevOps Service Connection" -Status "Deleting existing connection..." -PercentComplete 25

        $id = $existing.id
        Invoke-Expression -Command "az devops service-endpoint delete --org https://dev.azure.com/$Organization --project '$Project' --id $id --yes" | Out-Null
    }

    $clearTextPassword = $Password | ConvertFrom-SecureString -AsPlainText

    Invoke-Expression -Command "`$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY = `"$clearTextPassword`"" | Out-Null

    Write-Progress -Activity "Creating Azure DevOps Service Connection" -Status "Create service connection..." -PercentComplete 50

    $connection = Invoke-Expression -Command "az devops service-endpoint azurerm create --org https://dev.azure.com/$Organization --project '$Project' --azure-rm-service-principal-id $AppId --azure-rm-tenant-id $TenantId --azure-rm-subscription-name '$SubscriptionName' --azure-rm-subscription-id $SubscriptionId --name '$Name'" | ConvertFrom-Json
    $id = $connection.id

    Write-Progress -Activity "Creating Azure DevOps Service Connection" -Status "Enabling service connection for all pipelines..." -PercentComplete 75

    Invoke-Expression -Command "az devops service-endpoint update --org https://dev.azure.com/$Organization --project '$Project' --id $id --enable-for-all true" | Out-Null

    Write-Progress -Activity "Creating Azure DevOps Service Connection" -PercentComplete 100 -Completed
}
