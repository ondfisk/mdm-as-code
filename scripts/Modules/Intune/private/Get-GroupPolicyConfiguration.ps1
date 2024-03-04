function Get-GroupPolicyConfiguration {
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
            -Resource "deviceManagement/groupPolicyConfigurations/$Id"

        $definitionValueResponse = Invoke-IntuneGraphApi -Method Get `
            -Resource "deviceManagement/groupPolicyConfigurations/$Id/definitionValues?`$expand=definition"

        $definitionValues = @()

        $definitionValueResponse.value | ForEach-Object {
            $definitionId = $PSItem.definition.id
            $presentationValuesResponse = Invoke-IntuneGraphApi -Method Get `
                -Resource "deviceManagement/groupPolicyConfigurations/$Id/definitionValues/$($PSItem.id)/presentationValues?`$expand=presentation"

            $presentationValues = @()

            $presentationValuesResponse.value | ForEach-Object {
                $presentationId = $PSItem.presentation.id

                $presentationValue = [pscustomobject]@{
                    id                        = $PSItem.id
                    "@odata.type"             = $PSItem."@odata.type"
                    "presentation@odata.bind" = "$script:graphBaseUri/beta/deviceManagement/groupPolicyDefinitions('$definitionId')/presentations('$presentationId')"
                }

                if ($PSItem.value) {
                    $presentationValue | Add-Member -Name "value" -MemberType NoteProperty -Value $PSItem.value
                }

                if ($PSItem.values) {
                    $presentationValue | Add-Member -Name "values" -MemberType NoteProperty -Value $PSItem.values
                }

                $presentationValues += $presentationValue
            }

            $definitionValues += [pscustomobject]@{
                id                      = $PSItem.id
                enabled                 = $PSItem.enabled
                "definition@odata.bind" = "$script:graphBaseUri/beta/deviceManagement/groupPolicyDefinitions('$definitionId')"
                presentationValues      = $presentationValues
            }
        }

        $configuration | Add-Member -Name "definitionValues" -MemberType NoteProperty -Value $definitionValues

        $configuration
    }

    end { }
}
