function Get-Intent {
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
            -Resource "deviceManagement/intents/$Id"

        if ($configuration.templateId) {
            $template = Get-Template -Id $configuration.templateId
            $configuration | Add-Member -Name "templateDisplayName" -MemberType NoteProperty -Value $template.displayName
        }

        $settings = Invoke-IntuneGraphApi -Method Get `
            -Resource "deviceManagement/intents/$Id/settings"

        $configuration | Add-Member -Name "settings" -MemberType NoteProperty -Value $settings.value

        $configuration
    }

    end { }
}
