function Get-DeviceCompliancePolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Id
    )

    begin { }

    process {
        $configuration = Invoke-IntuneGraphApi -Method Get `
            -Resource "deviceManagement/deviceCompliancePolicies/${Id}?`$expand=scheduledActionsForRule(`$expand%3DscheduledActionConfigurations)"

        $configuration.PSObject.Properties.Remove("scheduledActionsForRule@odata.context")

        $configuration.scheduledActionsForRule | ForEach-Object {
            $PSItem.PSObject.Properties.Remove("scheduledActionConfigurations@odata.context")
        }

        $configuration
    }

    end { }
}
