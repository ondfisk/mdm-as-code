Describe "Test-Json" {
    $path = Resolve-Path "$PSScriptRoot/.."

    # Test-Json currently does not work on JSON arrays - must be objects.
    $testCases = Get-ChildItem -Path $path -Include *.json -Exclude "transformations.json" -Recurse | ForEach-Object {
        @{
            Name     = $PSItem.FullName.Replace($path, "")
            FullName = $PSItem.FullName
        }
    }

    It "<Name> is valid json" -TestCases $testCases {
        Get-Content -Path $FullName -Raw | Test-Json | Should -Be $true
    }
}
