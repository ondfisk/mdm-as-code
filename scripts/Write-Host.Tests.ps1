Describe "Write-Host" {
    $path = Resolve-Path "$PSScriptRoot/.."

    $testCases = Get-ChildItem -Path $path -Include *.ps1, *.psm1 -Exclude "Write-Host.Tests.ps1" -Recurse | ForEach-Object {
        @{
            Name     = $PSItem.FullName.Replace($path, "")
            FullName = $PSItem.FullName
        }
    }

    It "<Name> contains no calls to Write-Host" -TestCases $testCases {
        Get-Content -Path $FullName | Should -Not -Match "Write-Host"
    }
}
