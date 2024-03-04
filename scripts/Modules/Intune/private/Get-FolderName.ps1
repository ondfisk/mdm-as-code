function Get-FolderName {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Resource,

        [Parameter(Mandatory = $true)]
        [string]
        $DisplayName,

        [Parameter(Mandatory = $false)]
        [string]
        $ODataType
    )

    $parts = @()
    $parts += $Resource

    $type = $ODataType | Get-FolderNameFromODataType

    if ($type) {
        $parts += $type
    }

    $dot = $DisplayName.LastIndexOf(".")

    if ($dot -ne -1) {
        $parts += $DisplayName.Substring(0, $dot)
    }
    else {
        $parts += $DisplayName
    }

    $parts -join "/"
}
