# Mobile Device Management as Code

[![Build Status](https://dev.azure.com/stringle-01/MDM-as-Code/_apis/build/status/MDM-as-Code/MDM-as-Code?branchName=main)](https://dev.azure.com/stringle-01/MDM-as-Code/_build/latest?definitionId=1&branchName=main)

## Environments

We have three tenants (environments).

Each environment has its own:

- Azure Subscription
- Azure Active Directory
- Intune setup
- Azure DevOps service connection

An environment can be selected by setting the environment variables below.

### Development

```powershell
$env:IntuneTenantName = "welcome365dev.onmicrosoft.com"
$env:IntuneTenantId = "b231583b-d29d-4f16-bb2a-1f8d221eaf4d"
$env:IntuneSubscriptionId = "676dc9ba-fccf-454d-8222-615d2f96640f"
$env:IntuneClientId = "97e03613-9e87-4093-aad8-0093302b69fc"
```

### Test

```powershell
$env:IntuneTenantName = "M365x076726.onmicrosoft.com"
$env:IntuneTenantId = "b4b2e768-96e6-4313-b156-15dfc489b860"
$env:IntuneSubscriptionId = "76265442-5ab7-4d92-b69d-41cb113f82cb"
$env:IntuneClientId = "711bbd96-46a3-43cb-95ee-34866a7d1fc3"
```

### Production

```powershell
$env:IntuneTenantName = "welcome365prod.onmicrosoft.com"
$env:IntuneTenantId = "fa822251-bb92-46df-a8fc-219524ba9fbf"
$env:IntuneSubscriptionId = "be148c13-5f8e-414f-a843-a2e1dd444d3c"
$env:IntuneClientId = "2ffe8fcd-4837-49a0-978b-0bf3bf87f2b8"
```

## Repo

The entire code base for pipeline and Intune configurations will be in one git repository.

## Pipeline

The pipeline requires three service connections - one for each tenant.

To create a service connection for a tenant, log in to the tenant using the AZ CLI:

```powershell
az login --tenant $env:IntuneTenantId
```

and execute the `New-AppRegistrationAndServicePrincipal` function:

```powershell
# Switch tenant
az account set --subscription $env:IntuneSubscriptionId

# Import AppRegistration module
Import-Module -Name .\scripts\Modules\AppRegistration -Force

# Create/update new app registration (optionally change role from default (Reader), grant admin consent, or reset any existing password)
$app = New-AppRegistrationAndServicePrincipal -DisplayName <display-name> [-Role <role>] [-Grant] [-ResetPassword]

# Enable the DevOps extension for Azure CLI
az extension add --name azure-devops

# Create/update Azure DevOps service connection
New-AzureDevOpsServiceConnection `
    -Organization <org> `
    -Project <project> `
    -Name <service-connection-name> `
    -TenantId $app.TenantId `
    -SubscriptionName $app.SubscriptionName `
    -SubscriptionId $app.SubscriptionId `
    -AppId $app.AppId `
    -Password $app.Password
```

## Workflow

Configurations will be defined manually in the *dev* environment using the [Microsoft Endpoint Manager admin center](https://aka.ms/intuneportal) (Intune Portal).

When a configuration is completed it can be exported to a `.json` file using the *Intune* module which will place the exported configuration in the git repo.

The pipeline will then pick it up and push the changes to the *test* environment.

## Trunk-based development

In order to make a change to production this will be the workflow:

1. Create a work item which describes the user story and acceptance criteria.
1. Create a new branch in the git repository.
1. Make a change in the *dev* environment.
1. Export the change to the new branch.
1. Push the new branch to Azure DevOps.
1. Pipeline will run a set of automated tests.
1. If tests succeed; create a pull request (PR).
1. Link the PR to the work item.
1. Pipeline will run a new build and trigger the automated approval for the *test* environment. If approved push changes to *test*.
1. Pipeline triggers the manual approval flow for *production*.
1. *Someone* approves.
1. Changes from PR will be merged to the *main* branch.
1. Pipeline triggers a manual approval flow due to gate set on the *production* service connection.
1. At least one reviewer (who did not trigger the pipeline) approves.
1. Pipeline pushed to *production*.

## Governance

The pipeline will include an automated approval flow for moving configurations from *dev* to *test*. An automated approval flow requires automated *unit tests* and possibly *integration tests*. If *all* are *green* we can push to *test*.

After this there will be a manual (user) approval flow to allow the configurations to flow from *test* to *production*.

## Folder structure

Configurations will be stored in the `configuration` folder with the following structure:

```bash
└───configuration
    ├───ResourceGroup e.g. deviceManagement
    │   └───ResourceSubGroup e.g. deviceConfigurations
    │       └───OptionalOperatingSystemName
    │           └───ConfigurationDisplayName
    │                   ConfigurationDisplayName.json
    │                   README.md
    │                   transformations.json
    └───groups
            GroupDisplayName.json
```

## Intune Module

The Intune module contains a set of cmdlets for exporting and importing Intune configurations using the Microsoft Graph API.

First install the required modules and configure logging:

```powershell
$ErrorActionPreference = "Stop"
Install-Module -Name MSAL.PS
Install-Module -Name Logging
Add-LoggingTarget -Name Console # Remove with (Get-LoggingTarget).Clear()
```

Then import the `Intune` module:

```powershell
Import-Module -Name .\scripts\Modules\Intune -Force
```

### Export-IntuneConfiguration

Export Intune configuration by resource to a local folder.

**Note**: Script supports exporting a single configuration by display name by using the `-DisplayName` parameter.

```powershell
# deviceConfigurations
Export-IntuneConfiguration -Resource "deviceManagement/deviceConfigurations" -OutputFolder .\configuration\

# groupPolicyConfigurations
Export-IntuneConfiguration -Resource "deviceManagement/groupPolicyConfigurations" -OutputFolder .\configuration\

# deviceCompliancePolicies
Export-IntuneConfiguration -Resource "deviceManagement/deviceCompliancePolicies" -OutputFolder .\configuration\

# intents (Endpoint Security)
Export-IntuneConfiguration -Resource "deviceManagement/intents" -OutputFolder .\configuration\

# windowsAutopilotDeploymentProfiles
Export-IntuneConfiguration -Resource "deviceManagement/windowsAutopilotDeploymentProfiles" -OutputFolder .\configuration\
```

### Import-IntuneConfiguration

Import Intune configuration from a local folder.

**Note**: You can add the `-WhatIf` parameter to verify whether a configuration will be created or updated.

```powershell
$environment = "Test"

Import-IntuneConfiguration -InputFolder .\configuration\ -Environment $environment
```

### Remove-IntuneConfiguration

Remove Intune configuration by configuration file name (`.../<resourceType>/<subType>/<displayName>/<displayName>.json`).

```powershell
Remove-IntuneConfiguration -ConfigurationFileName "deviceManagement/deviceConfigurations/myConfiguration/myConfiguration.json"
```

### Import-Groups

Sync Intune groups from a local folder.

**Note**: This script will import groups from a local folder.

**Note**: You can add the `-WhatIf` parameter to verify whether a group will be created or updated.

```powershell
Import-IntuneGroup -InputFolder .\configuration\groups\
```

### Sync-IntuneConfiguration

Sync Intune configuration from a local folder.

**Note**: This script will delete any configurations in Intune which are not present in the local folder structure.

**Note**: You can add the `-WhatIf` parameter to verify whether a configuration will be created, updated, or deleted.

```powershell
$environment = "Test"

Sync-IntuneConfiguration -InputFolder .\configuration\ -TempFolder .\temp\ -Environment $environment
```

### Transformations

A configuration can be changed between environments by adding *transformations* to the supplied `transformations.json` file.

Example:

```json
[
    {
        "configuration": "my-config",
        "transformations": [
            {
                "environment": "Test",
                "key": "prop.subprop",
                "value": "new-value"
            },
            {
                "environment": "Production",
                "key": "prop.subprop",
                "reference": {
                    "key-vault-name": "my-keyvault",
                    "secretName": "my-secret-or-certificate"
                }
            }
        ]
    }
]
```
