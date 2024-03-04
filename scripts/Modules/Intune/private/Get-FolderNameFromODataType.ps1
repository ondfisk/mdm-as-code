function Get-FolderNameFromODataType {
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]
        $ODataType
    )

    switch -Regex ($ODataType) {
        "android" { "android" }
        "iOS" { "iOS" }
        "macOS" { "macOS" }
        "windows" { "windows" }
        default { "" }
    }
}
