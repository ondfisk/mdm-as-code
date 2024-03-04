function New-MetaFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $Content
    )

    $exists = Test-Path -Path $Path

    if (-not $exists) {
        $Content | Set-Content -Path $Path
    }
}
