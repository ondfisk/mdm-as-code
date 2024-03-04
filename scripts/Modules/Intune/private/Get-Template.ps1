function Get-Template {
    [CmdletBinding(DefaultParameterSetName = "Id")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Id")]
        [string]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "DisplayName")]
        [string]
        $DisplayName
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Id" {
            Invoke-IntuneGraphApi -Method Get -Resource "deviceManagement/templates/$Id"
        }
        "DisplayName" {
            $templates = Invoke-IntuneGraphApi -Method Get -Resource "deviceManagement/templates?`$filter=displayName+eq+'$DisplayName'"

            $templates.value
        }
    }
}