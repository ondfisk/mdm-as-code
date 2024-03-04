BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "Get-FolderNameFromODataType" {
    It "Given Android it returns android" {
        "#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration" | Get-FolderNameFromODataType | Should -Be "android"
    }

    It "Given iOS it returns iOS" {
        "#microsoft.graph.iosGeneralDeviceConfiguration" | Get-FolderNameFromODataType | Should -Be "iOS"
    }

    It "Given macOS it returns macOS" {
        "#microsoft.graph.macOSCompliancePolicy" | Get-FolderNameFromODataType | Should -Be "macOS"
    }

    It "Given Windows it returns windows" {
        "#microsoft.graph.windows10GeneralConfiguration" | Get-FolderNameFromODataType | Should -Be "windows"
    }

    It "Given non-os type it returns empty string" {
        "#microsoft.graph.edgeSearchEngine" | Get-FolderNameFromODataType | Should -Be ""
    }

    It "Given empty it returns empty string" {
        "" | Get-FolderNameFromODataType | Should -Be ""
    }
}
