function ConvertFrom-ConfigurationFileName {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $ConfigurationFileName
    )

    $normalized = $ConfigurationFileName -replace "\\", "/"

    $normalized -match "([^/]+)/([^/]+)/(?:android/|iOS/|windows/|macOS/)?(?:[^/]+)/([^/]+)\.json$"

    @{
        Resource    = $Matches[1] + "/" + $Matches[2]
        DisplayName = $Matches[3]
        FullName    = $Matches[1] + "/" + $Matches[2] + "/" + $Matches[3]
    }
}
