BeforeAll {
    . $PSScriptRoot\Get-FolderNameFromODataType.ps1
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "Get-FolderName" {
    Context "Given valid input" {
        It "When resource: <Resource>, display name: <DisplayName>, and OData type: <ODataType>, it returns: <Expected>" -TestCases @(
            @{
                Resource    = "cat/sub"
                DisplayName = "name"
                ODataType   = "windows"
                Expected    = "cat/sub/windows/name"
            }
            @{
                Resource    = "cat/sub"
                DisplayName = "name.ring1"
                ODataType   = "macOS"
                Expected    = "cat/sub/macOS/name"
            }
            @{
                Resource    = "cat/sub"
                DisplayName = "name.beta"
                Expected    = "cat/sub/name"
            }
        ) {
            Get-FolderName -Resource $Resource -DisplayName $DisplayName -ODataType $ODataType | Should -Be $Expected
        }
    }
}
